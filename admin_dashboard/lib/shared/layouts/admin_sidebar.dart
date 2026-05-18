import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/constants/app_spacing.dart';
import '../../routes/app_routes.dart';
import '../extensions/context_extensions.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key, required this.collapsed, required this.onToggle, required this.activeRoute, required this.onRouteSelected});

  final bool collapsed;
  final VoidCallback onToggle;
  final AdminRoute activeRoute;
  final ValueChanged<AdminRoute> onRouteSelected;

  @override
  Widget build(BuildContext context) {
    final width = collapsed ? 76.0 : 256.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: width,
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF09090B) : Colors.white,
        border: Border(right: BorderSide(color: context.theme.dividerColor)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 12, 18),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_stories_rounded, size: 19, color: Colors.white),
                ),
                if (!collapsed) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(AppConfig.appName, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w800))),
                ],
                IconButton(onPressed: onToggle, tooltip: collapsed ? 'Expand sidebar' : 'Collapse sidebar', icon: Icon(collapsed ? Icons.keyboard_double_arrow_right_rounded : Icons.keyboard_double_arrow_left_rounded, size: 18)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              children: [
                _NavSection(routes: AdminRoutes.primary, collapsed: collapsed, activeRoute: activeRoute, onRouteSelected: onRouteSelected),
                const SizedBox(height: 24),
                if (!collapsed) Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('Workspace', style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant, letterSpacing: .6))),
                const SizedBox(height: 8),
                _NavSection(routes: AdminRoutes.utility, collapsed: collapsed, activeRoute: activeRoute, onRouteSelected: onRouteSelected),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: context.colors.primary.withValues(alpha: .08), borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Icon(Icons.verified_user_outlined, color: context.colors.primary, size: 18),
                  if (!collapsed) ...[
                    const SizedBox(width: 10),
                    Expanded(child: Text('Admin-only console', style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w700))),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavSection extends StatelessWidget {
  const _NavSection({required this.routes, required this.collapsed, required this.activeRoute, required this.onRouteSelected});
  final List<AdminRoute> routes;
  final bool collapsed;
  final AdminRoute activeRoute;
  final ValueChanged<AdminRoute> onRouteSelected;

  @override
  Widget build(BuildContext context) {
    return Column(children: routes.map((route) => _NavItem(route: route, collapsed: collapsed, selected: route.path == activeRoute.path, onPressed: () => onRouteSelected(route))).toList());
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({required this.route, required this.collapsed, required this.selected, required this.onPressed});
  final AdminRoute route;
  final bool collapsed;
  final bool selected;
  final VoidCallback onPressed;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected;
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: EdgeInsets.symmetric(horizontal: widget.collapsed ? 12 : 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? context.colors.primary.withValues(alpha: .10) : hovered ? context.colors.onSurface.withValues(alpha: .045) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            AnimatedContainer(duration: const Duration(milliseconds: 160), width: 3, height: 18, decoration: BoxDecoration(color: active ? context.colors.primary : Colors.transparent, borderRadius: BorderRadius.circular(999))),
            const SizedBox(width: 10),
            Icon(widget.route.icon, size: 18, color: active ? context.colors.primary : context.colors.onSurfaceVariant),
            if (!widget.collapsed) ...[
              const SizedBox(width: 12),
              Expanded(child: Text(widget.route.label, style: context.text.labelLarge?.copyWith(fontWeight: active ? FontWeight.w800 : FontWeight.w600, color: active ? context.colors.onSurface : context.colors.onSurfaceVariant))),
            ],
          ],
        ),
      ),
      ),
    );
  }
}
