import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';

class HoverableCard extends StatefulWidget {
  const HoverableCard({super.key, required this.child, this.padding = EdgeInsets.zero, this.onTap});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  State<HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<HoverableCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final border = context.isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: context.isDark ? const Color(0xFF18181B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _hovered ? context.colors.primary.withValues(alpha: .45) : border),
          boxShadow: _hovered
              ? [BoxShadow(color: Colors.black.withValues(alpha: context.isDark ? .25 : .06), blurRadius: 24, offset: const Offset(0, 12))]
              : [],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );
  }
}
