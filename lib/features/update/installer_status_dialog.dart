import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import 'liquid_background.dart';

/// Dialog shown while installer is open - detects when user comes back
class InstallingDialog extends StatefulWidget {
  final Map<String, dynamic> updateInfo;

  const InstallingDialog({
    super.key,
    required this.updateInfo,
  });

  @override
  State<InstallingDialog> createState() => _InstallingDialogState();
}

class _InstallingDialogState extends State<InstallingDialog> with WidgetsBindingObserver {
  bool _hasDetectedReturn = false;
  bool _appWentToBackground = false;
  bool _isWaitingForInstaller = true;
  bool _installationFailed = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🟢 InstallingDialog: initState - Adding lifecycle observer');
    WidgetsBinding.instance.addObserver(this);

    // Mark that we're ready to detect lifecycle changes
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isWaitingForInstaller = true;
        });
        debugPrint('🟢 InstallingDialog: Ready to detect lifecycle changes');
      }
    });

    // Safety timeout - if user is still here after 60 seconds, something went wrong
    Future.delayed(const Duration(seconds: 60), () {
      if (mounted && !_hasDetectedReturn) {
        debugPrint('⚠️ InstallingDialog: Timeout reached - assuming user cancelled');
        _showCancellationError();
      }
    });
  }

  @override
  void dispose() {
    debugPrint('🔴 InstallingDialog: dispose - Removing lifecycle observer');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📱 APP LIFECYCLE CHANGED: $state');
    debugPrint('   _appWentToBackground: $_appWentToBackground');
    debugPrint('   _hasDetectedReturn: $_hasDetectedReturn');
    debugPrint('   _isWaitingForInstaller: $_isWaitingForInstaller');
    debugPrint('   mounted: $mounted');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // Detect when app goes to background (user opened installer)
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      debugPrint('📤 App went to background - installer likely opened');
      _appWentToBackground = true;
    }

    // Detect when app comes back to foreground (user cancelled or finished)
    if (state == AppLifecycleState.resumed &&
        _appWentToBackground &&
        _isWaitingForInstaller &&
        !_hasDetectedReturn) {

      debugPrint('📥 App came back to foreground!');
      debugPrint('✅ User returned from installer - likely cancelled installation');

      _showCancellationError();
    }
  }

  void _showCancellationError() {
    if (_hasDetectedReturn) {
      debugPrint('⚠️ Already shown error, skipping');
      return;
    }

    _hasDetectedReturn = true;
    debugPrint('🚨 Showing installation failed state');

    // User came back from installer - they either installed or cancelled
    // If they installed, app would restart (we wouldn't be here)
    // So they must have cancelled
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _installationFailed = true;
        });
        debugPrint('✅ Updated UI to show Installation Failed with Try Again button');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: _installationFailed,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28.r),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(
                color: _installationFailed
                    ? Colors.red.withValues(alpha: 0.4)
                    : AppColors.primaryTeal.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: LiquidBackground(
              isDark: isDark,
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: _installationFailed
                    ? _buildFailedState(context, isDark)
                    : _buildInstallingState(context, isDark),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstallingState(BuildContext context, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.primaryTeal, AppColors.primaryLime],
            ),
          ),
          child: Icon(
            Icons.system_update_alt_rounded,
            size: 40.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Installing Update',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.primaryDarkBlue,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Please complete the installation in the system installer',
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24.h),
        CircularProgressIndicator(
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
          strokeWidth: 3.w,
        ),
      ],
    );
  }

  Widget _buildFailedState(BuildContext context, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.red.shade400,
                Colors.red.shade600,
              ],
            ),
          ),
          child: Icon(
            Icons.error_outline_rounded,
            size: 40.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Installation Failed',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.primaryDarkBlue,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'The update was not installed. Please try again.',
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Return false = cancelled
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  side: BorderSide(
                    color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Return true = retry requested
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  backgroundColor: AppColors.primaryTeal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// InstallationStatusDialog removed - no longer needed
// User cancellation is now detected automatically
