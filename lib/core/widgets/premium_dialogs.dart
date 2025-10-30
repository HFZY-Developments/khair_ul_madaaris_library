import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

/// Premium Success Dialog (Turffontein-style)
Future<void> showPremiumSuccessDialog(
  BuildContext context, {
  required String title,
  required String message,
  required IconData icon,
  String primaryButtonText = 'Done',
  String? secondaryButtonText,
  VoidCallback? onPrimaryPressed,
  VoidCallback? onSecondaryPressed,
}) async {
  // Heavy haptic feedback for success
  HapticFeedback.heavyImpact();

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      // Responsive padding based on screen size
      final dialogPadding = screenWidth < 360 ? 16.w : (screenWidth < 600 ? 24.w : 32.w);

      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r),
        ),
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.9,
            maxHeight: screenHeight * 0.85,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(dialogPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Theme.of(context).dialogBackgroundColor,
                      Colors.green.shade900.withValues(alpha: 0.3),
                    ]
                  : [
                      Colors.white,
                      Colors.green.shade50,
                    ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon with Animation
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 64.sp,
                  color: Colors.white,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.0, 0.0),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .then()
                  .shimmer(duration: 1200.ms),

              SizedBox(height: 28.h),

              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 500.ms)
                  .slideY(begin: 0.3, end: 0),

              SizedBox(height: 12.h),

              // Message
              SelectableText(
                message,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 500.ms),

              SizedBox(height: 32.h),

              // Action Buttons
              Row(
                children: [
                  if (secondaryButtonText != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                          onSecondaryPressed?.call();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          side: BorderSide(
                            color: Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          secondaryButtonText,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                  ],
                  Expanded(
                    flex: secondaryButtonText != null ? 2 : 1,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                        onPrimaryPressed?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        backgroundColor: Colors.green.shade600,
                        elevation: 3,
                      ),
                      child: Text(
                        primaryButtonText,
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
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// Premium Error Dialog
Future<void> showPremiumErrorDialog(
  BuildContext context, {
  required String title,
  required String message,
  required IconData icon,
  String buttonText = 'OK',
  VoidCallback? onPressed,
}) async {
  HapticFeedback.mediumImpact();

  return showDialog(
    context: context,
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      // Responsive padding based on screen size
      final dialogPadding = screenWidth < 360 ? 16.w : (screenWidth < 600 ? 24.w : 32.w);

      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r),
        ),
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.9,
            maxHeight: screenHeight * 0.85,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(dialogPadding),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28.r),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Theme.of(context).dialogBackgroundColor,
                          Colors.red.shade900.withValues(alpha: 0.3),
                        ]
                      : [
                          Colors.white,
                          Colors.red.shade50,
                        ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Error Icon
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade600, Colors.red.shade800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 48.sp,
                    ),
                  )
                      .animate()
                      .shake(duration: 500.ms, hz: 4)
                      .scale(duration: 300.ms, curve: Curves.easeOutCubic),

                  SizedBox(height: 28.h),

                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.visible,
                  ),

                  SizedBox(height: 12.h),

                  // Message (with proper wrapping for long error text)
                  SelectableText(
                    message,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 32.h),

                  // OK Button
                  ElevatedButton(
                    onPressed: onPressed ?? () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(buttonText, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// Premium Loading Dialog
void showPremiumLoadingDialog(BuildContext context, {required String message}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;

      // Responsive padding
      final dialogPadding = screenWidth < 360 ? 20.w : (screenWidth < 600 ? 28.w : 32.w);

      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.85,
          ),
          child: Container(
            padding: EdgeInsets.all(dialogPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 60.w,
                  height: 60.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryTeal,
                    ),
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 1500.ms),

                SizedBox(height: 24.h),

                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Scan Success Animation (Instant Feedback)
Future<void> showScanSuccessAnimation(BuildContext context) async {
  HapticFeedback.mediumImpact();

  await showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    builder: (context) {
      return Center(
        child: Container(
          width: 140.w,
          height: 140.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryTeal, AppColors.primaryLime],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryTeal.withValues(alpha: 0.6),
                blurRadius: 50,
                spreadRadius: 15,
              ),
            ],
          ),
          child: Icon(
            Icons.check_circle,
            size: 70.sp,
            color: Colors.white,
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.0, 0.0),
              end: const Offset(1.3, 1.3),
              duration: 350.ms,
              curve: Curves.elasticOut,
            )
            .then()
            .scale(
              begin: const Offset(1.3, 1.3),
              end: const Offset(1.0, 1.0),
              duration: 200.ms,
            ),
      );
    },
  );

  // Auto-dismiss after animation
  await Future.delayed(const Duration(milliseconds: 650));
  if (context.mounted) {
    Navigator.pop(context);
  }
}
