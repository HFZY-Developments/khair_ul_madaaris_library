import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';

/// Elegant premium animated background with smooth gradient waves
class LiquidBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const LiquidBackground({
    super.key,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient
        Positioned.fill(
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
            ),
          ),
        ),
        // Animated gradient wave 1 - Teal
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryTeal.withValues(alpha: isDark ? 0.10 : 0.06),
                  Colors.transparent,
                  Colors.transparent,
                ],
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .fadeIn(duration: 4000.ms, curve: Curves.easeInOut)
              .then()
              .fadeOut(duration: 4000.ms, curve: Curves.easeInOut),
        ),
        // Animated gradient wave 2 - Lime (opposite direction, different timing)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                colors: [
                  AppColors.primaryLime.withValues(alpha: isDark ? 0.10 : 0.06),
                  Colors.transparent,
                  Colors.transparent,
                ],
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .fadeOut(duration: 4000.ms, curve: Curves.easeInOut)
              .then()
              .fadeIn(duration: 4000.ms, curve: Curves.easeInOut),
        ),
        // Radial gradient overlay - adds depth
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.transparent,
                  (isDark ? Colors.black : Colors.white).withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
        ),
        // Content
        child,
      ],
    );
  }
}
