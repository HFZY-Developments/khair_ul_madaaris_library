import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Responsive utility class for adaptive layouts
/// Note: flutter_screenutil provides .w, .h, .sp, .r extensions automatically
class Responsive {
  Responsive._();

  /// Initialize ScreenUtil (call in main.dart)
  static void init(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812), // iPhone 11 Pro design size
      minTextAdapt: true,
    );
  }

  /// Check if device is mobile (< 600dp)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Check if device is tablet (>= 600dp and < 1200dp)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  /// Check if device is desktop (>= 1200dp)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  /// Get responsive value based on device type
  static T valueWhen<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get safe area padding
  static EdgeInsets safeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }
}

// Note: No need to create extension methods here
// flutter_screenutil already provides:
// - num.w for responsive width
// - num.h for responsive height
// - num.sp for responsive font size
// - num.r for responsive radius
//
// Use them directly like: 16.w, 20.h, 14.sp, 12.r
