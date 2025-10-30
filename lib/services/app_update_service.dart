import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:r_upgrade/r_upgrade.dart';
import '../core/widgets/premium_dialogs.dart';
import '../features/update/update_dialog.dart';
import '../features/update/download_progress_dialog.dart';

/// Service to handle in-app updates
///
/// This service checks for new versions, downloads APK files, and triggers installation.
/// All operations are wrapped in try-catch to ensure app stability.
class AppUpdateService {
  // GitHub raw URL for version.json (you'll replace this with your actual URL)
  static const String _versionCheckUrl =
      'https://raw.githubusercontent.com/YOUR_USERNAME/khair_ul_madaaris_library/main/version.json';

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

      // Download APK using r_upgrade
      downloadStatus.value = 'Downloading update...';

      int? upgradeId = await RUpgrade.upgrade(
        downloadUrl,
        fileName: 'app-update.apk',
        useDownloadManager: false,
        installType: UpgradeInstallType.normal,
        notificationStyle: NotificationStyle.planTime,
        notificationVisibility: NotificationVisibility.VISIBILITY_VISIBLE,
      );

      if (upgradeId != null) {
        // Listen to download progress
        RUpgrade.stream.listen((DownloadInfo info) {
          if (info.id == upgradeId) {
            double progress = (info.percent ?? 0) / 100;
            downloadProgress.value = progress;

            if (info.status == DownloadStatus.STATUS_SUCCESSFUL) {
              downloadStatus.value = 'Download complete! Installing...';

              // Close progress dialog after a short delay
              Future.delayed(const Duration(milliseconds: 500), () {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              });

              // Clean up: APK will be deleted by system after install
            } else if (info.status == DownloadStatus.STATUS_FAILED) {
              downloadStatus.value = 'Download failed';

              // Show error
              Future.delayed(const Duration(milliseconds: 500), () {
                if (context.mounted) {
                  Navigator.pop(context);
                  showPremiumErrorDialog(
                    context,
                    title: 'Download Failed',
                    message: 'Could not download update. Please check your internet connection.',
                    icon: Icons.error_rounded,
                  );
                }
              });
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error downloading/installing update: $e');

      if (context.mounted) {
        Navigator.pop(context); // Close progress dialog
        await showPremiumErrorDialog(
          context,
          title: 'Update Failed',
          message: 'Could not install update. Please try again later.',
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
}
