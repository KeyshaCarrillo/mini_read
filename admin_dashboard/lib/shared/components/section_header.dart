import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, required this.subtitle, this.trailing});

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(subtitle, style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
