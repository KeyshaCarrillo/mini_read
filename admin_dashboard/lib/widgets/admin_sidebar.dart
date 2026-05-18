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

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: const Border(
          right: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Admin Core',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 36),
          _NavButton(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard General',
            selected: admin.section == AdminSection.dashboard,
            onTap: () => _select(context, AdminSection.dashboard),
          ),
          _NavButton(
            icon: Icons.group_rounded,
            label: 'Gestion de Usuarios',
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
            label: 'Configuracion',
            selected: admin.section == AdminSection.settings,
            onTap: () => _select(context, AdminSection.settings),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.surfaceContainerHighest,
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
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
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

class _NavButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected ? Colors.white : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selected
                          ? Colors.white
                          : AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
