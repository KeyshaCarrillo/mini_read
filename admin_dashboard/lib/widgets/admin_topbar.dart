import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/admin_controller.dart';
import '../controllers/auth_controller.dart';
import '../core/constants.dart';

class AdminTopbar extends StatelessWidget {
  final bool showMenu;
  final VoidCallback onMenuPressed;

  const AdminTopbar({
    super.key,
    required this.showMenu,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();
    final auth = context.watch<AuthController>();
    final now = DateTime.now();

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color?.withValues(alpha: 0.92),
        border: const Border(
          bottom: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          if (showMenu)
            IconButton(
              tooltip: 'Menu',
              onPressed: onMenuPressed,
              icon: const Icon(Icons.menu_rounded),
            ),
          Text(
            _titleFor(admin.section),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          if (MediaQuery.sizeOf(context).width > 760)
            SizedBox(
              width: 260,
              child: TextField(
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search data...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: AppColors.outlineVariant,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: AppColors.outlineVariant,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(width: 12),
          IconButton(
            tooltip: 'Notificaciones',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          Tooltip(
            message: admin.isDarkMode ? 'Modo claro' : 'Modo oscuro',
            child: Switch(
              value: admin.isDarkMode,
              onChanged: admin.toggleDarkMode,
            ),
          ),
          if (MediaQuery.sizeOf(context).width > 1040) ...[
            const SizedBox(width: 8),
            Chip(
              avatar: const Icon(Icons.calendar_today_rounded, size: 16),
              label: Text('${now.day}/${now.month}/${now.year}'),
            ),
            const SizedBox(width: 8),
            Chip(
              avatar: const Icon(Icons.verified_user_rounded, size: 16),
              label: Text(auth.role),
            ),
          ],
          IconButton(
            tooltip: 'Salir',
            onPressed: context.read<AuthController>().signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
    );
  }

  String _titleFor(AdminSection section) {
    return switch (section) {
      AdminSection.dashboard => 'Dashboard',
      AdminSection.users => 'Gestion',
      AdminSection.tokens => 'Tokens',
      AdminSection.settings => 'Configuracion',
    };
  }
}
