import 'package:flutter/widgets.dart';

import 'breakpoints.dart';

T responsiveValue<T>(
  BuildContext context, {
  required T tablet,
  required T laptop,
  required T desktop,
  T? wide,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= AdminBreakpoints.wide && wide != null) return wide;
  if (width >= AdminBreakpoints.desktop) return desktop;
  if (width >= AdminBreakpoints.laptop) return laptop;
  return tablet;
}
