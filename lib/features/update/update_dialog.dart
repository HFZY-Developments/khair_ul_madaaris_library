import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../services/app_update_service.dart';
import 'liquid_background.dart';

/// Premium-themed update dialog
/// Matches the app's existing design language
class UpdateDialog extends StatelessWidget {
  final Map<String, dynamic> updateInfo;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final version = updateInfo['version'] as String? ?? 'Unknown';
    final changelog = (updateInfo['changelog'] as List?)?.cast<String>() ?? [];
    final fileSize = updateInfo['fileSize'] as String? ?? 'Unknown size';
    final releaseDate = updateInfo['releaseDate'] as String? ?? '';

    return Dialog(
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
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: LiquidBackground(
            isDark: isDark,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(28.w),
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with glow effect
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primaryTeal,
                        AppColors.primaryLime,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryTeal.withValues(alpha: 0.5),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.system_update_rounded,
                    size: 50.sp,
                    color: Colors.white,
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .scale(
                      duration: 2000.ms,
                      begin: const Offset(1, 1),
                      end: const Offset(1.05, 1.05),
                    )
                    .then()
                    .scale(
                      duration: 2000.ms,
                      begin: const Offset(1.05, 1.05),
                      end: const Offset(1, 1),
                    ),

                SizedBox(height: 24.h),

                // Title
                Text(
                  'New Update Available!',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.primaryDarkBlue,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

                SizedBox(height: 8.h),

                // Version badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryTeal.withValues(alpha: 0.2),
                        AppColors.primaryLime.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColors.primaryTeal.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.new_releases_rounded,
                        color: AppColors.primaryTeal,
                        size: 18.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Version $version',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).scale(),

                SizedBox(height: 24.h),

                // Subtitle
                Text(
                  'A new version is available with exciting improvements and bug fixes.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),

                SizedBox(height: 24.h),

                // Changelog section - No scrolling, elegant fade-in animations
                if (changelog.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                Colors.white.withValues(alpha: 0.03),
                                Colors.white.withValues(alpha: 0.08),
                              ]
                            : [
                                Colors.black.withValues(alpha: 0.02),
                                Colors.black.withValues(alpha: 0.05),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isDark
                            ? AppColors.primaryTeal.withValues(alpha: 0.2)
                            : AppColors.primaryTeal.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryTeal.withValues(alpha: 0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header with animated icon
                        Row(
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
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                            )
                                .animate(onPlay: (controller) => controller.repeat())
                                .shimmer(duration: 2000.ms, color: AppColors.primaryLime.withValues(alpha: 0.3)),
                            SizedBox(width: 12.w),
                            Text(
                              'What\'s New',
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w800,
                                foreground: Paint()
                                  ..shader = const LinearGradient(
                                    colors: [
                                      AppColors.primaryTeal,
                                      AppColors.primaryLime,
                                    ],
                                  ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.3, end: 0),
                        SizedBox(height: 18.h),
                        // Changelog items - All visible, no scrolling, staggered fade-in
                        ...List.generate(
                          changelog.length,
                          (index) => Padding(
                            padding: EdgeInsets.only(bottom: index < changelog.length - 1 ? 14.h : 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Animated gradient dot
                                Container(
                                  margin: EdgeInsets.only(top: 6.h),
                                  width: 8.w,
                                  height: 8.h,
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
                                        color: AppColors.primaryTeal.withValues(alpha: 0.4),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                )
                                    .animate(delay: (450 + index * 100).ms)
                                    .scale(begin: const Offset(0, 0), curve: Curves.elasticOut),
                                SizedBox(width: 14.w),
                                // Text with fade and slide
                                Expanded(
                                  child: Text(
                                    changelog[index],
                                    style: TextStyle(
                                      fontSize: 13.5.sp,
                                      color: isDark ? Colors.grey[200] : Colors.grey[800],
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.2,
                                    ),
                                  )
                                      .animate(delay: (450 + index * 100).ms)
                                      .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                                      .slideX(begin: -0.2, end: 0, curve: Curves.easeOut),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 22.h),
                ],

                // Info row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoChip(
                      icon: Icons.file_download_rounded,
                      label: fileSize,
                      isDark: isDark,
                    ),
                    if (releaseDate.isNotEmpty) ...[
                      SizedBox(width: 12.w),
                      _buildInfoChip(
                        icon: Icons.calendar_today_rounded,
                        label: releaseDate,
                        isDark: isDark,
                      ),
                    ],
                  ],
                ).animate().fadeIn(delay: 500.ms),

                SizedBox(height: 28.h),

                // Download button - Enhanced with better text handling
                Container(
                  width: double.infinity,
                  height: 56.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primaryTeal,
                        AppColors.primaryLime,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryTeal.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: AppColors.primaryLime.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        HapticFeedback.mediumImpact();
                        // Don't close this dialog yet - let download service handle navigation
                        await AppUpdateService.downloadAndInstall(context, updateInfo);
                        // Close update dialog after download completes/fails
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      borderRadius: BorderRadius.circular(16.r),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.download_rounded,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                          SizedBox(width: 12.w),
                          Flexible(
                            child: Text(
                              'Download Update',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 600.ms)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),

                SizedBox(height: 16.h),

                // Important note - Enhanced with glassmorphism
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withValues(alpha: 0.15),
                        Colors.deepOrange.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.2),
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
                          color: Colors.orange.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.priority_high_rounded,
                          color: Colors.orange,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Text(
                          'Update required to continue using the app',
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: AppColors.primaryTeal),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
