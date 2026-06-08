import 'package:flutter/material.dart';

class AppTheme {
  static const Color ink = Color(0xFF1A1A1A);
  static const Color paper = Color(0xFFF9F6F0);
  static const Color midnight = Color(0xFF1B263B);
  static const Color gold = Color(0xFFD4AF37);
  static const Color stone = Color(0xFF8B8A86);
  static const Color obsidian = Color(0xFF121212);
  static const Color graphite = Color(0xFF1E1E1E);
  static const Color ivory = Color(0xFFE5E5E5);
  static const Color coral = Color(0xFFE36B5D);
  static const Color sky = Color(0xFF6FA8C8);
  static const Color plum = Color(0xFF76608A);
  static const Color moss = Color(0xFF5B7C62);

  static ThemeData get light {
    return _buildTheme(
      brightness: Brightness.light,
      background: paper,
      surface: Colors.white,
      text: ink,
      primary: midnight,
      secondary: gold,
      outline: Colors.black.withValues(alpha: 0.12),
    );
  }

  static ThemeData get dark {
    return _buildTheme(
      brightness: Brightness.dark,
      background: obsidian,
      surface: graphite,
      text: ivory,
      primary: gold,
      secondary: const Color(0xFF6E8DFF),
      outline: Colors.white.withValues(alpha: 0.14),
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color text,
    required Color primary,
    required Color secondary,
    required Color outline,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: primary,
      secondary: secondary,
      surface: surface,
      onSurface: text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: text,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: outline),
        ),
      ),
    );
  }
}
