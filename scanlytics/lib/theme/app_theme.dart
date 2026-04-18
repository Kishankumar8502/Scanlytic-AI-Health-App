import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF4F6F8);
  static const Color surface = Colors.white;
  static const Color neonGreen = Color(0xFF10B981); // Medical green
  static const Color neonRed = Color(0xFFEF4444); // Medical red
  static const Color textMain = Color(0xFF1F2937); // Dark grey
  static const Color textMuted = Color(0xFF6B7280); // Lighter grey
  static const Color border = Color(0xFFE5E7EB);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.neonGreen,
        error: AppColors.neonRed,
        surface: AppColors.surface,
      ),
      fontFamily: 'sans-serif',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textMain,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.neonGreen),
        titleTextStyle: TextStyle(
          color: AppColors.textMain,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
