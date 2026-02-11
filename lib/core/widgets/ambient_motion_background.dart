import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_colors.dart';

/// Subtle animated background accents used to add a premium feel
/// without changing layout or interaction behavior.
class AmbientMotionBackground extends StatelessWidget {
  final bool isDark;
  final bool compact;
  final double alphaScale;

  const AmbientMotionBackground({
    super.key,
    required this.isDark,
    this.compact = false,
    this.alphaScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final blobScale = compact ? 0.72 : 1.0;
    final opacityScale = alphaScale.clamp(0.1, 1.0);

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -60 * blobScale,
            left: -30 * blobScale,
            child:
                _buildBlob(
                      size: 220 * blobScale,
                      colors: [
                        AppColors.primaryTeal.withValues(
                          alpha: (isDark ? 0.22 : 0.16) * opacityScale,
                        ),
                        Colors.transparent,
                      ],
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .move(
                      begin: const Offset(0, 0),
                      end: const Offset(20, 14),
                      duration: const Duration(milliseconds: 7200),
                      curve: Curves.easeInOut,
                    ),
          ),
          Positioned(
            right: -40 * blobScale,
            bottom: -70 * blobScale,
            child:
                _buildBlob(
                      size: 250 * blobScale,
                      colors: [
                        AppColors.primaryLime.withValues(
                          alpha: (isDark ? 0.14 : 0.12) * opacityScale,
                        ),
                        Colors.transparent,
                      ],
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .move(
                      begin: const Offset(0, 0),
                      end: const Offset(-18, -12),
                      duration: const Duration(milliseconds: 8200),
                      curve: Curves.easeInOut,
                    ),
          ),
          Positioned(
            top: compact ? 80 : 120,
            right: compact ? 20 : 36,
            child:
                _buildBlob(
                      size: 120 * blobScale,
                      colors: [
                        AppColors.primaryDarkBlue.withValues(
                          alpha: (isDark ? 0.24 : 0.1) * opacityScale,
                        ),
                        Colors.transparent,
                      ],
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .move(
                      begin: const Offset(0, 0),
                      end: const Offset(8, 10),
                      duration: const Duration(milliseconds: 6200),
                      curve: Curves.easeInOut,
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlob({required double size, required List<Color> colors}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors, stops: const [0.0, 1.0]),
      ),
    );
  }
}
