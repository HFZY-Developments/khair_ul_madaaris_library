import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../core/widgets/premium_dialogs.dart';
import '../features/update/update_dialog.dart';
import '../features/update/download_progress_dialog.dart';
import '../features/update/installer_status_dialog.dart';

/// Service to handle in-app updates
///
/// This service checks for new versions, downloads APK files, and triggers installation.
/// All operations are wrapped in try-catch to ensure app stability.
class AppUpdateService {
  // GitHub raw URL for version.json
  static const String _versionCheckUrl =
      'https://raw.githubusercontent.com/HFZY-Developments/khair_ul_madaaris_library/main/version.json';

  // Feature flag to enable/disable auto-update
  static const bool enableAutoUpdate = true;

  // Download progress tracking
  static ValueNotifier<double> downloadProgress = ValueNotifier<double>(0.0);
  static ValueNotifier<String> downloadStatus = ValueNotifier<String>('');

  /// Check for updates in background (called on app startup)
  /// Shows popup only if update is available and user is on home screen
  static Future<void> checkForUpdatesBackground(BuildContext context) async {
    if (!enableAutoUpdate) return;

    try {
      // Clean up old APK files from previous installations
      _cleanupOldApkFiles();

      // Wait a bit before checking (let app load first)
      await Future.delayed(const Duration(seconds: 2));

      // Check if mounted
      if (!context.mounted) return;

      // Check for update with timeout
      final updateInfo = await _fetchUpdateInfo().timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );

      if (updateInfo != null && context.mounted) {
        debugPrint('🎯 Showing update dialog now...');
        // Show update dialog
        await showUpdateDialog(context, updateInfo);
      } else {
        debugPrint(
          '❌ Update dialog NOT shown. updateInfo: ${updateInfo != null}, context.mounted: ${context.mounted}',
        );
      }
    } catch (e) {
      // Silent failure - app continues normally
      debugPrint('Background update check failed: $e');
    }
  }

  /// Manual update check (called from Settings button)
  static Future<void> checkForUpdatesManual(BuildContext context) async {
    var loadingDialogVisible = false;
    try {
      // Check network connectivity first
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        // No network connection
        if (context.mounted) {
          await showPremiumErrorDialog(
            context,
            title: 'No Network Connection',
            message: 'Please check your internet connection and try again.',
            icon: Icons.wifi_off_rounded,
          );
        }
        return;
      }

      // Show loading
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );
      loadingDialogVisible = true;

      final updateInfo = await _fetchUpdateInfo().timeout(
        const Duration(seconds: 15),
      );

      // Close loading
      if (context.mounted &&
          loadingDialogVisible &&
          Navigator.canPop(context)) {
        Navigator.pop(context);
        loadingDialogVisible = false;
      }

      if (updateInfo != null && context.mounted) {
        await showUpdateDialog(context, updateInfo);
      } else if (context.mounted) {
        // No update available
        await showPremiumSuccessDialog(
          context,
          title: 'You\'re Up to Date!',
          message: 'You have the latest version of the app.',
          icon: Icons.check_circle_rounded,
        );
      }
    } catch (e) {
      if (context.mounted &&
          loadingDialogVisible &&
          Navigator.canPop(context)) {
        Navigator.pop(context); // Close loading
        loadingDialogVisible = false;
      }
      if (context.mounted) {
        await showPremiumErrorDialog(
          context,
          title: 'Update Check Failed',
          message: 'Could not check for updates. Please try again later.',
          icon: Icons.cloud_off_rounded,
        );
      }
    }
  }

  /// Fetch update information from GitHub
  static Future<Map<String, dynamic>?> _fetchUpdateInfo() async {
    try {
      // Get current version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 1;

      debugPrint('🔍 UPDATE CHECK START');
      debugPrint('📱 Current Version: ${packageInfo.version}');
      debugPrint('📱 Current Version Code: $currentVersionCode');
      debugPrint('🌐 Checking URL: $_versionCheckUrl');

      // Fetch version.json from GitHub
      final response = await http.get(Uri.parse(_versionCheckUrl));

      debugPrint('📡 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ Response Body: ${response.body}');

        final versionData = _parseUpdateInfo(jsonDecode(response.body));
        if (versionData == null) {
          debugPrint(
            '❌ version.json format invalid. Required keys: version, versionCode, downloadUrl, sha256',
          );
          return null;
        }

        final latestVersionCode = versionData['versionCode'] as int;
        final latestVersion = versionData['version'] as String;

        debugPrint('☁️ Latest Version: $latestVersion');
        debugPrint('☁️ Latest Version Code: $latestVersionCode');
        debugPrint(
          '🔄 Comparison: $latestVersionCode > $currentVersionCode = ${latestVersionCode > currentVersionCode}',
        );

        // Check if update is needed
        if (latestVersionCode > currentVersionCode) {
          debugPrint('🎉 UPDATE AVAILABLE!');
          return versionData;
        } else {
          debugPrint('✋ No update needed (already on latest or newer)');
        }
      } else {
        debugPrint('❌ Failed to fetch version.json: ${response.statusCode}');
      }

      return null; // No update available
    } catch (e) {
      debugPrint('💥 Error fetching update info: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  /// Download and install update
  static Future<void> downloadAndInstall(
    BuildContext context,
    Map<String, dynamic> updateInfo,
  ) async {
    // Capture navigator before any async operations
    final navigator = Navigator.of(context);
    var progressDialogVisible = false;

    try {
      final downloadUrl = updateInfo['downloadUrl'] as String;
      final expectedSha256 = _normalizeExpectedSha256(updateInfo);

      if (expectedSha256 == null) {
        if (context.mounted) {
          await showPremiumErrorDialog(
            context,
            title: 'Update Blocked',
            message:
                'This update is missing a valid security checksum (SHA-256).\n\nPlease contact support and try again later.',
            icon: Icons.security_rounded,
          );
        }
        return;
      }

      // No permission needed for Android 11+ (uses app-specific storage)
      // Android 10 and below: Try to get permission, but continue anyway
      // (files are saved to app's temp directory which doesn't need permission)

      // Show download progress dialog
      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false, // Cannot dismiss by tapping outside
        builder: (ctx) => const DownloadProgressDialog(),
      );
      progressDialogVisible = true;

      // Get download directory
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/app-update.apk';

      // LOGGING: Show exact file location (works in debug & release)
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📁 APK DOWNLOAD LOCATION:');
      debugPrint('   Directory: ${directory.path}');
      debugPrint('   Full Path: $filePath');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Delete old APK if exists
      final file = File(filePath);
      if (await file.exists()) {
        final fileSize = await file.length();
        final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
        debugPrint(
          '🗑️  Deleting old APK (${fileSizeMB}MB) before downloading new one',
        );
        await file.delete();
        debugPrint('✅ Old APK deleted successfully');
      } else {
        debugPrint('ℹ️  No old APK found, proceeding with fresh download');
      }

      // Download APK using Dio
      downloadStatus.value = 'Downloading update...';
      debugPrint('⬇️  Starting download from: $downloadUrl');

      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 30),
          validateStatus: (status) {
            // Reject 404 and other errors immediately
            return status != null && status >= 200 && status < 300;
          },
        ),
      );

      await dio.download(
        downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            downloadProgress.value = progress;

            final percentage = (progress * 100).toStringAsFixed(0);
            downloadStatus.value = 'Downloading... $percentage%';

            // Log every 25% progress
            if (percentage == '25' ||
                percentage == '50' ||
                percentage == '75') {
              final receivedMB = (received / (1024 * 1024)).toStringAsFixed(2);
              final totalMB = (total / (1024 * 1024)).toStringAsFixed(2);
              debugPrint(
                '📊 Download Progress: $percentage% ($receivedMB MB / $totalMB MB)',
              );
            }
          }
        },
      );

      // Download complete - verify file
      final downloadedFile = File(filePath);
      if (!await downloadedFile.exists()) {
        throw Exception(
          'Downloaded file not found at expected path: $filePath',
        );
      }

      final fileSize = await downloadedFile.length();
      final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
      debugPrint('✅ Download Complete!');
      debugPrint('   File Size: ${fileSizeMB}MB');
      debugPrint('   Saved at: $filePath');

      // Verify APK integrity before opening installer
      downloadStatus.value = 'Verifying package integrity...';
      final actualSha256 = await _calculateFileSha256(downloadedFile);
      final isHashValid = actualSha256.toLowerCase() == expectedSha256;
      if (!isHashValid) {
        if (progressDialogVisible && navigator.canPop()) {
          navigator.pop();
          progressDialogVisible = false;
        }
        if (context.mounted) {
          await showPremiumErrorDialog(
            context,
            title: 'Security Check Failed',
            message:
                'The downloaded update failed integrity verification and was blocked.\n\nExpected: $expectedSha256\nActual: $actualSha256',
            icon: Icons.security_rounded,
          );
        }
        return;
      }

      // Integrity verified
      downloadStatus.value = 'Integrity verified. Installing...';
      downloadProgress.value = 1.0;

      // Close progress dialog
      await Future.delayed(const Duration(milliseconds: 500));
      if (progressDialogVisible && navigator.canPop()) {
        navigator.pop();
        progressDialogVisible = false;
      }

      // Install APK using platform channel (native Android method)
      debugPrint('📦 Opening installer for: $filePath');

      try {
        const platform = MethodChannel(
          'com.hfzy.khair_ul_madaaris_library/install',
        );
        await platform.invokeMethod('installApk', {'filePath': filePath});
        debugPrint('✅ Installer opened successfully');

        // Show dialog that detects if user cancels
        if (context.mounted) {
          final shouldRetry = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => InstallingDialog(updateInfo: updateInfo),
          );

          // If user pressed "Try Again", retry the download
          if (shouldRetry == true && context.mounted) {
            debugPrint('🔄 User requested retry - restarting download');
            await downloadAndInstall(context, updateInfo);
          }
        }
      } catch (e) {
        debugPrint('❌ Failed to open installer: $e');
        if (context.mounted) {
          await showPremiumErrorDialog(
            context,
            title: 'Installation Error',
            message: 'Please install the APK manually from:\n$filePath',
            icon: Icons.error_rounded,
          );
        }
      }

      // Note: After this point, the system's package installer takes over
      // The app may be closed during installation

      // DON'T delete immediately - let Android finish copying the file
      // Cleanup will happen on next app launch instead (safer for slow devices)
      // See _cleanupOldApkFiles() which runs on app startup
    } on DioException catch (e) {
      debugPrint('Error downloading update: ${e.type} - ${e.message}');

      // Determine user-friendly error message
      String title = 'Update Failed';
      String message = 'Could not download the update. Please try again later.';

      if (e.response?.statusCode == 404) {
        title = 'Update Not Available';
        message =
            'The update file is currently unavailable. Please check back later or contact support.';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        title = 'Download Timed Out';
        message =
            'The download took too long. Please check your internet connection and try again.';
      } else if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        title = 'Connection Error';
        message =
            'Unable to connect to the server. Please check your internet connection and try again.';
      } else if (e.type == DioExceptionType.cancel) {
        title = 'Download Cancelled';
        message =
            'The download was cancelled. You can try again from Settings.';
      }

      // Close progress dialog and show error
      try {
        debugPrint('🔴 Closing download dialog...');
        if (progressDialogVisible && navigator.canPop()) {
          navigator.pop();
          progressDialogVisible = false;
          debugPrint('✅ Download dialog closed');
        }
      } catch (e) {
        debugPrint('❌ Failed to close dialog: $e');
      }

      // Small delay to let dialog close
      await Future.delayed(const Duration(milliseconds: 300));

      debugPrint(
        '📢 Attempting to show error dialog. context.mounted: ${context.mounted}',
      );

      try {
        if (context.mounted) {
          debugPrint('✅ Showing error dialog: $title');
          await showPremiumErrorDialog(
            context,
            title: title,
            message: message,
            icon: Icons.cloud_off_rounded,
          );
          debugPrint('✅ Error dialog shown successfully');
        } else {
          debugPrint('❌ Cannot show error - context not mounted');
        }
      } catch (e) {
        debugPrint('❌ Failed to show error dialog: $e');
      }
    } catch (e) {
      debugPrint('Unexpected error during update: $e');

      // Close progress dialog and show error
      if (progressDialogVisible && navigator.canPop()) {
        navigator.pop();
        progressDialogVisible = false;
      }

      // Small delay to let dialog close
      await Future.delayed(const Duration(milliseconds: 300));

      debugPrint(
        '📢 Attempting to show error dialog. context.mounted: ${context.mounted}',
      );

      if (context.mounted) {
        debugPrint('✅ Showing unexpected error dialog');
        await showPremiumErrorDialog(
          context,
          title: 'Update Failed',
          message: 'An unexpected error occurred. Please try again later.',
          icon: Icons.error_rounded,
        );
      } else {
        debugPrint('❌ Cannot show error - context not mounted');
      }
    }
  }

  static Map<String, dynamic>? _parseUpdateInfo(dynamic jsonData) {
    if (jsonData is! Map<String, dynamic>) {
      return null;
    }

    final versionCode = jsonData['versionCode'];
    final version = jsonData['version'];
    final downloadUrl = jsonData['downloadUrl'];
    final sha256 = jsonData['sha256'];

    if (versionCode is! int ||
        version is! String ||
        downloadUrl is! String ||
        downloadUrl.trim().isEmpty ||
        sha256 is! String ||
        !_isValidSha256(sha256.trim().toLowerCase())) {
      return null;
    }

    return Map<String, dynamic>.from(jsonData);
  }

  static String? _normalizeExpectedSha256(Map<String, dynamic> updateInfo) {
    final value = updateInfo['sha256'];
    if (value is! String) return null;
    final normalized = value.trim().toLowerCase();
    if (!_isValidSha256(normalized)) return null;
    return normalized;
  }

  static bool _isValidSha256(String value) {
    return RegExp(r'^[a-f0-9]{64}$').hasMatch(value);
  }

  @visibleForTesting
  static Map<String, dynamic>? parseUpdateInfoForTesting(dynamic jsonData) {
    return _parseUpdateInfo(jsonData);
  }

  @visibleForTesting
  static String? normalizeExpectedSha256ForTesting(
    Map<String, dynamic> updateInfo,
  ) {
    return _normalizeExpectedSha256(updateInfo);
  }

  @visibleForTesting
  static bool verifySha256ForTesting({
    required Uint8List bytes,
    required Map<String, dynamic> updateInfo,
  }) {
    final expectedSha256 = _normalizeExpectedSha256(updateInfo);
    if (expectedSha256 == null) {
      return false;
    }
    final actualSha256 = sha256FromBytes(bytes);
    return actualSha256.toLowerCase() == expectedSha256;
  }

  @visibleForTesting
  static String sha256FromBytes(Uint8List bytes) {
    return sha256.convert(bytes).toString();
  }

  static Future<String> _calculateFileSha256(File file) async {
    final bytes = await file.readAsBytes();
    return sha256FromBytes(bytes);
  }

  /// Show update dialog
  static Future<void> showUpdateDialog(
    BuildContext context,
    Map<String, dynamic> updateInfo,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // Mandatory update
      builder: (ctx) => UpdateDialog(updateInfo: updateInfo),
    );
  }

  /// Clean up old APK files (called on app startup)
  ///
  /// This is safe because:
  /// 1. If installation succeeded, we're running the new version - old APK no longer needed
  /// 2. If installation failed, user can download again
  /// 3. Runs 3 seconds after startup to ensure Android released file handles
  static void _cleanupOldApkFiles() {
    Future.delayed(const Duration(seconds: 3), () async {
      try {
        final directory = await getTemporaryDirectory();
        final apkFile = File('${directory.path}/app-update.apk');

        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('🧹 APK CLEANUP CHECK (runs 3s after app startup)');
        debugPrint('   Checking: ${apkFile.path}');

        if (await apkFile.exists()) {
          final fileSize = await apkFile.length();
          final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
          debugPrint('   Found old APK: ${fileSizeMB}MB');

          // Try to delete - if file is still in use by system, this will fail silently
          await apkFile.delete();
          debugPrint('   ✅ Old APK deleted successfully');
          debugPrint('   Storage freed: ${fileSizeMB}MB');
        } else {
          debugPrint(
            '   ℹ️  No old APK found (already cleaned or never existed)',
          );
        }
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      } catch (e) {
        // Silent failure - file might still be in use, will be cleaned next time
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('⚠️  Could not cleanup old APK (file may be in use): $e');
        debugPrint('   Will try again on next app launch');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      }
    });
  }
}
