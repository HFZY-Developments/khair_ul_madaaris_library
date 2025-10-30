import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../utils/responsive.dart';

/// Premium gradient button with animations
class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool isLoading;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient,
    this.width,
    this.height,
    this.icon,
    this.isLoading = false,
    this.textColor,
    this.fontSize,
    this.fontWeight,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        width: widget.width,
        height: widget.height ?? 56.h,
        decoration: BoxDecoration(
          gradient: isDisabled
              ? LinearGradient(
                  colors: [
                    Colors.grey.shade300,
                    Colors.grey.shade400,
                  ],
                )
              : widget.gradient ?? AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium.r),
          boxShadow: _isPressed || isDisabled
              ? []
              : [
                  BoxShadow(
                    color: (widget.gradient ?? AppColors.primaryGradient)
                        .colors
                        .first
                        .withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium.r),
            onTap: isDisabled ? null : widget.onPressed,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge.w,
                vertical: AppConstants.paddingMedium.h,
              ),
              child: widget.isLoading
                  ? Center(
                      child: SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // REMOVED mainAxisSize: MainAxisSize.min - This was causing text cutoff!
                      // Without it, Row takes available width and ellipsis works properly
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: widget.textColor ?? Colors.white,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                        ],
                        Flexible(
                          child: Text(
                            widget.text,
                            style: TextStyle(
                              color: widget.textColor ?? Colors.white,
                              fontSize: widget.fontSize ?? 16.sp,
                              fontWeight: widget.fontWeight ?? FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,  // Added maxLines for safety
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    )
        .animate(target: _isPressed ? 1 : 0)
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(0.95, 0.95),
          duration: AppConstants.animationFast,
        );
  }
}
