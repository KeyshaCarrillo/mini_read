import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../extensions/context_extensions.dart';

class PremiumPanel extends StatelessWidget {
  const PremiumPanel({super.key, required this.child, this.padding = AppSpacing.panel});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF18181B) : Colors.white,
        borderRadius: AppSpacing.radiusMd,
        border: Border.all(color: context.isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }
}
