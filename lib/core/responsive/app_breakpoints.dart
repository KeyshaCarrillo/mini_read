import 'package:flutter/widgets.dart';

class AppBreakpoints {
  static const double tablet = 768;
  static const double laptop = 1100;
  static const double desktop = 1440;

  static bool isTablet(double width) => width >= tablet && width < laptop;
  static bool isDesktop(double width) => width >= laptop;
  static bool isWide(double width) => width >= desktop;

  static EdgeInsets pagePadding(double width) {
    if (width >= desktop) return const EdgeInsets.all(32);
    if (width >= laptop) return const EdgeInsets.all(24);
    return const EdgeInsets.all(18);
  }

  static int kpiColumns(double width) {
    if (width >= desktop) return 4;
    if (width >= laptop) return 3;
    if (width >= tablet) return 2;
    return 1;
  }
}
