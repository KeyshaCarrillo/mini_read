import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/admin_controller.dart';
import '../controllers/auth_controller.dart';
import '../core/constants.dart';

class AdminSidebar extends StatelessWidget {
  final bool compact;

  const AdminSidebar({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();
    final auth = context.watch<AuthController>();
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF9FAFF), Color(0xFFF2F5FF)],
        ),
        border: const Border(
          right: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDCE2FB)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14031B79),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF04117C), Color(0xFF1B36B7)],
                    ),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Administrador',
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Control Center',
                        style: textTheme.labelMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          _NavButton(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard General',
            selected: admin.section == AdminSection.dashboard,
            onTap: () => _select(context, AdminSection.dashboard),
          ),
          _NavButton(
            icon: Icons.group_rounded,
            label: 'Gestión de Usuarios',
            selected: admin.section == AdminSection.users,
            onTap: () => _select(context, AdminSection.users),
          ),
          _NavButton(
            icon: Icons.history_edu_rounded,
            label: 'Historial de Tokens',
            selected: admin.section == AdminSection.tokens,
            onTap: () => _select(context, AdminSection.tokens),
          ),
          _NavButton(
            icon: Icons.settings_rounded,
            label: 'Configuración',
            selected: admin.section == AdminSection.settings,
            onTap: () => _select(context, AdminSection.settings),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDCE2FB)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFEFF2FF),
                  child: Icon(Icons.person_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        auth.role == 'owner'
                            ? 'Platform Owner'
                            : 'Platform Administrator',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _select(BuildContext context, AdminSection section) {
    context.read<AdminController>().setSection(section);
    if (compact) Navigator.of(context).pop();
  }
}

class _NavButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFF04117C), Color(0xFF1B36B7)],
                  )
                : null,
            color: active ? null : (_hover ? const Color(0xFFEFF3FF) : null),
            border: active
                ? null
                : Border.all(color: const Color(0xFFDDE2F5), width: 0.9),
            boxShadow: active
                ? const [
                    BoxShadow(
                      color: Color(0x2B1A36B6),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 13,
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      size: 20,
                      color: active ? Colors.white : AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.label,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: active
                              ? Colors.white
                              : AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
