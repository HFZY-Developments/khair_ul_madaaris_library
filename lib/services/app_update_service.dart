import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/widgets/premium_dialogs.dart';
import '../features/update/update_dialog.dart';
import '../features/update/download_progress_dialog.dart';

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
        // Show update dialog
        await showUpdateDialog(context, updateInfo);
      }
    } catch (e) {
      // Silent failure - app continues normally
      debugPrint('Background update check failed: $e');
    }
  }

  /// Manual update check (called from Settings button)
  static Future<void> checkForUpdatesManual(BuildContext context) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final updateInfo = await _fetchUpdateInfo().timeout(
        const Duration(seconds: 15),
      );

      // Close loading
      if (context.mounted) {
        Navigator.pop(context);
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
      if (context.mounted) {
        Navigator.pop(context); // Close loading
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

      // Fetch version.json from GitHub
      final response = await http.get(Uri.parse(_versionCheckUrl));

      if (response.statusCode == 200) {
        final versionData = jsonDecode(response.body);
        final latestVersionCode = versionData['versionCode'] as int;

        // Check if update is needed
        if (latestVersionCode > currentVersionCode) {
          return versionData;
        }
      }

      return null; // No update available
    } catch (e) {
      debugPrint('Error fetching update info: $e');
      return null;
    }
  }

  /// Download and install update
  static Future<void> downloadAndInstall(
    BuildContext context,
    Map<String, dynamic> updateInfo,
  ) async {
    try {
      final downloadUrl = updateInfo['downloadUrl'] as String;

      // Request storage permission for Android 10 and below
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          if (context.mounted) {
            await showPremiumErrorDialog(
              context,
              title: 'Permission Required',
              message: 'Storage permission is needed to download updates.',
              icon: Icons.error_rounded,
            );
          }
          return;
        }
      }

      // Show download progress dialog
      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false, // Cannot dismiss by tapping outside
        builder: (ctx) => const DownloadProgressDialog(),
      );

      // Get download directory
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/app-update.apk';

      // Delete old APK if exists
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Download APK using Dio
      downloadStatus.value = 'Downloading update...';

      final dio = Dio();
      await dio.download(
        downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            downloadProgress.value = progress;

            final percentage = (progress * 100).toStringAsFixed(0);
            downloadStatus.value = 'Downloading... $percentage%';
          }
        },
      );

      // Download complete
      downloadStatus.value = 'Download complete! Installing...';
      downloadProgress.value = 1.0;

      // Close progress dialog
      await Future.delayed(const Duration(milliseconds: 500));
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Open APK file for installation
      final result = await OpenFile.open(filePath);

      debugPrint('Install result: ${result.message}');

      // Note: After this point, the system's package installer takes over
      // The app may be closed during installation

      // DON'T delete immediately - let Android finish copying the file
      // Cleanup will happen on next app launch instead (safer for slow devices)
      // See _cleanupOldApkFiles() which runs on app startup
    } catch (e) {
      debugPrint('Error downloading/installing update: $e');

      if (context.mounted) {
        Navigator.pop(context); // Close progress dialog
        await showPremiumErrorDialog(
          context,
          title: 'Update Failed',
          message: 'Could not install update. Please try again later.\n\nError: ${e.toString()}',
          icon: Icons.error_rounded,
        );
      }
    }
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

        if (await apkFile.exists()) {
          // Try to delete - if file is still in use by system, this will fail silently
          await apkFile.delete();
          debugPrint('Cleaned up old APK file from previous update');
        }
      } catch (e) {
        // Silent failure - file might still be in use, will be cleaned next time
        debugPrint('Could not cleanup old APK (file may be in use): $e');
      }
    });
  }
}
