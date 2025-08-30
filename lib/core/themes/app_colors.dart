import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF2196F3);
  static const Color lightBackground = Color.fromARGB(255, 239, 250, 254);
  static const Color lightSurface = Color(0xFFF8F9FA);
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFF42A5F5);
  static const Color darkBackground = Color(0xFF1A1D29);
  static const Color darkSurface = Color(0xFF252834);
  static const Color darkText = Color(0xFFE5E7EB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  //Bottom Navigation Bar Colors
  static const Color lightBottomNav = Color(0xFFFDFDFE);
  static const Color darkBottomNav = Color(0xFF2A2F3E);

  // Gradient Colors for Buttons
  static const LinearGradient lightGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF21CBF3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF42A5F5), Color(0xFF29B6F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Utility Colors
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
}
