import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_button.dart';
import '../../services/app_update_service.dart';

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
      child: Container(
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
            color: isDark
                ? AppColors.primaryTeal.withOpacity(0.3)
                : AppColors.primaryTeal.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTeal.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
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
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryTeal,
                        AppColors.primaryLime,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryTeal.withOpacity(0.5),
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
                    .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),

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
                        AppColors.primaryTeal.withOpacity(0.2),
                        AppColors.primaryLime.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColors.primaryTeal.withOpacity(0.5),
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

                // Changelog section
                if (changelog.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: 200.h,
                    ),
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.article_rounded,
                              color: AppColors.primaryTeal,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'What\'s New',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.primaryDarkBlue,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: changelog.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(top: 6.h),
                                      width: 6.w,
                                      height: 6.h,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryTeal,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Text(
                                        changelog[index],
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: -0.2, end: 0);
                            },
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  SizedBox(height: 20.h),
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

                // Download button
                GradientButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context); // Close this dialog
                    AppUpdateService.downloadAndInstall(context, updateInfo);
                  },
                  text: 'DOWNLOAD UPDATE',
                  icon: Icons.download_rounded,
                ),

                SizedBox(height: 12.h),

                // Important note
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_rounded,
                        color: Colors.orange,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Update required to continue using the app',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
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
