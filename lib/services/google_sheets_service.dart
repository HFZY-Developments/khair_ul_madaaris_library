import 'dart:async';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/book.dart';
import '../models/library_stats.dart';
import 'connectivity_service.dart';

/// Premium Google Sheets Service with Advanced Features:
/// - Rate limiting (60 requests/minute)
/// - Request caching (5-minute expiration)
/// - Exponential backoff retry logic
/// - Connection status monitoring
/// - Batch request optimization
class GoogleSheetsService {
  GoogleSheetsService._();

  static final GoogleSheetsService instance = GoogleSheetsService._();

  final Logger _logger = Logger();
  GoogleSignIn? _googleSignIn;
  sheets.SheetsApi? _sheetsApi;
  auth.AutoRefreshingAuthClient? _authClient;
  bool _isSignedIn = false;

  // Rate Limiting
  final List<DateTime> _requestTimestamps = [];
  int _requestCount = 0;

  // Caching
  final Map<String, _CacheEntry> _cache = {};

  // Connection Status
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  Timer? _connectionCheckTimer;
  bool _lastConnectionStatus = false; // Track last emitted status

  /// Connection status stream - Returns stream with initial value
  Stream<bool> get connectionStatus async* {
    // Emit the last known status immediately to avoid loading state
    yield _lastConnectionStatus;
    // Then emit all future updates
    yield* _connectionController.stream;
  }

  /// Update connection status (helper to update both controller and last status)
  void _updateConnectionStatus(bool status) {
    _lastConnectionStatus = status;
    _connectionController.add(status);
  }

  /// Is signed in
  bool get isSignedIn => _isSignedIn;

  /// Initialize the service
  Future<void> initialize() async {
    try {
      _logger.i('Initializing Google Sheets Service');

      _googleSignIn = GoogleSignIn(
        scopes: [sheets.SheetsApi.spreadsheetsScope],
        serverClientId: AppConstants.serverClientId,
      );

      // OPTIMIZATION: Check if user has ever signed in before
      final prefs = await SharedPreferences.getInstance();
      final hasSignedInBefore = prefs.getString(AppConstants.keyUserEmail) != null;

      // CRITICAL: Set initial connection status based on saved data (prevents scanner lock on relaunch)
      _lastConnectionStatus = hasSignedInBefore;

      if (!hasSignedInBefore) {
        // Skip silent sign-in check if never signed in before (saves time on first launch)
        _logger.i('No previous sign-in detected, skipping silent sign-in check');
        _isSignedIn = false;
        _updateConnectionStatus(false);
      } else {
        // Try silent sign-in with timeout (restore previous session)
        _logger.i('Previous sign-in detected, attempting silent sign-in');
        try {
          final account = await _googleSignIn!.signInSilently(suppressErrors: true);
          if (account != null) {
            await _setupAuthClient(account);
            _isSignedIn = true;
            _updateConnectionStatus(true);
            _logger.i('Silent sign-in successful: ${account.email}');
          } else {
            _logger.w('Silent sign-in returned null (session expired)');
            _isSignedIn = false;
            _updateConnectionStatus(false);
          }
        } catch (e) {
          _logger.e('Silent sign-in failed: $e');
          _isSignedIn = false;
          _updateConnectionStatus(false);
        }
      }

      // Start connection monitoring
      _startConnectionMonitoring();

      _logger.i('Google Sheets Service initialized. Signed in: $_isSignedIn');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize Google Sheets Service', error: e, stackTrace: stackTrace);
      _isSignedIn = false;
      _updateConnectionStatus(false);
      rethrow;
    }
  }

  /// Sign in with Google
  Future<bool> signIn() async {
    try {
      _logger.i('Attempting Google Sign-In');

      // CRITICAL: Check connectivity before attempting sign-in
      final connectivityService = ConnectivityService();
      final isConnected = await connectivityService.checkConnectivity();

      if (!isConnected) {
        _logger.w('No internet connection - cannot sign in');
        throw Exception('NO_INTERNET');
      }

      if (_googleSignIn == null) {
        throw Exception('GoogleSignIn not initialized');
      }

      final account = await _googleSignIn!.signIn();
      if (account == null) {
        _logger.w('User canceled sign-in');
        return false;
      }

      await _setupAuthClient(account);
      _isSignedIn = true;
      _updateConnectionStatus(true);

      // Save sign-in info
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyUserEmail, account.email);
      await prefs.setString(AppConstants.keyLastSyncTime, DateTime.now().toIso8601String());

      _logger.i('Successfully signed in as ${account.email}');
      return true;
    } catch (e, stackTrace) {
      _logger.e('Sign-in failed', error: e, stackTrace: stackTrace);
      _isSignedIn = false;
      _updateConnectionStatus(false);

      // Rethrow to let UI handle the error
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn?.signOut();
      _authClient?.close();
      _authClient = null;
      _sheetsApi = null;
      _isSignedIn = false;
      _updateConnectionStatus(false);
      _clearCache();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyUserEmail);

      _logger.i('Successfully signed out');
    } catch (e, stackTrace) {
      _logger.e('Sign-out failed', error: e, stackTrace: stackTrace);
    }
  }

  /// Setup auth client
  Future<void> _setupAuthClient(GoogleSignInAccount account) async {
    final auth = await account.authentication;
    final credentials = auth.accessToken;

    if (credentials == null) {
      throw Exception('Failed to get access token');
    }

    final authHeaders = {'Authorization': 'Bearer $credentials'};
    final authenticatedClient = _GoogleAuthClient(authHeaders);

    _sheetsApi = sheets.SheetsApi(authenticatedClient);
  }

  /// Start connection monitoring
  void _startConnectionMonitoring() {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = Timer.periodic(
      AppConstants.connectionCheckInterval,
      (_) => _checkConnection(),
    );
  }

  /// Check connection status
  Future<void> _checkConnection() async {
    try {
      if (_sheetsApi == null || AppConstants.spreadsheetId.isEmpty) {
        _updateConnectionStatus(false);
        return;
      }

      // Simple ping to check connectivity
      await _sheetsApi!.spreadsheets.get(AppConstants.spreadsheetId);
      if (!_isSignedIn) {
        _isSignedIn = true;
        _updateConnectionStatus(true);
      }
    } catch (e) {
      if (_isSignedIn) {
        _isSignedIn = false;
        _updateConnectionStatus(false);
      }
    }
  }

  /// Rate limiting check - ensures we don't exceed API limits
  Future<void> _checkRateLimit() async {
    final now = DateTime.now();

    // Remove timestamps older than 1 minute
    _requestTimestamps.removeWhere(
      (timestamp) => now.difference(timestamp).inMinutes >= 1,
    );

    // Check if we've exceeded the rate limit
    if (_requestTimestamps.length >= AppConstants.maxRequestsPerMinute) {
      final oldestRequest = _requestTimestamps.first;
      final waitTime = const Duration(minutes: 1) - now.difference(oldestRequest);

      _logger.w('Rate limit reached. Waiting ${waitTime.inSeconds} seconds');
      await Future.delayed(waitTime);
      _requestTimestamps.clear();
    }

    // Add current request timestamp
    _requestTimestamps.add(now);
    _requestCount++;

    // Small delay between requests for smoother operation
    if (_requestCount % 5 == 0) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Execute request with retry logic
  Future<T> _executeWithRetry<T>(
    Future<T> Function() request, {
    String? cacheKey,
    Duration? cacheDuration,
  }) async {
    // Check cache first
    if (cacheKey != null) {
      final cached = _getFromCache<T>(cacheKey);
      if (cached != null) {
        _logger.d('Cache hit for: $cacheKey');
        return cached;
      }
    }

    // Rate limiting
    await _checkRateLimit();

    // Retry logic with exponential backoff
    int attemptNum = 0;
    Duration delay = const Duration(milliseconds: 1000);

    while (attemptNum < AppConstants.maxRetryAttempts) {
      try {
        final result = await request();

        // Cache the result
        if (cacheKey != null && result != null) {
          _addToCache(cacheKey, result, cacheDuration);
        }

        return result;
      } catch (e) {
        attemptNum++;

        if (attemptNum >= AppConstants.maxRetryAttempts) {
          _logger.e('Request failed after $attemptNum attempts: $e');
          rethrow;
        }

        _logger.w('Request failed (attempt $attemptNum/${AppConstants.maxRetryAttempts}), retrying in ${delay.inSeconds}s');
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }

    throw Exception('Request failed after maximum retries');
  }

  /// Get all books from the inventory with pagination support
  Future<List<Book>> getAllBooks({bool forceRefresh = false}) async {
    const cacheKey = 'all_books';

    if (forceRefresh) {
      _removeFromCache(cacheKey);
    }

    return _executeWithRetry(
      () async {
        _ensureInitialized();

        final List<Book> allBooks = [];
        int pageSize = 500; // Fetch 500 rows at a time to avoid API limits
        int startRow = 2; // Start after header row

        while (true) {
          final endRow = startRow + pageSize - 1;
          final range = '${AppConstants.bookInventorySheet}!A$startRow:G$endRow';

          _logger.d('Fetching books from row $startRow to $endRow');

          try {
            final response = await _sheetsApi!.spreadsheets.values.get(
              AppConstants.spreadsheetId,
              range,
            );

            if (response.values == null || response.values!.isEmpty) {
              // No more books to fetch
              _logger.i('Finished fetching all books. Total: ${allBooks.length}');
              break;
            }

            final booksInThisBatch = response.values!
                .map((row) {
                  try {
                    return Book.fromSheetsRow(row);
                  } catch (e) {
                    _logger.w('Failed to parse book row: $e');
                    return null;
                  }
                })
                .whereType<Book>()
                .toList();

            allBooks.addAll(booksInThisBatch);
            _logger.d('Fetched ${booksInThisBatch.length} books in this batch. Total so far: ${allBooks.length}');

            // If we got fewer rows from Sheets API than requested, we've reached the end
            // Note: Check response.values.length, not booksInThisBatch.length,
            // because some rows might fail to parse but there could still be more data
            if (response.values!.length < pageSize) {
              _logger.i('Reached end of data. Total books: ${allBooks.length}');
              break;
            }

            startRow = endRow + 1;
          } catch (e) {
            _logger.e('Error fetching books batch: $e');
            rethrow;
          }
        }

        return allBooks;
      },
      cacheKey: cacheKey,
      cacheDuration: AppConstants.cacheExpiration,
    );
  }

  /// Get book by ID
  Future<Book?> getBookById(String bookId, {bool forceRefresh = false}) async {
    final cacheKey = 'book_$bookId';

    if (forceRefresh) {
      _removeFromCache(cacheKey);
      _logger.i('Force refreshing book: $bookId');
    }

    return _executeWithRetry(
      () async {
        final books = await getAllBooks(forceRefresh: forceRefresh);
        final book = books.where((book) => book.bookId == bookId).firstOrNull;
        _logger.i('getBookById result for $bookId: ${book != null ? "FOUND (checkout date: ${book.checkoutDate})" : "NOT FOUND"}');
        return book;
      },
      cacheKey: cacheKey,
      cacheDuration: AppConstants.cacheExpiration,
    );
  }

  /// Add new book
  Future<bool> addBook(Book book) async {
    return _executeWithRetry(
      () async {
        _ensureInitialized();

        // Check for duplicates
        final existing = await getBookById(book.bookId);
        if (existing != null) {
          throw Exception('Book with ID ${book.bookId} already exists');
        }

        final valueRange = sheets.ValueRange.fromJson({
          'values': [book.toSheetsRow()],
        });

        await _sheetsApi!.spreadsheets.values.append(
          valueRange,
          AppConstants.spreadsheetId,
          '${AppConstants.bookInventorySheet}!A:G',
          valueInputOption: 'USER_ENTERED',
        );

        _clearCache();
        _logger.i('Book added: ${book.bookId}');
        return true;
      },
    );
  }

  /// Update book (checkout/return)
  Future<bool> updateBook(Book book) async {
    return _executeWithRetry(
      () async {
        _ensureInitialized();

        // Find the row index
        final books = await getAllBooks(forceRefresh: true);
        final index = books.indexWhere((b) => b.bookId == book.bookId);

        if (index == -1) {
          throw Exception('Book not found: ${book.bookId}');
        }

        final rowNumber = index + 2; // +2 because of header row and 0-based index
        final sheetsRow = book.toSheetsRow();

        _logger.i('DEBUG UPDATE: Row number: $rowNumber');
        _logger.i('DEBUG UPDATE: Sheets row data: $sheetsRow');
        _logger.i('DEBUG UPDATE: Checkout date in row: ${sheetsRow[6]}');

        final valueRange = sheets.ValueRange.fromJson({
          'values': [sheetsRow],
        });

        final range = '${AppConstants.bookInventorySheet}!A$rowNumber:G$rowNumber';
        _logger.i('DEBUG UPDATE: Updating range: $range');

        await _sheetsApi!.spreadsheets.values.update(
          valueRange,
          AppConstants.spreadsheetId,
          range,
          valueInputOption: 'USER_ENTERED',
        );

        _clearCache();
        _logger.i('Book updated: ${book.bookId}');
        return true;
      },
    );
  }

  /// Checkout book
  Future<bool> checkoutBook(String bookId, String borrowerName) async {
    final book = await getBookById(bookId);
    if (book == null) {
      throw Exception(AppConstants.errorBookNotFound);
    }

    if (book.status == BookStatus.checkedOut) {
      throw Exception(AppConstants.errorAlreadyCheckedOut);
    }

    final checkoutDate = DateTime.now();
    _logger.i('DEBUG CHECKOUT: Creating updated book with checkout date: $checkoutDate');

    final updatedBook = book.copyWith(
      status: BookStatus.checkedOut,
      borrowerName: borrowerName,
      checkoutDate: checkoutDate,
    );

    _logger.i('DEBUG CHECKOUT: Updated book checkout date: ${updatedBook.checkoutDate}');
    _logger.i('DEBUG CHECKOUT: Updated book sheets row: ${updatedBook.toSheetsRow()}');

    return updateBook(updatedBook);
  }

  /// Return book
  Future<bool> returnBook(String bookId) async {
    final book = await getBookById(bookId);
    if (book == null) {
      throw Exception(AppConstants.errorBookNotFound);
    }

    if (book.status != BookStatus.checkedOut) {
      throw Exception(AppConstants.errorNotCheckedOut);
    }

    final updatedBook = book.copyWith(
      status: BookStatus.available,
      clearBorrower: true,
      clearCheckoutDate: true,
    );

    return updateBook(updatedBook);
  }

  /// Get library statistics
  Future<LibraryStats> getLibraryStats({bool forceRefresh = false}) async {
    const cacheKey = 'library_stats';

    if (forceRefresh) {
      _removeFromCache(cacheKey);
    }

    return _executeWithRetry(
      () async {
        final books = await getAllBooks(forceRefresh: forceRefresh);

        if (books.isEmpty) {
          return LibraryStats.empty();
        }

        final totalBooks = books.length;
        final availableBooks = books.where((b) => b.status == BookStatus.available).length;
        final checkedOutBooks = books.where((b) => b.status == BookStatus.checkedOut).length;
        final overdueBooks = books.where((b) => b.isOverdue).length;
        final reservedBooks = books.where((b) => b.status == BookStatus.reserved).length;
        final damagedBooks = books.where((b) => b.status == BookStatus.damaged).length;
        final lostBooks = books.where((b) => b.status == BookStatus.lost).length;

        // Books by category
        final booksByCategory = <String, int>{};
        for (final book in books) {
          booksByCategory[book.category] = (booksByCategory[book.category] ?? 0) + 1;
        }

        // Books by shelf
        final booksByShelf = <String, int>{};
        for (final book in books) {
          booksByShelf[book.shelf] = (booksByShelf[book.shelf] ?? 0) + 1;
        }

        // Top borrowers
        final borrowerCounts = <String, int>{};
        for (final book in books.where((b) => b.borrowerName != null)) {
          final name = book.borrowerName!;
          borrowerCounts[name] = (borrowerCounts[name] ?? 0) + 1;
        }

        final topBorrowers = borrowerCounts.entries
            .map((e) => TopBorrower(name: e.key, booksCheckedOut: e.value))
            .toList()
          ..sort((a, b) => b.booksCheckedOut.compareTo(a.booksCheckedOut));

        return LibraryStats(
          totalBooks: totalBooks,
          availableBooks: availableBooks,
          checkedOutBooks: checkedOutBooks,
          overdueBooks: overdueBooks,
          reservedBooks: reservedBooks,
          damagedBooks: damagedBooks,
          lostBooks: lostBooks,
          booksByCategory: booksByCategory,
          booksByShelf: booksByShelf,
          topBorrowers: topBorrowers.take(10).toList(),
          recentActivities: [],
          lastUpdated: DateTime.now(),
        );
      },
      cacheKey: cacheKey,
      cacheDuration: AppConstants.cacheExpiration,
    );
  }

  /// Clear all cache
  void _clearCache() {
    _cache.clear();
    _logger.d('Cache cleared');
  }

  /// Add to cache
  void _addToCache<T>(String key, T value, Duration? duration) {
    _cache[key] = _CacheEntry(
      value,
      DateTime.now().add(duration ?? AppConstants.cacheExpiration),
    );
  }

  /// Get from cache
  T? _getFromCache<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      return null;
    }

    return entry.value as T?;
  }

  /// Remove from cache
  void _removeFromCache(String key) {
    _cache.remove(key);
  }

  /// Ensure service is initialized
  void _ensureInitialized() {
    if (_sheetsApi == null) {
      throw Exception('Google Sheets Service not initialized or signed in');
    }
    if (AppConstants.spreadsheetId.isEmpty) {
      throw Exception('Spreadsheet ID not configured');
    }
  }

  /// Dispose resources
  void dispose() {
    _connectionCheckTimer?.cancel();
    _connectionController.close();
    _authClient?.close();
  }
}

/// Cache Entry
class _CacheEntry {
  final dynamic value;
  final DateTime expiresAt;

  _CacheEntry(this.value, this.expiresAt);
}

/// Custom HTTP client for Google Auth
class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }

  @override
  void close() {
    _client.close();
  }
}
