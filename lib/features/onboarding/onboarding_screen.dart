import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/gradient_button.dart';
import '../../providers/app_state_provider.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.qr_code_scanner_rounded,
      title: 'Instant QR Scanning',
      description: 'Scan any book\'s QR code to checkout, return, or view book details with instant feedback and beautiful animations',
      gradient: AppColors.primaryGradient,
    ),
    OnboardingPage(
      icon: Icons.library_books_rounded,
      title: 'Smart Library System',
      description: 'Seamlessly track all library books, view availability in real-time, and manage checkouts with automatic 14-day due dates',
      gradient: AppColors.limeGradient,
    ),
    OnboardingPage(
      icon: Icons.admin_panel_settings_rounded,
      title: 'Powerful Admin Dashboard',
      description: 'Monitor library statistics, explore books by shelf and category, track overdue items, and add new books - all from one premium interface',
      gradient: LinearGradient(
        colors: [AppColors.primaryDarkBlue, AppColors.primaryTeal],
      ),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _complete,
                child: Text('Skip', style: TextStyle(fontSize: 16.sp)),
              ),
            ).animate().fadeIn(delay: 300.ms),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) => _buildPage(_pages[index]),
              ),
            ),

            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildIndicator(index == _currentPage),
              ),
            ).animate().fadeIn(delay: 500.ms),

            SizedBox(height: isSmallScreen ? 16.h : 24.h),

            // Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: GradientButton(
                text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                onPressed: () {
                  if (_currentPage == _pages.length - 1) {
                    _complete();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                gradient: _pages[_currentPage].gradient,
              ),
            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),

            SizedBox(height: isSmallScreen ? 16.h : 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: isSmallScreen ? 12.h : 24.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated gradient icon with pulsing effect (Responsive)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.35,
                maxHeight: MediaQuery.of(context).size.width * 0.35,
              ),
              child: Container(
                width: isSmallScreen ? 120.w : 160.w,
                height: isSmallScreen ? 120.h : 160.h,
                decoration: BoxDecoration(
                  gradient: page.gradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryTeal.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(page.icon, size: isSmallScreen ? 60.sp : 80.sp, color: Colors.white),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.05, 1.05),
                  duration: 2000.ms,
                  curve: Curves.easeInOut,
                )
                .then()
                .scale(
                  begin: const Offset(1.05, 1.05),
                  end: const Offset(1.0, 1.0),
                  duration: 2000.ms,
                  curve: Curves.easeInOut,
                ),

            SizedBox(height: isSmallScreen ? 32.h : 48.h),

            // Title with gradient shimmer (Adaptive)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: ShaderMask(
                  shaderCallback: (bounds) => page.gradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
                  child: Text(
                    page.title,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 26.sp : 32.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.3, end: 0),

            SizedBox(height: isSmallScreen ? 16.h : 24.h),

            // Description with enhanced styling (Adaptive)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                page.description,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14.sp : 16.sp,
                  color: Colors.grey[700],
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: isSmallScreen ? 3 : 4,
                overflow: TextOverflow.ellipsis,
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      height: isActive ? 12.h : 8.h,
      width: isActive ? 32.w : 8.w,
      decoration: BoxDecoration(
        gradient: isActive
            ? _pages[_currentPage].gradient
            : null,
        color: isActive ? null : Colors.grey[300],
        borderRadius: BorderRadius.circular(6.r),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primaryTeal.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }

  Future<void> _complete() async {
    await setFirstLaunchComplete();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Gradient gradient;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}
