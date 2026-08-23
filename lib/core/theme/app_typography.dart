import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const TextStyle _base = TextStyle(
    color: AppColors.charcoalSoil,
    fontFamily: 'Roboto', // Replace with the actual font if different
  );

  static TextStyle get displayLarge => _base.copyWith(fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25);
  static TextStyle get displayMedium => _base.copyWith(fontSize: 45, fontWeight: FontWeight.w400);
  static TextStyle get displaySmall => _base.copyWith(fontSize: 36, fontWeight: FontWeight.w400);

  static TextStyle get headlineLarge => _base.copyWith(fontSize: 32, fontWeight: FontWeight.w400);
  static TextStyle get headlineMedium => _base.copyWith(fontSize: 28, fontWeight: FontWeight.w400);
  static TextStyle get headlineSmall => _base.copyWith(fontSize: 24, fontWeight: FontWeight.w400);

  static TextStyle get titleLarge => _base.copyWith(fontSize: 22, fontWeight: FontWeight.w500);
  static TextStyle get titleMedium => _base.copyWith(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15);
  static TextStyle get titleSmall => _base.copyWith(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1);

  static TextStyle get bodyLarge => _base.copyWith(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5);
  static TextStyle get bodyMedium => _base.copyWith(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25);
  static TextStyle get bodySmall => _base.copyWith(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4);

  static TextStyle get labelLarge => _base.copyWith(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1);
  static TextStyle get labelMedium => _base.copyWith(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5);
  static TextStyle get labelSmall => _base.copyWith(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5);

  static TextStyle get caption => bodySmall.copyWith(color: AppColors.textTertiary);
}
