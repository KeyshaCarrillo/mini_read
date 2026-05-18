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
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: const Border(
          bottom: BorderSide(color: AppColors.outlineVariant),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1200114C),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showMenu)
            IconButton(
              tooltip: 'Menu',
              onPressed: onMenuPressed,
              icon: const Icon(Icons.menu_rounded),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _titleFor(admin.section),
                  style: textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _subtitleFor(admin.section),
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (MediaQuery.sizeOf(context).width > 760)
            SizedBox(
              width: 300,
              child: TextField(
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Buscar usuarios, libros, tokens...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF3F5FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.outlineVariant,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.outlineVariant,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.3,
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
              backgroundColor: const Color(0xFFF2F4FF),
              avatar: const Icon(Icons.calendar_today_rounded, size: 16),
              label: Text('${now.day}/${now.month}/${now.year}'),
            ),
            const SizedBox(width: 8),
            Chip(
              backgroundColor: const Color(0xFFEAF0FF),
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
      AdminSection.dashboard => 'Dashboard Ejecutivo',
      AdminSection.users => 'Gestion de Usuarios y Libros',
      AdminSection.tokens => 'Historial de Tokens',
      AdminSection.settings => 'Configuracion General',
    };
  }

  String _subtitleFor(AdminSection section) {
    return switch (section) {
      AdminSection.dashboard => 'Resumen en tiempo real de la plataforma.',
      AdminSection.users =>
        'Administra perfiles, permisos, premium y contenido desde un solo lugar.',
      AdminSection.tokens => 'Monitorea movimientos y auditoria de tokens.',
      AdminSection.settings =>
        'Personaliza parametros del panel administrativo.',
    };
  }
}
