import 'package:flutter/material.dart';

class AppTheme {
  static const Color ink = Color(0xFF12131A);
  static const Color paper = Color(0xFFFFFCF4);
  static const Color moss = Color(0xFF5B7C62);
  static const Color coral = Color(0xFFE36B5D);
  static const Color sky = Color(0xFF6FA8C8);
  static const Color plum = Color(0xFF76608A);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: moss,
      brightness: Brightness.light,
      primary: moss,
      secondary: coral,
      tertiary: sky,
      surface: paper,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: paper,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
        ),
      ),
    );
  }
}
