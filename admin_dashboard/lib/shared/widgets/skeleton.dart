import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';

class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({super.key, this.height = 16, this.width, this.radius = 10});
  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .35, end: .75),
      duration: const Duration(milliseconds: 900),
      builder: (context, value, child) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: context.colors.onSurface.withValues(alpha: context.isDark ? value * .09 : value * .08), borderRadius: BorderRadius.circular(radius)),
      ),
    );
  }
}
