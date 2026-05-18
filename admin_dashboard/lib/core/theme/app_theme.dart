import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AdminTheme {
  static ThemeData light() => _theme(Brightness.light);
  static ThemeData dark() => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AdminColors.primary,
      brightness: brightness,
      primary: AdminColors.primary,
      secondary: AdminColors.secondary,
      secondaryContainer: AdminColors.secondaryContainer,
      surface: isDark ? AdminColors.darkSurface : AdminColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? AdminColors.darkBackground : AdminColors.background,
      dividerColor: isDark ? AdminColors.darkBorder : AdminColors.border,
      textTheme: GoogleFonts.interTextTheme(isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AdminColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AdminColors.darkBackground : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: isDark ? AdminColors.darkBorder : AdminColors.border)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? AdminColors.darkSurface : AdminColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: BorderSide(color: isDark ? AdminColors.darkBorder : AdminColors.border)),
      ),
    );
  }
}
