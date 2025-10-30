import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// Premium App Theme for Khair-ul-Madaaris Library
/// Implements both light and dark themes with elegant Material Design 3
class AppTheme {
  AppTheme._();

  // Font Family
  static const String _fontFamily = 'Poppins';

  /// Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: _fontFamily,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryTeal,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryTeal.withValues(alpha: 0.1),
        onPrimaryContainer: AppColors.primaryTeal,

        secondary: AppColors.primaryLime,
        onSecondary: AppColors.primaryDarkBlue,
        secondaryContainer: AppColors.primaryLime.withValues(alpha: 0.1),
        onSecondaryContainer: AppColors.primaryDarkBlue,

        tertiary: AppColors.primaryDarkBlue,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.primaryDarkBlue.withValues(alpha: 0.1),
        onTertiaryContainer: AppColors.primaryDarkBlue,

        error: AppColors.errorLight,
        onError: Colors.white,
        errorContainer: AppColors.errorLight.withValues(alpha: 0.1),
        onErrorContainer: AppColors.errorLight,

        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        surfaceContainerHighest: AppColors.cardLight,

        outline: AppColors.borderLight,
        outlineVariant: AppColors.dividerLight,

        shadow: AppColors.overlayLight,
        scrim: AppColors.scrimLight,

        inverseSurface: AppColors.surfaceDark,
        onInverseSurface: AppColors.textPrimaryDark,
        inversePrimary: AppColors.primaryTeal,
      ),

      scaffoldBackgroundColor: AppColors.backgroundLight,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimaryLight,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
          letterSpacing: 0.15,
        ),
        iconTheme: IconThemeData(
          color: AppColors.textPrimaryLight,
          size: AppConstants.iconSizeMedium,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cardLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          side: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        margin: EdgeInsets.all(AppConstants.paddingSmall),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          textStyle: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryTeal,
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          side: BorderSide(
            color: AppColors.primaryTeal,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          textStyle: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryTeal,
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall,
          ),
          textStyle: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Icon Button Theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimaryLight,
          hoverColor: AppColors.primaryTeal.withValues(alpha: 0.08),
          highlightColor: AppColors.primaryTeal.withValues(alpha: 0.12),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppColors.primaryTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppColors.errorLight),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppColors.errorLight, width: 2),
        ),
        labelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          color: AppColors.textSecondaryLight,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          color: AppColors.textTertiaryLight,
          fontWeight: FontWeight.w400,
        ),
        errorStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          color: AppColors.errorLight,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        elevation: 8,
        backgroundColor: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryLight,
          letterSpacing: 0.15,
        ),
        contentTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondaryLight,
          height: 1.5,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 8,
        backgroundColor: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.borderRadiusLarge),
          ),
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        elevation: 6,
        backgroundColor: AppColors.textPrimaryLight,
        contentTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primaryTeal,
        circularTrackColor: AppColors.primaryTeal.withValues(alpha: 0.2),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 1,
        space: 1,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.1),
        labelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryTeal,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingSmall,
          vertical: AppConstants.paddingSmall / 2,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
      ),

      // Text Theme
      textTheme: _buildTextTheme(Brightness.light),
    );
  }

  /// Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,

      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryTeal,
        onPrimary: AppColors.primaryDarkBlue,
        primaryContainer: AppColors.primaryTeal.withValues(alpha: 0.2),
        onPrimaryContainer: AppColors.primaryTeal,

        secondary: AppColors.primaryLime,
        onSecondary: AppColors.primaryDarkBlue,
        secondaryContainer: AppColors.primaryLime.withValues(alpha: 0.2),
        onSecondaryContainer: AppColors.primaryLime,

        tertiary: AppColors.primaryLightBlue,
        onTertiary: AppColors.primaryDarkBlue,
        tertiaryContainer: AppColors.primaryLightBlue.withValues(alpha: 0.2),
        onTertiaryContainer: AppColors.primaryLightBlue,

        error: AppColors.errorDark,
        onError: AppColors.backgroundDark,
        errorContainer: AppColors.errorDark.withValues(alpha: 0.2),
        onErrorContainer: AppColors.errorDark,

        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        surfaceContainerHighest: AppColors.cardDark,

        outline: AppColors.borderDark,
        outlineVariant: AppColors.dividerDark,

        shadow: AppColors.overlayDark,
        scrim: AppColors.scrimDark,

        inverseSurface: AppColors.surfaceLight,
        onInverseSurface: AppColors.textPrimaryLight,
        inversePrimary: AppColors.primaryDarkBlue,
      ),

      scaffoldBackgroundColor: AppColors.backgroundDark,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
          letterSpacing: 0.15,
        ),
        iconTheme: IconThemeData(
          color: AppColors.textPrimaryDark,
          size: AppConstants.iconSizeMedium,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cardDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          side: BorderSide(
            color: AppColors.borderDark,
            width: 1,
          ),
        ),
        margin: EdgeInsets.all(AppConstants.paddingSmall),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: AppColors.primaryDarkBlue,
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          textStyle: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryTeal,
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          side: BorderSide(
            color: AppColors.primaryTeal,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          textStyle: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryTeal,
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall,
          ),
          textStyle: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Icon Button Theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimaryDark,
          hoverColor: AppColors.primaryTeal.withValues(alpha: 0.16),
          highlightColor: AppColors.primaryTeal.withValues(alpha: 0.24),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: AppColors.primaryDarkBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDark,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppColors.primaryTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppColors.errorDark),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppColors.errorDark, width: 2),
        ),
        labelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          color: AppColors.textSecondaryDark,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          color: AppColors.textTertiaryDark,
          fontWeight: FontWeight.w400,
        ),
        errorStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          color: AppColors.errorDark,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        elevation: 8,
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryDark,
          letterSpacing: 0.15,
        ),
        contentTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondaryDark,
          height: 1.5,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 8,
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.borderRadiusLarge),
          ),
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        elevation: 6,
        backgroundColor: AppColors.cardDark,
        contentTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primaryTeal,
        circularTrackColor: AppColors.primaryTeal.withValues(alpha: 0.3),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
        space: 1,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryTeal,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingSmall,
          vertical: AppConstants.paddingSmall / 2,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
      ),

      // Text Theme
      textTheme: _buildTextTheme(Brightness.dark),
    );
  }

  /// Build Text Theme
  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseColor = brightness == Brightness.light
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;
    final secondaryColor = brightness == Brightness.light
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;

    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 57,
        fontWeight: FontWeight.w800,
        color: baseColor,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: 0,
        height: 1.22,
      ),
      headlineLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0,
        height: 1.33,
      ),
      titleLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.15,
        height: 1.50,
      ),
      titleSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      bodyLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: 0.5,
        height: 1.50,
      ),
      bodyMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        letterSpacing: 0.4,
        height: 1.33,
      ),
      labelLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: secondaryColor,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }
}
