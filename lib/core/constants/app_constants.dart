/// App-wide constants and configuration
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Khair-ul-Madaaris Library';
  static const String appNameArabic = 'مكتبة خير المدارس';
  static const String appTagline = 'Premium Library Management';
  static const String developerName =
      'HFZY Developments'; // TODO: Update with your name
  static const String developerEmail = 'hfzy.apps@gmail.com'; // TODO: Update

  // Google Sheets Configuration
  static const String spreadsheetId =
      '1NabXmw_La-ejig_h615hzncBfcwDQIsyhDv0o1Kfn9c'; // TODO: Add your spreadsheet ID
  static const String bookInventorySheet = 'Book Inventory';
  static const String statsSheet = 'Statistics';
  static const String settingsSheet = 'Settings';

  // Google OAuth
  static const String serverClientId =
      '698382210573-pgtlkqbvv9bnvk9bekv6qi2tkoll6fst.apps.googleusercontent.com'; // TODO: Add your OAuth client ID

  // API Rate Limiting (to stay within Google's limits)
  static const int maxRequestsPerMinute =
      60; // Google allows 300, we use 60 for safety
  static const int requestDelayMs = 1000; // 1 second between requests
  static const int maxRetryAttempts = 3;
  static const int retryDelayMs = 2000; // 2 seconds between retries

  // Cache Duration
  static const Duration cacheExpiration = Duration(minutes: 5);
  static const Duration connectionCheckInterval = Duration(seconds: 10);

  // Admin
  static const String defaultAdminPassword = 'admin123';
  static const String adminPasswordKey = 'admin_password';

  // SharedPreferences Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyLastSyncTime = 'last_sync_time';
  static const String keyUserEmail = 'user_email';
  static const String keyCachedBooks = 'cached_books';
  static const String keyIsAdminMode = 'is_admin_mode';

  // UI Constants
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXL = 24.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXL = 32.0;

  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXL = 48.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationSlower = Duration(milliseconds: 800);

  // QR Scanner
  static const double qrScannerFrameSize = 280.0;
  static const double qrScannerCornerLength = 32.0;
  static const double qrScannerCornerWidth = 4.0;

  // Book Statuses
  static const String statusAvailable = 'Available';
  static const String statusCheckedOut = 'Checked Out';
  static const String statusOverdue = 'Overdue';
  static const String statusReserved = 'Reserved';
  static const String statusDamaged = 'Damaged';
  static const String statusLost = 'Lost';

  // Validation
  static const int minTitleLength = 2;
  static const int maxTitleLength = 200;
  static const int minAuthorLength = 2;
  static const int maxAuthorLength = 100;
  static const int minBorrowerLength = 2;
  static const int maxBorrowerLength = 100;

  // Error Messages
  static const String errorNoInternet =
      'No internet connection. Please check your network.';
  static const String errorGeneric = 'An error occurred. Please try again.';
  static const String errorBookNotFound = 'Book not found in the system.';
  static const String errorAlreadyCheckedOut =
      'This book is already checked out.';
  static const String errorNotCheckedOut =
      'This book is not currently checked out.';
  static const String errorInvalidQR =
      'Invalid QR code. Please scan a valid book code.';
  static const String errorRateLimit =
      'Too many requests. Please wait a moment.';

  // Success Messages
  static const String successBookAdded = 'Book added successfully!';
  static const String successBookCheckedOut = 'Book checked out successfully!';
  static const String successBookReturned = 'Book returned successfully!';
  static const String successBookUpdated = 'Book updated successfully!';

  // Donation
  static const String donateUrl =
      'https://www.example.com/donate'; // TODO: Update
  static const String donateMessage =
      'Support the development of this free app';

  // Help & Support
  static const String helpEmail = 'hfzy.apps@gmail.com';
  static const String privacyPolicyUrl =
      'https://www.example.com/privacy'; // TODO: Update
  static const String termsOfServiceUrl =
      'https://www.example.com/terms'; // TODO: Update
}
