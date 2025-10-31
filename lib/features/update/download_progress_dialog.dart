import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../services/app_update_service.dart';
import 'liquid_background.dart';

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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28.r),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(
                color: isDark
                    ? AppColors.primaryTeal.withValues(alpha: 0.4)
                    : AppColors.primaryTeal.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryTeal.withValues(alpha: 0.4),
                  blurRadius: 40,
                  spreadRadius: 2,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: AppColors.primaryLime.withValues(alpha: 0.2),
                  blurRadius: 25,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: LiquidBackground(
              isDark: isDark,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 36.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
              // Animated downloading icon
              Container(
                width: 90.w,
                height: 90.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryTeal,
                      AppColors.primaryLime,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryTeal.withValues(alpha: 0.5),
                      blurRadius: 35,
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: AppColors.primaryLime.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.downloading_rounded,
                  size: 44.sp,
                  color: Colors.white,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .rotate(duration: 2000.ms),

              SizedBox(height: 28.h),

              // Title
              Text(
                'Downloading Update',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.primaryDarkBlue,
                  letterSpacing: 0.3,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),

              SizedBox(height: 28.h),

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
                            width: 110.w,
                            height: 110.w,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 10.w,
                              strokeCap: StrokeCap.round,
                              backgroundColor: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryTeal,
                              ),
                            ),
                          ),
                          // Inner circle with gradient
                          Container(
                            width: 90.w,
                            height: 90.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryTeal.withValues(alpha: 0.1),
                                  AppColors.primaryLime.withValues(alpha: 0.1),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${(progress * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w900,
                                  foreground: Paint()
                                    ..shader = const LinearGradient(
                                      colors: [
                                        AppColors.primaryTeal,
                                        AppColors.primaryLime,
                                      ],
                                    ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),

                      SizedBox(height: 28.h),

                      // Linear progress bar with enhanced styling
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryTeal.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            width: double.infinity,
                            height: 10.h,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.grey[300],
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.grey[400]!,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primaryTeal,
                                      AppColors.primaryLime,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryTeal.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
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

              SizedBox(height: 24.h),

              // Status text
              ValueListenableBuilder<String>(
                valueListenable: AppUpdateService.downloadStatus,
                builder: (context, status, child) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryTeal.withValues(alpha: 0.08),
                          AppColors.primaryLime.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.primaryTeal.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      status.isEmpty ? 'Preparing download...' : status,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        color: isDark ? Colors.white : AppColors.primaryDarkBlue,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
                },
              ),

              SizedBox(height: 22.h),

              // Info note - Enhanced premium design
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryTeal.withValues(alpha: 0.12),
                      AppColors.primaryLime.withValues(alpha: 0.12),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColors.primaryTeal.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryTeal.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryTeal,
                            AppColors.primaryLime,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryTeal.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.hourglass_empty_rounded,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Text(
                        'Please wait while we download the update',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isDark ? Colors.grey[300] : AppColors.primaryDarkBlue,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
