import 'package:flutter/material.dart';

abstract final class AdminColors {
  static const background = Color(0xFFFBF8FF);
  static const primary = Color(0xFF000666);
  static const secondary = Color(0xFF775A19);
  static const secondaryContainer = Color(0xFFFED488);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE8E2F2);
  static const text = Color(0xFF111827);
  static const muted = Color(0xFF6B7280);

  static const darkBackground = Color(0xFF080A1F);
  static const darkSurface = Color(0xFF101331);
  static const darkBorder = Color(0xFF272B58);

  static const emerald = Color(0xFF059669);
  static const blue = Color(0xFF2563EB);
  static const rose = Color(0xFFE11D48);

  // Backwards-compatible aliases for older shared dashboard widgets.
  static const zinc50 = background;
  static const zinc100 = Color(0xFFF4F4F5);
  static const zinc200 = Color(0xFFE4E4E7);
  static const zinc300 = Color(0xFFD4D4D8);
  static const zinc500 = muted;
  static const zinc700 = Color(0xFF3F3F46);
  static const zinc800 = darkBorder;
  static const zinc900 = darkSurface;
  static const zinc950 = darkBackground;
  static const slate50 = background;
  static const slate100 = Color(0xFFF1F5F9);
  static const slate200 = border;
  static const slate400 = Color(0xFF94A3B8);
  static const slate500 = muted;
  static const slate700 = Color(0xFF334155);
  static const slate900 = primary;
  static const indigo500 = Color(0xFF6366F1);
  static const indigo600 = primary;
  static const blue600 = blue;
  static const emerald500 = emerald;
  static const amber500 = secondary;
  static const rose500 = rose;
}
