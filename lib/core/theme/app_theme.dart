import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.accentGreen,
        onPrimary: AppColors.surfaceWhite,
        secondary: AppColors.waterBlue,
        onSecondary: AppColors.surfaceWhite,
        error: AppColors.criticalRed,
        onError: AppColors.surfaceWhite,
        background: AppColors.paperBackground,
        onBackground: AppColors.charcoalSoil,
        surface: AppColors.surfaceWhite,
        onSurface: AppColors.charcoalSoil,
      ),
      scaffoldBackgroundColor: AppColors.paperBackground,
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGreen,
          foregroundColor: AppColors.surfaceWhite,
          textStyle: AppTypography.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdRadius,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentGreen,
          side: const BorderSide(color: AppColors.accentGreen),
          textStyle: AppTypography.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdRadius,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentGreen,
          textStyle: AppTypography.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceWhite,
        border: OutlineInputBorder(
          borderRadius: AppRadius.smRadius,
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.smRadius,
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.smRadius,
          borderSide: const BorderSide(color: AppColors.accentGreen),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.smRadius,
          borderSide: const BorderSide(color: AppColors.criticalRed),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceWhite,
        foregroundColor: AppColors.charcoalSoil,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceWhite,
        selectedItemColor: AppColors.accentGreen,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceWhite,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdRadius,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
      ),
    );
  }
}
