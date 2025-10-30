import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/app_state_provider.dart';
import '../../services/google_sheets_service.dart';
import '../onboarding/onboarding_screen.dart';
import '../home/home_screen.dart';

/// Ultra-Premium Splash Screen with Advanced Animations
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late Animation<double> _gradientAnimation;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    // Animated gradient background
    _gradientController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.easeInOut),
    );

    _initialize();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      // Update progress: Initialize Google Sheets Service
      setState(() => _progress = 0.2);
      await GoogleSheetsService.instance.initialize();

      // Update progress
      setState(() => _progress = 0.6);

      // Wait for animations to complete (2.5 seconds total)
      await Future.delayed(const Duration(milliseconds: 2500));

      setState(() => _progress = 1.0);

      if (!mounted) return;

      // Check if first launch
      final isFirstLaunch = await ref.read(firstLaunchProvider.future);

      if (!mounted) return;

      // Navigate to appropriate screen with transition
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              isFirstLaunch ? const OnboardingScreen() : const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } catch (e) {
      // Handle errors gracefully
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Initialization error: $e'),
            backgroundColor: AppColors.errorLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryDarkBlue,
                  Color.lerp(
                    AppColors.primaryTeal,
                    AppColors.primaryDarkBlue,
                    _gradientAnimation.value,
                  )!,
                  AppColors.primaryDarkBlue,
                ],
                stops: [0.0, _gradientAnimation.value * 0.5 + 0.25, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Floating Orbs/Particles
                ..._buildFloatingOrbs(),

                // Main Content
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        // 3D Floating Logo with Multi-layer Shadows (Responsive)
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6,
                            maxHeight: MediaQuery.of(context).size.height * 0.3,
                          ),
                          child: Container(
                            width: 240.w,
                            height: 240.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40.r),
                              boxShadow: [
                                // Deep shadow for depth
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 60,
                                  spreadRadius: 15,
                                  offset: const Offset(0, 20),
                                ),
                                // Lime glow
                                BoxShadow(
                                  color: AppColors.primaryLime.withValues(alpha: 0.5),
                                  blurRadius: 100,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 0),
                                ),
                                // Teal glow
                                BoxShadow(
                                  color: AppColors.primaryTeal.withValues(alpha: 0.4),
                                  blurRadius: 80,
                                  spreadRadius: 10,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 800.ms)
                            .scale(
                              begin: const Offset(0.2, 0.2),
                              end: const Offset(1, 1),
                              curve: Curves.elasticOut,
                              duration: 1600.ms,
                            )
                            .then()
                            .shimmer(
                              delay: 600.ms,
                              duration: 1500.ms,
                              color: Colors.white.withValues(alpha: 0.4),
                            )
                            .shake(delay: 2000.ms, hz: 0.5, duration: 500.ms),

                        SizedBox(height: 56.h),

                        // App Name - Letter by Letter Reveal (Constrained)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: _buildAnimatedText(
                            AppConstants.appName,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            startDelay: 400,
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Arabic Name with Glow
                        Text(
                          AppConstants.appNameArabic,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(
                                color: AppColors.primaryLime.withValues(alpha: 0.8),
                                offset: const Offset(0, 0),
                                blurRadius: 25,
                              ),
                              Shadow(
                                color: AppColors.primaryLime.withValues(alpha: 0.4),
                                offset: const Offset(0, 0),
                                blurRadius: 50,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        )
                            .animate()
                            .fadeIn(delay: 700.ms, duration: 800.ms)
                            .slideY(
                              begin: 0.5,
                              end: 0,
                              curve: Curves.easeOutCubic,
                              duration: 800.ms,
                            ),

                        SizedBox(height: 24.h),

                        // Premium Badge (No "Premium Library Management")
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryLime.withValues(alpha: 0.3),
                                AppColors.primaryTeal.withValues(alpha: 0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(
                              color: AppColors.primaryLime.withValues(alpha: 0.6),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryLime.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.library_books_rounded,
                                color: AppColors.primaryLime,
                                size: 20.sp,
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                'LIBRARY SYSTEM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Icon(
                                Icons.verified,
                                color: AppColors.primaryLime,
                                size: 20.sp,
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 1000.ms, duration: 800.ms)
                            .scale(
                              begin: const Offset(0.7, 0.7),
                              end: const Offset(1, 1),
                              curve: Curves.easeOutBack,
                              duration: 900.ms,
                            )
                            .then()
                            .shimmer(
                              duration: 2000.ms,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),

                        SizedBox(height: 90.h),

                        // Advanced Loading Indicator with Progress (Responsive)
                        Column(
                          children: [
                            // Custom Progress Bar
                            Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              height: 6.h,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Stack(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: MediaQuery.of(context).size.width * 0.5 * _progress,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.primaryTeal,
                                          AppColors.primaryLime,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryLime.withValues(alpha: 0.5),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 20.h),

                            // Status Text
                            Text(
                              _getLoadingText(),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        )
                            .animate(onPlay: (controller) => controller.repeat())
                            .fadeIn(delay: 1200.ms, duration: 800.ms)
                            .then()
                            .shimmer(
                              duration: 2500.ms,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                      ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build Animated Text with Letter Reveal (Adaptive)
  Widget _buildAnimatedText(
    String text, {
    required double fontSize,
    required FontWeight fontWeight,
    required double letterSpacing,
    required int startDelay,
  }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(text.length, (index) {
          final char = text[index];
          return Text(
            char,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  offset: const Offset(0, 4),
                  blurRadius: 15,
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(
                delay: (startDelay + (index * 40)).ms,
                duration: 300.ms,
              )
              .slideY(
                begin: 0.8,
                end: 0,
                curve: Curves.easeOutCubic,
                duration: 400.ms,
              );
        }),
      ),
    );
  }

  /// Build Floating Orbs/Particles
  List<Widget> _buildFloatingOrbs() {
    final random = math.Random(42); // Fixed seed for consistency
    return List.generate(8, (index) {
      final size = 40.0 + random.nextDouble() * 80;
      final left = random.nextDouble() * MediaQuery.of(context).size.width;
      final top = random.nextDouble() * MediaQuery.of(context).size.height;

      return Positioned(
        left: left,
        top: top,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                (index % 2 == 0 ? AppColors.primaryTeal : AppColors.primaryLime)
                    .withValues(alpha: 0.15),
                (index % 2 == 0 ? AppColors.primaryTeal : AppColors.primaryLime)
                    .withValues(alpha: 0.0),
              ],
            ),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .moveY(
              begin: 0,
              end: random.nextDouble() * 50 - 25,
              duration: Duration(milliseconds: 3000 + random.nextInt(2000)),
              curve: Curves.easeInOut,
            )
            .moveX(
              begin: 0,
              end: random.nextDouble() * 50 - 25,
              duration: Duration(milliseconds: 3500 + random.nextInt(2000)),
              curve: Curves.easeInOut,
            ),
      );
    });
  }

  /// Get Loading Status Text
  String _getLoadingText() {
    if (_progress < 0.3) {
      return 'Connecting...';
    } else if (_progress < 0.7) {
      return 'Loading Library...';
    } else if (_progress < 1.0) {
      return 'Almost Ready...';
    } else {
      return 'Welcome!';
    }
  }
}
