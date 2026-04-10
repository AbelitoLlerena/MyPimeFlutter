import 'package:flutter/material.dart';

/// Paleta alineada con referencia VentaPOS (sidebar oscuro, acentos teal/verde).
abstract final class AppColors {
  static const Color sidebar = Color(0xFF1a1d23);
  static const Color sidebarText = Color(0xFF94a3b8);
  static const Color pageBackground = Color(0xFFF1F5F9);
  static const Color primaryTeal = Color(0xFF14b8a6);
  static const Color primaryGreen = Color(0xFF22c55e);
  static const Color danger = Color(0xFFef4444);
  static const Color warningBg = Color(0xFFfef3c7);
  static const Color warningText = Color(0xFF92400e);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryTeal,
      brightness: Brightness.light,
      primary: AppColors.primaryTeal,
    ),
    scaffoldBackgroundColor: AppColors.pageBackground,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF0f172a),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFe2e8f0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFe2e8f0)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
  return base;
}
