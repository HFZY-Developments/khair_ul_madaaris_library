import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/app_user.dart';
import '../models/book.dart';
import '../models/library_stats.dart';
import '../services/google_sheets_service.dart';

/// Theme Mode Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) { // Default to dark mode
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeStr = prefs.getString(AppConstants.keyThemeMode);
    if (themeModeStr != null) {
      state = ThemeMode.values.firstWhere(
        (e) => e.name == themeModeStr,
        orElse: () => ThemeMode.dark, // Default to dark mode if not found
      );
    } else {
      // CRITICAL: Set dark mode as default on first launch
      state = ThemeMode.dark;
      await prefs.setString(AppConstants.keyThemeMode, ThemeMode.dark.name);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyThemeMode, mode.name);
  }

  void toggleTheme(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    setThemeMode(brightness == Brightness.light ? ThemeMode.dark : ThemeMode.light);
  }
}

/// Current User Provider
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AppUser?>((ref) {
  return CurrentUserNotifier();
});

class CurrentUserNotifier extends StateNotifier<AppUser?> {
  CurrentUserNotifier() : super(null) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(AppConstants.keyUserEmail);
    if (email != null) {
      // Create user from saved data
      state = AppUser(
        id: email,
        email: email,
        displayName: email.split('@').first,
        lastSignIn: DateTime.now(),
      );
    }
  }

  void setUser(AppUser? user) {
    state = user;
  }

  Future<void> clearUser() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyUserEmail);
  }
}

/// Admin Mode Provider
final adminModeProvider = StateNotifierProvider<AdminModeNotifier, bool>((ref) {
  return AdminModeNotifier();
});

class AdminModeNotifier extends StateNotifier<bool> {
  AdminModeNotifier() : super(false) {
    _loadAdminMode();
  }

  Future<void> _loadAdminMode() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(AppConstants.keyIsAdminMode) ?? false;
  }

  Future<void> setAdminMode(bool isAdmin) async {
    state = isAdmin;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsAdminMode, isAdmin);
  }

  Future<bool> verifyAdminPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString(AppConstants.adminPasswordKey) ??
        AppConstants.defaultAdminPassword;
    return password == savedPassword;
  }

  Future<void> updateAdminPassword(String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.adminPasswordKey, newPassword);
  }
}

/// Google Sheets Connection Provider
final sheetsConnectionProvider = StreamProvider<bool>((ref) {
  return GoogleSheetsService.instance.connectionStatus;
});

/// Books List Provider (filters out invalid books)
final booksProvider = FutureProvider<List<Book>>((ref) async {
  final allBooks = await GoogleSheetsService.instance.getAllBooks();
  // Filter out books that don't have title, shelf, AND category
  return allBooks.where((book) {
    return book.title.trim().isNotEmpty &&
        book.shelf.trim().isNotEmpty &&
        book.category.trim().isNotEmpty;
  }).toList();
});

/// Library Stats Provider (calculated from filtered valid books only)
final libraryStatsProvider = FutureProvider<LibraryStats>((ref) async {
  // Get filtered books (only valid ones with title, shelf, category)
  final books = await ref.watch(booksProvider.future);

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

  // Books by category (filter out empty categories)
  final booksByCategory = <String, int>{};
  for (final book in books) {
    if (book.category.trim().isNotEmpty) {
      booksByCategory[book.category] = (booksByCategory[book.category] ?? 0) + 1;
    }
  }

  // Books by shelf (filter out empty shelves)
  final booksByShelf = <String, int>{};
  for (final book in books) {
    if (book.shelf.trim().isNotEmpty) {
      booksByShelf[book.shelf] = (booksByShelf[book.shelf] ?? 0) + 1;
    }
  }

  // Top borrowers
  final borrowerCounts = <String, int>{};
  for (final book in books.where((b) => b.borrowerName != null && b.borrowerName!.trim().isNotEmpty)) {
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
    recentActivities: [], // Not needed for now
    lastUpdated: DateTime.now(),
  );
});

/// Refresh Books Provider (for pull-to-refresh, filters out invalid books)
final refreshBooksProvider = FutureProvider.autoDispose<List<Book>>((ref) async {
  final allBooks = await GoogleSheetsService.instance.getAllBooks(forceRefresh: true);
  // Filter out books that don't have title, shelf, AND category
  return allBooks.where((book) {
    return book.title.trim().isNotEmpty &&
        book.shelf.trim().isNotEmpty &&
        book.category.trim().isNotEmpty;
  }).toList();
});

/// Search Query Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Filtered Books Provider (based on search)
final filteredBooksProvider = Provider<AsyncValue<List<Book>>>((ref) {
  final booksAsync = ref.watch(booksProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return booksAsync.whenData((books) {
    if (searchQuery.isEmpty) return books;

    final query = searchQuery.toLowerCase();
    return books.where((book) {
      return book.title.toLowerCase().contains(query) ||
          book.bookId.toLowerCase().contains(query) ||
          book.category.toLowerCase().contains(query) ||
          book.shelf.toLowerCase().contains(query) ||
          (book.borrowerName?.toLowerCase().contains(query) ?? false);
    }).toList();
  });
});

/// First Launch Provider
final firstLaunchProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(AppConstants.keyIsFirstLaunch) ?? true;
});

/// Set First Launch Complete
Future<void> setFirstLaunchComplete() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(AppConstants.keyIsFirstLaunch, false);
}
