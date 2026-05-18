import 'package:flutter/material.dart';

class AppTheme {
  static const Color zinc50 = Color(0xFFFAFAFA);
  static const Color zinc100 = Color(0xFFF4F4F5);
  static const Color zinc200 = Color(0xFFE4E4E7);
  static const Color zinc300 = Color(0xFFD4D4D8);
  static const Color zinc500 = Color(0xFF71717A);
  static const Color zinc600 = Color(0xFF52525B);
  static const Color zinc700 = Color(0xFF3F3F46);
  static const Color zinc800 = Color(0xFF27272A);
  static const Color zinc900 = Color(0xFF18181B);
  static const Color slate950 = Color(0xFF020617);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo700 = Color(0xFF4338CA);
  static const Color emerald600 = Color(0xFF059669);
  static const Color amber600 = Color(0xFFD97706);
  static const Color rose600 = Color(0xFFE11D48);

  // Legacy aliases used by older screens while the app migrates to /theme.
  static const Color ink = zinc900;
  static const Color paper = zinc50;
  static const Color midnight = slate950;
  static const Color gold = amber600;
  static const Color stone = zinc500;
  static const Color obsidian = Color(0xFF09090B);
  static const Color graphite = zinc900;
  static const Color ivory = zinc100;
  static const Color coral = rose600;
  static const Color sky = Color(0xFF2563EB);
  static const Color plum = indigo700;
  static const Color moss = emerald600;

  static ThemeData get light => _buildTheme(
    brightness: Brightness.light,
    seed: indigo600,
    background: zinc50,
    surface: Colors.white,
    surfaceContainer: zinc100,
    text: zinc900,
    muted: zinc600,
    outline: zinc200,
  );

  static ThemeData get dark => _buildTheme(
    brightness: Brightness.dark,
    seed: Color(0xFF818CF8),
    background: Color(0xFF09090B),
    surface: Color(0xFF111113),
    surfaceContainer: zinc900,
    text: zinc100,
    muted: zinc300,
    outline: zinc800,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color seed,
    required Color background,
    required Color surface,
    required Color surfaceContainer,
    required Color text,
    required Color muted,
    required Color outline,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      primary: seed,
      secondary: indigo700,
      surface: surface,
      surfaceContainer: surfaceContainer,
      onSurface: text,
      outline: outline,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Inter',
      visualDensity: VisualDensity.standard,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: 'Inter',
        bodyColor: text,
        displayColor: text,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: text,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: outline),
        ),
      ),
      dividerTheme: DividerThemeData(color: outline, space: 1, thickness: 1),
      iconTheme: IconThemeData(color: muted, size: 20),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: TextStyle(color: muted, fontWeight: FontWeight.w500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: seed, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: seed,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 42),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          minimumSize: const Size(0, 42),
          side: BorderSide(color: outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
