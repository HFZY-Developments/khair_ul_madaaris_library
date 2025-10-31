import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _rotationController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _rotationController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0a0a0a),
                    const Color(0xFF1a1a1a),
                    const Color(0xFF0f0f0f),
                  ]
                : [
                    const Color(0xFFf5f5f5),
                    const Color(0xFFe8e8e8),
                    const Color(0xFFfafafa),
                  ],
          ),
        ),
        child: Stack(
          children: [
            // Sophisticated floating elements
            ..._buildFloatingElements(),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  child: Column(
                    children: [
                      SizedBox(height: 10.h),

                      // Minimalist close button
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.close_rounded,
                              size: 24.sp,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 400.ms),

                      SizedBox(height: 30.h),

                      // Premium hero section
                      _buildPremiumHero(isDark),

                      SizedBox(height: 48.h),

                      // Elite title
                      _buildEliteTitle(isDark),

                      SizedBox(height: 16.h),

                      // Refined subtitle
                      _buildSubtitle(isDark),

                      SizedBox(height: 48.h),

                      // Premium message
                      _buildPremiumMessage(isDark),

                      SizedBox(height: 40.h),

                      // Elite banking card
                      _buildEliteBankCard(context, isDark),

                      SizedBox(height: 40.h),

                      // Professional branding
                      _buildProfessionalBranding(isDark),

                      SizedBox(height: 48.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingElements() {
    return List.generate(6, (index) {
      return AnimatedBuilder(
        animation: _rotationController,
        builder: (context, child) {
          final angle = (_rotationController.value * 2 * math.pi) + (index * 2 * math.pi / 6);
          final radius = 180.w + (index * 25);

          return Positioned(
            left: MediaQuery.of(context).size.width / 2 + math.cos(angle) * radius - 80.w,
            top: MediaQuery.of(context).size.height / 3 + math.sin(angle) * radius - 80.w,
            child: Container(
              width: 160.w - (index * 20),
              height: 160.w - (index * 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryTeal.withOpacity(0.08 - index * 0.01),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildPremiumHero(bool isDark) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowIntensity = 0.3 + (_glowController.value * 0.2);

        return Container(
          width: 160.w,
          height: 160.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF00897B),
                const Color(0xFF00695C),
                const Color(0xFF004D40),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00897B).withOpacity(glowIntensity),
                blurRadius: 60,
                spreadRadius: 20,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.favorite_rounded,
              size: 80.sp,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
        );
      },
    ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms);
  }

  Widget _buildEliteTitle(bool isDark) {
    return Column(
      children: [
        Text(
          'Support Developer',
          style: TextStyle(
            fontSize: 38.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.5,
            color: isDark ? Colors.white : Colors.black87,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12.h),
        Container(
          width: 80.w,
          height: 4.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryTeal,
                AppColors.primaryLime,
              ],
            ),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildSubtitle(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.school_rounded,
            color: AppColors.primaryTeal,
            size: 18.sp,
          ),
          SizedBox(width: 10.w),
          Text(
            'Built with excellence for Madrasahs',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 400.ms).scale();
  }

  Widget _buildPremiumMessage(bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final messagePadding = screenWidth < 360 ? 20.w : (screenWidth < 600 ? 26.w : 32.w);

    return Container(
      padding: EdgeInsets.all(messagePadding),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.volunteer_activism_rounded,
            size: 48.sp,
            color: AppColors.primaryTeal,
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(duration: 2000.ms, begin: const Offset(1, 1), end: const Offset(1.05, 1.05)),

          SizedBox(height: 24.h),

          Text(
            'Your support helps us continue creating free Islamic apps for the Ummah.\n\nA portion of all contributions goes towards Sadaqah, and the rest helps us maintain and improve our apps.\n\nJazakAllahu Khayran for your kindness and support.',
            style: TextStyle(
              fontSize: 15.sp,
              height: 1.8,
              fontWeight: FontWeight.w400,
              color: isDark ? Colors.white.withOpacity(0.8) : Colors.black87,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildEliteBankCard(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardPadding = screenWidth < 360 ? 20.w : (screenWidth < 600 ? 28.w : 36.w);

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00695C),
            const Color(0xFF004D40),
            const Color(0xFF00332A),
          ],
        ),
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00695C).withOpacity(0.4),
            blurRadius: 50,
            offset: const Offset(0, 25),
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 80,
            offset: const Offset(0, 40),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Banking Details',
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Tap icon to copy',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white60,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 36.h),

          // Banking details
          _buildEliteDetailRow(context, 'Bank', 'FNB/RMB', Icons.account_balance_rounded, false),
          SizedBox(height: 16.h),
          _buildEliteDetailRow(context, 'Account Holder', 'H Chothia', Icons.person_outline_rounded, true),
          SizedBox(height: 16.h),
          _buildEliteDetailRow(context, 'Account Type', 'Current Account', Icons.credit_card_rounded, false),
          SizedBox(height: 16.h),
          _buildEliteDetailRow(context, 'Account Number', '62883389499', Icons.tag_rounded, true),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildEliteDetailRow(BuildContext context, String label, String value, IconData icon, bool copyable) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 22.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: copyable ? 17.sp : 15.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: copyable ? 0.8 : 0.2,
                  ),
                ),
              ],
            ),
          ),
          if (copyable)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  HapticFeedback.mediumImpact();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.white, size: 22.sp),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              '$label copied successfully',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFF00695C),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      duration: const Duration(seconds: 2),
                      margin: EdgeInsets.all(16.w),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.content_copy_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfessionalBranding(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.white.withOpacity(0.03),
                  Colors.white.withOpacity(0.01),
                ]
              : [
                  Colors.black.withOpacity(0.02),
                  Colors.black.withOpacity(0.01),
                ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryTeal,
                  AppColors.primaryTeal.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.code_rounded, color: Colors.white, size: 22.sp),
          ),
          SizedBox(width: 14.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HFZY Developments',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Crafted with precision & care',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isDark ? Colors.white.withOpacity(0.5) : Colors.black45,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 700.ms, delay: 800.ms).slideY(begin: 0.1, end: 0);
  }
}
