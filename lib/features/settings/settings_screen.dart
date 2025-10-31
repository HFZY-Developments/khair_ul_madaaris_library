import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/premium_dialogs.dart';
import '../../providers/app_state_provider.dart';
import '../../services/google_sheets_service.dart';
import '../donation/donation_screen.dart';
import '../../services/app_update_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isAdmin = ref.watch(adminModeProvider);
    final connectionStatus = ref.watch(sheetsConnectionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text('Settings', style: TextStyle(fontSize: 18.sp)),
            Text(
              'Customize Your Experience',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 16.h),

            // Appearance Section
            _buildEnhancedSection(
              context: context,
              isDark: isDark,
              title: 'APPEARANCE',
              icon: Icons.palette_rounded,
              children: [
                _buildAnimatedToggleTile(
                  context: context,
                  isDark: isDark,
                  title: 'Dark Mode',
                  subtitle: themeMode == ThemeMode.dark
                      ? 'Dark theme active'
                      : 'Light theme active',
                  icon: themeMode == ThemeMode.dark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  value: themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
              ],
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),

            SizedBox(height: 16.h),

            // Account Section
            _buildEnhancedSection(
                  context: context,
                  isDark: isDark,
                  title: 'ACCOUNT',
                  icon: Icons.person_rounded,
                  children: [
                    connectionStatus.when(
                      data: (connected) => _buildPremiumTile(
                        context: context,
                        isDark: isDark,
                        title: 'Google Sheets',
                        subtitle: connected
                            ? 'Connected & synced'
                            : 'Disconnected',
                        icon: Icons.cloud_rounded,
                        trailing: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (connected
                                        ? AppColors.statusAvailable
                                        : AppColors.statusOverdue)
                                    .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: connected
                                  ? AppColors.statusAvailable
                                  : AppColors.statusOverdue,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                connected
                                    ? Icons.check_circle_rounded
                                    : Icons.error_rounded,
                                color: connected
                                    ? AppColors.statusAvailable
                                    : AppColors.statusOverdue,
                                size: 16.sp,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                connected ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: connected
                                      ? AppColors.statusAvailable
                                      : AppColors.statusOverdue,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: null,
                      ),
                      loading: () => _buildPremiumTile(
                        context: context,
                        isDark: isDark,
                        title: 'Google Sheets',
                        subtitle: 'Checking connection...',
                        icon: Icons.cloud_rounded,
                        trailing: SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        onTap: null,
                      ),
                      error: (_, __) => _buildPremiumTile(
                        context: context,
                        isDark: isDark,
                        title: 'Google Sheets',
                        subtitle: 'Connection error',
                        icon: Icons.cloud_off_rounded,
                        trailing: Icon(
                          Icons.error_rounded,
                          color: AppColors.statusOverdue,
                        ),
                        onTap: null,
                      ),
                    ),
                    _buildPremiumTile(
                      context: context,
                      isDark: isDark,
                      title: 'Sign Out',
                      subtitle: 'Log out of your account',
                      icon: Icons.logout_rounded,
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16.sp,
                      ),
                      onTap: () => _showSignOutDialog(context, ref),
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 100.ms)
                .slideY(begin: 0.1, end: 0),

            SizedBox(height: 16.h),

            // Admin Section
            if (isAdmin)
              _buildEnhancedSection(
                    context: context,
                    isDark: isDark,
                    title: 'ADMIN',
                    icon: Icons.admin_panel_settings_rounded,
                    children: [
                      _buildPremiumTile(
                        context: context,
                        isDark: isDark,
                        title: 'Change Password',
                        subtitle: 'Update admin password',
                        icon: Icons.lock_rounded,
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16.sp,
                        ),
                        onTap: () => _showChangePasswordDialog(context, ref),
                      ),
                    ],
                  )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0),

            if (isAdmin) SizedBox(height: 16.h),

            // Support Section
            _buildEnhancedSection(
                  context: context,
                  isDark: isDark,
                  title: 'SUPPORT',
                  icon: Icons.help_rounded,
                  children: [
                    _buildPremiumTile(
                      context: context,
                      isDark: isDark,
                      title: 'Contact Support',
                      subtitle: AppConstants.helpEmail,
                      icon: Icons.email_rounded,
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16.sp,
                      ),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _launchURL('mailto:${AppConstants.helpEmail}');
                      },
                    ),
                    _buildPremiumTile(
                      context: context,
                      isDark: isDark,
                      title: 'Donate to Developer',
                      subtitle: 'Support free app development',
                      icon: Icons.favorite_rounded,
                      iconColor: Colors.red,
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16.sp,
                      ),
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DonationScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: isAdmin ? 300.ms : 200.ms)
                .slideY(begin: 0.1, end: 0),

            SizedBox(height: 16.h),

            // About Section
            _buildEnhancedSection(
                  context: context,
                  isDark: isDark,
                  title: 'ABOUT',
                  icon: Icons.info_rounded,
                  children: [
                    _buildPremiumTile(
                      context: context,
                      isDark: isDark,
                      title: AppConstants.appName,
                      subtitle: 'Version 1.0.1',
                      icon: Icons.apps_rounded,
                      trailing: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'v1.0.1',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      onTap: null,
                    ),
                    _buildPremiumTile(
                      context: context,
                      isDark: isDark,
                      title: 'Check for Updates',
                      subtitle: 'Download the latest version',
                      icon: Icons.system_update_rounded,
                      iconColor: AppColors.primaryTeal,
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16.sp,
                      ),
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        AppUpdateService.checkForUpdatesManual(context);
                      },
                    ),
                    _buildPremiumTile(
                      context: context,
                      isDark: isDark,
                      title: 'Developer',
                      subtitle: AppConstants.developerName,
                      icon: Icons.code_rounded,
                      trailing: Icon(Icons.chevron_right_rounded, size: 16.sp),
                      onTap: null,
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: isAdmin ? 400.ms : 300.ms)
                .slideY(begin: 0.1, end: 0),

            SizedBox(height: 32.h),

            // Footer
            Text(
              'Made with dedication for ${AppConstants.appName}',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11.sp,
                fontStyle: FontStyle.italic,
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 600.ms),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedSection({
    required BuildContext context,
    required bool isDark,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey[300]!).withValues(
              alpha: 0.3,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18.sp),
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.primaryTeal,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.grey[800] : Colors.grey[200],
          ),
          // Children
          ...children,
        ],
      ),
    );
  }

  Widget _buildPremiumTile({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    Color? iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primaryTeal).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.primaryTeal,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[SizedBox(width: 12.w), trailing],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedToggleTile({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppColors.primaryTeal, size: 22.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primaryTeal,
              activeTrackColor: AppColors.primaryTeal.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSignOutDialog(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Theme.of(context).dialogBackgroundColor,
                        Theme.of(context).dialogBackgroundColor,
                      ]
                    : [Colors.white, Colors.grey[50]!],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange[400]!, Colors.red[400]!],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 48.sp,
                  ),
                ),
                SizedBox(height: 24.h),

                // Title
                Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 12.h),

                // Message
                Text(
                  'Are you sure you want to sign out?\n\nYou will need to sign in again to access your library.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32.h),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      await GoogleSheetsService.instance.signOut();
      await ref.read(currentUserProvider.notifier).clearUser();
      await ref.read(adminModeProvider.notifier).setAdminMode(false);
    }
  }

  Future<void> _showChangePasswordDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    HapticFeedback.mediumImpact();
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(28.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_rounded,
                        color: Colors.white,
                        size: 28.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 28.h),

                // Form fields
                TextField(
                  controller: currentController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Current Password *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: newController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    prefixIcon: const Icon(Icons.lock_reset_rounded),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    prefixIcon: const Icon(Icons.check_circle_outline_rounded),
                  ),
                ),
                SizedBox(height: 28.h),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    ElevatedButton(
                      onPressed: () async {
                        if (newController.text != confirmController.text) {
                          await showPremiumErrorDialog(
                            dialogContext,
                            title: 'Validation Error',
                            message: 'New passwords do not match.',
                            icon: Icons.warning_rounded,
                          );
                          return;
                        }

                        if (newController.text.length < 4) {
                          await showPremiumErrorDialog(
                            dialogContext,
                            title: 'Validation Error',
                            message:
                                'Password must be at least 4 characters long.',
                            icon: Icons.warning_rounded,
                          );
                          return;
                        }

                        final verified = await ref
                            .read(adminModeProvider.notifier)
                            .verifyAdminPassword(currentController.text);

                        if (!verified) {
                          if (!context.mounted) return;
                          await showPremiumErrorDialog(
                            dialogContext,
                            title: 'Incorrect Password',
                            message: 'Current password is incorrect.',
                            icon: Icons.error_rounded,
                          );
                          return;
                        }

                        await ref
                            .read(adminModeProvider.notifier)
                            .updateAdminPassword(newController.text);

                        if (!context.mounted) return;
                        Navigator.pop(dialogContext);

                        await showPremiumSuccessDialog(
                          context,
                          title: 'Password Updated!',
                          message:
                              'Your admin password has been changed successfully.',
                          icon: Icons.check_circle_rounded,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 28.w,
                          vertical: 14.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Update Password',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
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
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
