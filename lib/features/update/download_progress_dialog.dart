import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../services/app_update_service.dart';

/// Download progress dialog (non-cancelable)
/// Shows download progress with elegant animations
class DownloadProgressDialog extends StatelessWidget {
  const DownloadProgressDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false, // Prevents back button dismissal
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1a1a1a),
                      const Color(0xFF0f0f0f),
                    ]
                  : [
                      Colors.white,
                      Colors.grey[50]!,
                    ],
            ),
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(
              color: AppColors.primaryTeal.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryTeal.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated downloading icon
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryTeal,
                      AppColors.primaryLime,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryTeal.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.downloading_rounded,
                  size: 40.sp,
                  color: Colors.white,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .rotate(duration: 2000.ms)
                  .then()
                  .shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.3)),

              SizedBox(height: 24.h),

              // Title
              Text(
                'Downloading Update',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.primaryDarkBlue,
                ),
              ).animate().fadeIn(duration: 400.ms),

              SizedBox(height: 24.h),

              // Progress bar
              ValueListenableBuilder<double>(
                valueListenable: AppUpdateService.downloadProgress,
                builder: (context, progress, child) {
                  return Column(
                    children: [
                      // Progress indicator
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 100.w,
                            height: 100.w,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 8.w,
                              backgroundColor: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryTeal,
                              ),
                            ),
                          ),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 200.ms).scale(),

                      SizedBox(height: 24.h),

                      // Linear progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          width: double.infinity,
                          height: 8.h,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.grey[300],
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryTeal,
                                    AppColors.primaryLime,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              SizedBox(height: 20.h),

              // Status text
              ValueListenableBuilder<String>(
                valueListenable: AppUpdateService.downloadStatus,
                builder: (context, status, child) {
                  return Text(
                    status.isEmpty ? 'Preparing download...' : status,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? Colors.grey[300] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 300.ms);
                },
              ),

              SizedBox(height: 20.h),

              // Info note
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.primaryTeal.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_rounded,
                      color: AppColors.primaryTeal,
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Please wait while we download the update',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? Colors.grey[300] : AppColors.primaryDarkBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
