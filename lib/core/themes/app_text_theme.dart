import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextTheme {
  AppTextTheme._();

  // Base Poppins Text Style
  static final TextStyle _baseTextStyle = GoogleFonts.poppins();

  // Light Theme Text Styles
  static TextTheme lightTextTheme = TextTheme(
    // Title Styles
    headlineLarge: _baseTextStyle.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.lightText,
    ),
    headlineMedium: _baseTextStyle.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.lightText,
    ),
    headlineSmall: _baseTextStyle.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.lightText,
    ),

    // Body Styles
    bodyLarge: _baseTextStyle.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: AppColors.lightText,
      height: 1.5,
    ),
    bodyMedium: _baseTextStyle.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.lightTextSecondary,
      height: 1.4,
    ),
    bodySmall: _baseTextStyle.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.lightTextSecondary,
      height: 1.3,
    ),
  );

  // Dark Theme Text Styles
  static TextTheme darkTextTheme = TextTheme(
    // Title Styles
    headlineLarge: _baseTextStyle.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.darkText,
    ),
    headlineMedium: _baseTextStyle.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.darkText,
    ),
    headlineSmall: _baseTextStyle.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.darkText,
    ),

    // Body Styles
    bodyLarge: _baseTextStyle.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.darkText,
      height: 1.5,
    ),
    bodyMedium: _baseTextStyle.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.darkTextSecondary,
      height: 1.4,
    ),
    bodySmall: _baseTextStyle.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: AppColors.darkTextSecondary,
      height: 1.3,
    ),
  );
}
