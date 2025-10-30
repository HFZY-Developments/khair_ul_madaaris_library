import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/debounced_button.dart';
import '../../core/widgets/premium_dialogs.dart';
import '../../models/book.dart';
import '../../providers/app_state_provider.dart';
import '../../services/google_sheets_service.dart';
import '../scanner/qr_scanner_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../settings/settings_screen.dart';
import '../donation/donation_screen.dart';
import '../../services/app_update_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000), // Slower overall - 6 seconds per cycle
    )..repeat();

    _fadeAnimation = TweenSequence<double>([
      // Show "Khair-ul-Madaaris" - Hold longer
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 35, // Hold for 2.1s
      ),
      // Gentle fade to "Library" - Much slower transition
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 15, // Slow fade for 0.9s
      ),
      // Show "Library" - Hold longer
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.0),
        weight: 35, // Hold for 2.1s
      ),
      // Gentle fade back to "Khair-ul-Madaaris" - Much slower transition
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 15, // Slow fade for 0.9s
      ),
    ]).animate(_fadeController);

    // Check for app updates in background (non-blocking)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppUpdateService.checkForUpdatesBackground(context);
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(adminModeProvider);
    final connectionStatus = ref.watch(sheetsConnectionProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        toolbarHeight: () {
          final screenWidth = MediaQuery.of(context).size.width;
          const double refWidth = 428.0;
          final double scale = (screenWidth / refWidth).clamp(0.75, 2.5);
          return (56.0 * scale).clamp(56.0, 80.0);  // Scale toolbar height
        }(),
        title: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            const double refWidth = 428.0;
            final double scale = (screenWidth / refWidth).clamp(0.75, 2.5);

            // Use fluid scaling for title text
            final arabicFontSize = (12.0 * scale).clamp(10.0, 18.0);
            final leftPadding = (8.0 * scale).clamp(4.0, 12.0);

            return Padding(
              padding: EdgeInsets.only(left: leftPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated scrolling title with proper overflow handling
                  _buildMarqueeTitle(),
                  SizedBox(height: 2.0),
                  Text(
                    AppConstants.appNameArabic,
                    style: TextStyle(fontSize: arabicFontSize, fontWeight: FontWeight.w400),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            );
          },
        ),
        actions: () {
          final screenWidth = MediaQuery.of(context).size.width;
          const double refWidth = 428.0;
          final double scale = (screenWidth / refWidth).clamp(0.75, 2.5);
          final iconSize = (24.0 * scale).clamp(20.0, 32.0);
          final spacing = (4.0 * scale).clamp(2.0, 10.0);

          return [
            // Theme toggle
            IconButton(
              iconSize: iconSize,
              icon: Icon(Theme.of(context).brightness == Brightness.light
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded),
              onPressed: () {
                HapticFeedback.mediumImpact();
                ref.read(themeModeProvider.notifier).toggleTheme(context);
              },
            ),
            // Donation button
            IconButton(
              iconSize: iconSize,
              icon: Icon(Icons.favorite_rounded, color: Colors.red[400]),
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DonationScreen()),
                );
              },
            ),
            // Admin mode toggle
            IconButton(
              iconSize: iconSize,
              icon: Icon(isAdmin ? Icons.admin_panel_settings : Icons.lock_outline),
              color: isAdmin ? AppColors.primaryLime : null,
              onPressed: () => _toggleAdminMode(context),
            ),
            // Settings
            IconButton(
              iconSize: iconSize,
              icon: const Icon(Icons.settings_rounded),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
            SizedBox(width: spacing),
          ];
        }(),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // FLUID SCALE FACTOR for ALL body dimensions
            final screenWidth = constraints.maxWidth;
            final screenHeight = MediaQuery.of(context).size.height;
            const double refWidth = 428.0;
            final double scale = (screenWidth / refWidth).clamp(0.75, 2.5);

            // All dimensions now use fluid scaling!
            final horizontalPadding = (24.0 * scale).clamp(16.0, 36.0);
            final verticalSpacing = (24.0 * scale).clamp(16.0, 32.0);
            final logoSpacing = (32.0 * scale).clamp(24.0, 44.0);

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: (16.0 * scale).clamp(12.0, 24.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Connection Status
                  connectionStatus.when(
                    data: (connected) => _buildConnectionBanner(connected),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  SizedBox(height: verticalSpacing),

                  // Actual Logo - Fluid responsive scaling
                  Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // FLUID SCALE FACTOR (same as button)
                        const double referenceWidth = 428.0;
                        final double scaleWidth = screenWidth / referenceWidth;
                        final double scaleHeight = screenHeight / 926.0;
                        final double scaleFactor = (scaleWidth < scaleHeight ? scaleWidth : scaleHeight).clamp(0.75, 2.5);

                        // Base dimensions from Xiaomi 12S Ultra design
                        final logoSize = (170.0 * scaleFactor).clamp(110.0, 320.0);
                        final logoPadding = 22.0 * scaleFactor;
                        final glowBlur = 50.0 * scaleFactor;
                        final glowSpread = 10.0 * scaleFactor;
                        final borderRad = 35.0 * scaleFactor;

                        return Container(
                          width: logoSize,
                          height: logoSize,
                          padding: EdgeInsets.all(logoPadding),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(borderRad),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryTeal.withValues(alpha: 0.25),
                                blurRadius: glowBlur,
                                spreadRadius: glowSpread,
                                offset: const Offset(0, 12),
                              ),
                              BoxShadow(
                                color: AppColors.primaryLime.withValues(alpha: 0.2),
                                blurRadius: glowBlur + 20,
                                spreadRadius: 0,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ).animate().scale(curve: Curves.elasticOut, duration: 800.ms);
                      },
                    ),
                  ),

                  SizedBox(height: logoSpacing),

                  // Mode indicator (No emojis - Professional icons)
                  Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Use same fluid scale factor
                        const double refWidth = 428.0;
                        final double scale = (screenWidth / refWidth).clamp(0.75, 2.5);

                        // Base dimensions from Xiaomi 12S Ultra design
                        final buttonPadding = EdgeInsets.symmetric(
                          horizontal: (24.0 * scale).clamp(16.0, 40.0),
                          vertical: (12.0 * scale).clamp(8.0, 18.0),
                        );
                        final iconSize = (20.0 * scale).clamp(16.0, 28.0);
                        final fontSize = (18.0 * scale).clamp(14.0, 26.0);
                        final spacing = (10.0 * scale).clamp(6.0, 16.0);
                        final borderRadius = (24.0 * scale).clamp(18.0, 36.0);
                        final shadowBlur = (14.0 * scale).clamp(10.0, 22.0);

                        return Container(
                          padding: buttonPadding,
                          decoration: BoxDecoration(
                            gradient: isAdmin ? AppColors.limeGradient : AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(borderRadius),
                            boxShadow: [
                              BoxShadow(
                                color: (isAdmin ? AppColors.primaryLime : AppColors.primaryTeal).withValues(alpha: 0.3),
                                blurRadius: shadowBlur,
                                offset: Offset(0, (5.0 * scale).clamp(4.0, 8.0)),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isAdmin ? Icons.shield_rounded : Icons.person_rounded,
                                color: isAdmin ? AppColors.primaryDarkBlue : Colors.white,
                                size: iconSize,
                              ),
                              SizedBox(width: spacing),
                              Text(
                                isAdmin ? 'Admin Mode' : 'User Mode',
                                style: TextStyle(
                                  color: isAdmin ? AppColors.primaryDarkBlue : Colors.white,
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 300.ms).scale(curve: Curves.elasticOut, duration: 600.ms);
                      },
                    ),
                  ),

                  SizedBox(height: screenHeight < 700 ? 32.h : 40.h),

                  // UNIFIED SMART SCANNER BUTTON (Replaces 3 redundant buttons)
                  // Stream now emits initial value immediately, so no loading state
                  connectionStatus.when(
                    data: (connected) => _buildSmartScannerButton(isAdmin, connected),
                    loading: () => _buildSmartScannerButton(isAdmin, false), // Should never happen now
                    error: (_, __) => _buildSmartScannerButton(isAdmin, false),
                  ),

                  SizedBox(height: verticalSpacing),

                  // Admin Dashboard Button (Admin Mode Only)
                  if (isAdmin) ...[
                    DebouncedOutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primaryLime, width: 2),
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.dashboard_rounded, color: AppColors.primaryLime, size: 24.sp),
                          SizedBox(width: 12.w),
                          Text(
                            'Admin Dashboard',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryLime,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                    SizedBox(height: verticalSpacing),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Fade Title - Animated fade transition between "Khair-ul-Madaaris" and "Library"
  Widget _buildMarqueeTitle() {
    final screenWidth = MediaQuery.of(context).size.width;
    const double refWidth = 428.0;
    final double scale = (screenWidth / refWidth).clamp(0.75, 2.5);

    // Use fluid scaling
    final fontSize = (18.0 * scale).clamp(14.0, 26.0);
    final height = (24.0 * scale).clamp(20.0, 32.0);
    final letterSpacing = (0.3 * scale).clamp(0.1, 0.5);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          final textStyle = TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: letterSpacing,
          );

          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              // "Khair-ul-Madaaris" - fades out
              Opacity(
                opacity: _fadeAnimation.value,
                child: Text(
                  'Khair-ul-Madaaris',
                  style: textStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // "Library" - fades in
              Opacity(
                opacity: 1.0 - _fadeAnimation.value,
                child: Text(
                  'Library',
                  style: textStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Smart Scanner Button - Fluid responsive scaling for ALL screen sizes
  Widget _buildSmartScannerButton(bool isAdmin, bool connectionStatus) {
    // Get actual screen dimensions
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // FLUID SCALE FACTOR SYSTEM - Works on EVERY screen size!
    // Reference design: Xiaomi 12S Ultra (428px width, ~926px height)
    const double referenceWidth = 428.0;
    const double referenceHeight = 926.0;

    // Calculate scale factors for width and height separately
    final double scaleWidth = screenWidth / referenceWidth;
    final double scaleHeight = screenHeight / referenceHeight;

    // Use the SMALLER scale factor to maintain proportions and prevent overflow
    final double scaleFactor = scaleWidth < scaleHeight ? scaleWidth : scaleHeight;

    // Clamp scale factor to reasonable limits (0.75x to 2.5x)
    final double clampedScale = scaleFactor.clamp(0.75, 2.5);

    // Base dimensions from your beautiful Xiaomi 12S Ultra design
    // All dimensions scale proportionally with screen size!

    // CRITICAL: Use percentage of screen height for container to prevent overflow on tall screens
    final containerHeightPercentage = screenHeight * 0.24;  // 24% of screen height
    final containerHeight = containerHeightPercentage.clamp(140.0, 280.0);  // But limit extremes

    final containerPadding = (28.0 * clampedScale).clamp(16.0, 40.0);
    final iconPadding = (18.0 * clampedScale).clamp(12.0, 26.0);
    final iconSize = (44.0 * clampedScale).clamp(32.0, 60.0);
    final arrowPadding = (16.0 * clampedScale).clamp(10.0, 22.0);
    final arrowSize = (26.0 * clampedScale).clamp(20.0, 36.0);
    final titleSize = (34.0 * clampedScale).clamp(24.0, 48.0);
    final subtitleSize = (15.0 * clampedScale).clamp(11.0, 20.0);
    final titleSubtitleSpacing = (12.0 * clampedScale).clamp(6.0, 16.0);
    final borderRadius = (28.0 * clampedScale).clamp(20.0, 40.0);

    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();

        print('DEBUG SCAN: connectionStatus = $connectionStatus');

        // CRITICAL: Check if signed in before allowing scan
        if (!connectionStatus) {
          print('DEBUG SCAN: Not connected, showing error');
          await showPremiumErrorDialog(
            context,
            title: 'Sign In Required',
            message: 'Please sign in with Google to access the scanner.\n\nThis ensures all book transactions are properly tracked.',
            icon: Icons.lock_rounded,
          );
          return;
        }

        print('DEBUG SCAN: Connected, opening scanner');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QRScannerScreen(isAdmin: isAdmin),
          ),
        );
      },
      child: Container(
        height: containerHeight,
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.35,  // Allow up to 35% on larger screens
          minHeight: 140,  // Minimum height to remain usable
        ),
        padding: EdgeInsets.all(containerPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isAdmin
                ? [AppColors.primaryLime, AppColors.primaryTeal]
                : [AppColors.primaryTeal, AppColors.primaryDarkBlue],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: (isAdmin ? AppColors.primaryLime : AppColors.primaryTeal).withValues(alpha: 0.5),
              blurRadius: (35.0 * clampedScale).clamp(20.0, 50.0),
              spreadRadius: 0,
              offset: Offset(0, (12.0 * clampedScale).clamp(8.0, 18.0)),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: QR Icon + Arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated QR Code Icon
                Container(
                  padding: EdgeInsets.all(iconPadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular((20.0 * clampedScale).clamp(14.0, 28.0)),
                  ),
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    size: iconSize,
                    color: Colors.white,
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.05, 1.05),
                      duration: 1500.ms,
                      curve: Curves.easeInOut,
                    )
                    .then()
                    .scale(
                      begin: const Offset(1.05, 1.05),
                      end: const Offset(1.0, 1.0),
                      duration: 1500.ms,
                      curve: Curves.easeInOut,
                    ),

                // Arrow indicator
                Container(
                  padding: EdgeInsets.all(arrowPadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: arrowSize,
                  ),
                ),
              ],
            ),

            // Bottom Section: Title + Subtitle (Constrained with FittedBox)
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: screenWidth * 0.85),
                      child: Text(
                        'TAP TO SCAN',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: (1.5 * clampedScale).clamp(0.8, 2.0),
                          height: 1.0,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: titleSubtitleSpacing),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: screenWidth * 0.85),
                      child: Text(
                        isAdmin
                            ? 'Add Book • Checkout • Return'
                            : 'Checkout • Return • View Info',
                        style: TextStyle(
                          fontSize: subtitleSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.95),
                          letterSpacing: (0.6 * clampedScale).clamp(0.3, 1.0),
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: 200.ms, duration: 400.ms)
          .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic)
          .shimmer(delay: 800.ms, duration: 1500.ms, color: Colors.white.withValues(alpha: 0.15)),
    );
  }

  /// Quick Stats Card - Shows library-wide stats for users
  Widget _buildQuickStatsCard() {
    final booksAsync = ref.watch(booksProvider);

    return booksAsync.when(
      data: (books) {
        // Calculate library-wide stats (since we don't track borrower email, only name)
        final totalBooks = books.length;
        final availableCount = books.where((b) => b.status == BookStatus.available).length;
        final checkedOutCount = books.where((b) => b.status == BookStatus.checkedOut).length;
        final overdueCount = books.where((b) => b.isOverdue).length;

        return Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryDarkBlue.withValues(alpha: 0.1),
                AppColors.primaryTeal.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppColors.primaryTeal.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_graph_rounded, color: AppColors.primaryTeal, size: 24.sp),
                  SizedBox(width: 12.w),
                  Text(
                    'Library Quick Stats',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.check_circle_rounded,
                    label: 'Available',
                    value: availableCount.toString(),
                    color: AppColors.primaryLime,
                  ),
                  Container(
                    width: 1,
                    height: 40.h,
                    color: AppColors.primaryTeal.withValues(alpha: 0.2),
                  ),
                  _buildStatItem(
                    icon: Icons.book_rounded,
                    label: 'Borrowed',
                    value: checkedOutCount.toString(),
                    color: AppColors.primaryTeal,
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32.sp),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionBanner(bool connected) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Use same fluid scale factor system
    const double refWidth = 428.0;
    final double scale = (screenWidth / refWidth).clamp(0.75, 2.5);

    if (connected) {
      return Container(
        padding: EdgeInsets.all((12.0 * scale).clamp(10.0, 18.0)),
        decoration: BoxDecoration(
          color: AppColors.successLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular((12.0 * scale).clamp(10.0, 20.0)),
          border: Border.all(
            color: AppColors.successLight,
            width: scale > 1.2 ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cloud_done_rounded,
              color: AppColors.successLight,
              size: (24.0 * scale).clamp(20.0, 34.0),
            ),
            SizedBox(width: (12.0 * scale).clamp(10.0, 18.0)),
            Expanded(
              child: Text(
                'Connected to Google Sheets ✓',
                style: TextStyle(
                  fontSize: (14.0 * scale).clamp(12.0, 22.0),
                  color: AppColors.successLight,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
    } else {
      // Show sign-in prompt when not connected
      return Container(
        padding: EdgeInsets.all((16.0 * scale).clamp(12.0, 26.0)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryTeal.withValues(alpha: 0.1),
              AppColors.primaryLime.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular((16.0 * scale).clamp(14.0, 28.0)),
          border: Border.all(
            color: AppColors.primaryTeal.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  color: AppColors.warningLight,
                  size: (24.0 * scale).clamp(20.0, 34.0),
                ),
                SizedBox(width: (12.0 * scale).clamp(10.0, 18.0)),
                Expanded(
                  child: Text(
                    'Sign in to access library',
                    style: TextStyle(
                      fontSize: (16.0 * scale).clamp(14.0, 24.0),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: (12.0 * scale).clamp(10.0, 18.0)),
            SizedBox(
              width: double.infinity,  // CRITICAL: Make button take full width!
              child: GradientButton(
                text: 'Sign In with Google',
                icon: Icons.login_rounded,
                height: (56.0 * scale).clamp(52.0, 72.0),
                fontSize: (16.0 * scale).clamp(14.0, 22.0),
                onPressed: () async {
                // Show loading dialog
                showPremiumLoadingDialog(context, message: 'Signing in with Google...');

                try {
                  final success = await GoogleSheetsService.instance.signIn();

                  // Dismiss loading dialog
                  if (mounted) Navigator.pop(context);

                  if (!mounted) return;

                  if (success) {
                    // Refresh connection status to update UI
                    ref.invalidate(sheetsConnectionProvider);

                    // Show success dialog directly (no checkmark animation for sign-in)
                    await showPremiumSuccessDialog(
                      context,
                      title: 'Welcome!',
                      message: 'Successfully connected to Google Sheets.\n\nYou can now access the library system.',
                      icon: Icons.cloud_done_rounded,
                      onPrimaryPressed: () {
                        // Dialog will auto-close via Navigator.pop in the dialog itself
                        // No additional navigation needed
                      },
                    );
                  } else {
                    // Sign-in failed
                    await showPremiumErrorDialog(
                      context,
                      title: 'Sign-In Failed',
                      message: 'Could not connect to Google.\n\nPlease check:\n• Internet connection\n• Google account permissions\n• OAuth configuration',
                      icon: Icons.error_rounded,
                    );
                  }
                } catch (e) {
                  // Dismiss loading if showing
                  if (mounted && Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }

                  if (!mounted) return;

                  // Check if it's a network error
                  final isOfflineError = e.toString().contains('NO_INTERNET');

                  // Show elegant error message
                  await showPremiumErrorDialog(
                    context,
                    title: isOfflineError ? 'No Internet Connection' : 'Sign-In Error',
                    message: isOfflineError
                        ? 'Unable to connect to Google.\n\nPlease check your internet connection and try again.'
                        : 'An error occurred during sign-in:\n\n${e.toString()}\n\nPlease check:\n• Internet connection\n• Google account permissions',
                    icon: isOfflineError ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                  );
                }
              },
            ),
            ),  // Close SizedBox wrapper
          ],
        ),
      ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1, end: 0).shake(delay: 300.ms, hz: 2, duration: 400.ms);
    }
  }

  Future<void> _toggleAdminMode(BuildContext dialogContext) async {
    final isAdmin = ref.read(adminModeProvider);

    if (isAdmin) {
      // Turn off admin mode
      await ref.read(adminModeProvider.notifier).setAdminMode(false);
    } else {
      // Show password dialog
      final password = await showDialog<String>(
        context: dialogContext,
        builder: (context) => _AdminPasswordDialog(),
      );

      if (password == null) return;

      final verified = await ref.read(adminModeProvider.notifier).verifyAdminPassword(password);

      if (!dialogContext.mounted) return;

      if (verified) {
        await ref.read(adminModeProvider.notifier).setAdminMode(true);
        if (dialogContext.mounted) {
          ScaffoldMessenger.of(dialogContext).showSnackBar(
            const SnackBar(content: Text('Admin mode activated')),
          );
        }
      } else {
        if (dialogContext.mounted) {
          ScaffoldMessenger.of(dialogContext).showSnackBar(
            const SnackBar(
              content: Text('Incorrect password'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _AdminPasswordDialog extends StatefulWidget {
  @override
  State<_AdminPasswordDialog> createState() => _AdminPasswordDialogState();
}

class _AdminPasswordDialogState extends State<_AdminPasswordDialog> {
  final _controller = TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Admin Password'),
      content: TextField(
        controller: _controller,
        obscureText: _obscureText,
        decoration: InputDecoration(
          hintText: 'Password',
          suffixIcon: IconButton(
            icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscureText = !_obscureText),
          ),
        ),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Verify'),
        ),
      ],
    );
  }
}

