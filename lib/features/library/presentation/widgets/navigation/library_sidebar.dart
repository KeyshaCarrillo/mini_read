import 'package:flutter/material.dart';

class LibrarySidebar extends StatelessWidget {
  final bool collapsed;
  final bool compact;
  final VoidCallback onToggle;
  final VoidCallback onProfiles;
  final int bookCount;
  final int profileCount;

  const LibrarySidebar({
    super.key,
    required this.collapsed,
    required this.compact,
    required this.onToggle,
    required this.onProfiles,
    required this.bookCount,
    required this.profileCount,
  });

  static const double expandedWidth = 264;
  static const double collapsedWidth = 84;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final showLabels = !collapsed && !compact;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: compact ? 0 : (collapsed ? collapsedWidth : expandedWidth),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.92),
        border: Border(right: BorderSide(color: scheme.outline.withValues(alpha: 0.65))),
      ),
      child: compact
          ? const SizedBox.shrink()
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 14, 16),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.menu_book_rounded, color: Colors.white),
                        ),
                        if (showLabels) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mini Read',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  'Enterprise Library OS',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        IconButton(
                          tooltip: collapsed ? 'Expandir navegación' : 'Colapsar navegación',
                          onPressed: onToggle,
                          icon: Icon(collapsed ? Icons.keyboard_double_arrow_right_rounded : Icons.keyboard_double_arrow_left_rounded),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SidebarItem(
                    icon: Icons.dashboard_customize_rounded,
                    label: 'Overview',
                    active: true,
                    showLabel: showLabels,
                  ),
                  _SidebarItem(
                    icon: Icons.auto_stories_rounded,
                    label: 'Catálogo',
                    count: bookCount,
                    showLabel: showLabels,
                  ),
                  _SidebarItem(
                    icon: Icons.analytics_rounded,
                    label: 'Analytics',
                    showLabel: showLabels,
                  ),
                  _SidebarItem(
                    icon: Icons.smart_toy_rounded,
                    label: 'AI Reading',
                    showLabel: showLabels,
                  ),
                  _SidebarItem(
                    icon: Icons.group_rounded,
                    label: 'Perfiles',
                    count: profileCount,
                    showLabel: showLabels,
                    onTap: onProfiles,
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: _SidebarItem(
                      icon: Icons.help_outline_rounded,
                      label: 'Soporte',
                      showLabel: showLabels,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool showLabel;
  final int? count;
  final VoidCallback? onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.showLabel,
    this.active = false,
    this.count,
    this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = widget.active ? scheme.primary : scheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          decoration: BoxDecoration(
            color: widget.active
                ? scheme.primary.withValues(alpha: 0.08)
                : _hovered
                    ? scheme.surfaceContainerHighest.withValues(alpha: 0.52)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            dense: true,
            visualDensity: const VisualDensity(horizontal: -2, vertical: -1),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leading: Icon(widget.icon, color: foreground),
            title: widget.showLabel
                ? Text(
                    widget.label,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 14,
                      fontWeight: widget.active ? FontWeight.w800 : FontWeight.w700,
                    ),
                  )
                : null,
            trailing: widget.showLabel && widget.count != null
                ? Text(
                    '${widget.count}',
                    style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w800, fontSize: 12),
                  )
                : null,
            onTap: widget.onTap,
          ),
        ),
      ),
    );
  }
}
