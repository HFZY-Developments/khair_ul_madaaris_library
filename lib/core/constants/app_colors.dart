import 'package:flutter/material.dart';

/// App Color Palette extracted from Khair-ul-Madaaris logo
/// Premium color scheme for elegant UI/UX
class AppColors {
  AppColors._();

  // Primary Colors from Logo
  static const Color primaryTeal = Color(0xFF1BA39C);
  static const Color primaryLime = Color(0xFFC8D908);
  static const Color primaryDarkBlue = Color(0xFF2C5265);
  static const Color primaryLightBlue = Color(0xFFB5C7E0);

  // Gradient Colors
  static const Color gradientStart = Color(0xFF1BA39C);
  static const Color gradientEnd = Color(0xFF2C5265);
  static const Color limeGradientStart = Color(0xFFC8D908);
  static const Color limeGradientEnd = Color(0xFF9DAF07);

  // Semantic Colors - Light Mode
  static const Color successLight = Color(0xFF10B981);
  static const Color warningLight = Color(0xFFF59E0B);
  static const Color errorLight = Color(0xFFEF4444);
  static const Color infoLight = Color(0xFF3B82F6);

  // Semantic Colors - Dark Mode
  static const Color successDark = Color(0xFF34D399);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color errorDark = Color(0xFFF87171);
  static const Color infoDark = Color(0xFF60A5FA);

  // Neutral Colors - Light Mode
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1F2937);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textTertiaryLight = Color(0xFF9CA3AF);
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFD1D5DB);

  // Neutral Colors - Dark Mode
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textTertiaryDark = Color(0xFF94A3B8);
  static const Color dividerDark = Color(0xFF475569);
  static const Color borderDark = Color(0xFF64748B);

  // Book Status Colors
  static const Color statusAvailable = Color(0xFF10B981);  // Green
  static const Color statusCheckedOut = Color(0xFFFF9800);  // Orange
  static const Color statusOverdue = Color(0xFFEF4444);     // Red
  static const Color statusReserved = Color(0xFF3B82F6);    // Blue
  static const Color statusDamaged = Color(0xFF92400E);     // Brown
  static const Color statusLost = Color(0xFF64748B);        // Grey

  // Overlay Colors
  static const Color overlayLight = Color(0x1A000000);  // 10% black
  static const Color overlayDark = Color(0x33000000);   // 20% black
  static const Color scrimLight = Color(0x66000000);    // 40% black
  static const Color scrimDark = Color(0x99000000);     // 60% black

  // Shimmer Colors for Loading States
  static const Color shimmerBaseLight = Color(0xFFE5E7EB);
  static const Color shimmerHighlightLight = Color(0xFFF3F4F6);
  static const Color shimmerBaseDark = Color(0xFF334155);
  static const Color shimmerHighlightDark = Color(0xFF475569);

  // QR Scanner Overlay
  static const Color qrScannerFrame = Color(0xFF1BA39C);
  static const Color qrScannerBackground = Color(0xCC000000);  // 80% black

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryTeal, primaryDarkBlue],
  );

  static const LinearGradient limeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [limeGradientStart, limeGradientEnd],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  );

  // Material Color Swatch for Theme
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF1BA39C,
    <int, Color>{
      50: Color(0xFFE3F5F4),
      100: Color(0xFFBAE6E4),
      200: Color(0xFF8CD6D2),
      300: Color(0xFF5EC6C0),
      400: Color(0xFF3CB9B2),
      500: Color(0xFF1BA39C),
      600: Color(0xFF189B94),
      700: Color(0xFF14918A),
      800: Color(0xFF108880),
      900: Color(0xFF08776E),
    },
  );
}
