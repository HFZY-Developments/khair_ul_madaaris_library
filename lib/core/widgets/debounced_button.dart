import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Debounced Button - Prevents rapid taps and provides haptic feedback
class DebouncedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool enabled;

  const DebouncedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.enabled = true,
  });

  @override
  State<DebouncedButton> createState() => _DebouncedButtonState();
}

class _DebouncedButtonState extends State<DebouncedButton> {
  bool _isProcessing = false;

  Future<void> _handlePress() async {
    if (_isProcessing || !widget.enabled) return;

    setState(() => _isProcessing = true);

    // Haptic feedback
    HapticFeedback.mediumImpact();

    widget.onPressed();

    // Debounce delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (_isProcessing || !widget.enabled) ? null : _handlePress,
      style: widget.style,
      child: widget.child,
    );
  }
}

/// Debounced Outlined Button
class DebouncedOutlinedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool enabled;

  const DebouncedOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.enabled = true,
  });

  @override
  State<DebouncedOutlinedButton> createState() => _DebouncedOutlinedButtonState();
}

class _DebouncedOutlinedButtonState extends State<DebouncedOutlinedButton> {
  bool _isProcessing = false;

  Future<void> _handlePress() async {
    if (_isProcessing || !widget.enabled) return;

    setState(() => _isProcessing = true);

    // Haptic feedback
    HapticFeedback.lightImpact();

    widget.onPressed();

    // Debounce delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: (_isProcessing || !widget.enabled) ? null : _handlePress,
      style: widget.style,
      child: widget.child,
    );
  }
}
