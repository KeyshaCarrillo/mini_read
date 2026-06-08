import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/admin_controller.dart';
import '../controllers/auth_controller.dart';
import '../core/constants.dart';

class AdminTopbar extends StatefulWidget {
  final bool showMenu;
  final VoidCallback onMenuPressed;

  const AdminTopbar({
    super.key,
    required this.showMenu,
    required this.onMenuPressed,
  });

  @override
  State<AdminTopbar> createState() => _AdminTopbarState();
}

class _AdminTopbarState extends State<AdminTopbar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final searchInput = context.read<AdminController>().searchInput;
    if (_searchController.text == searchInput) return;
    _searchController.value = TextEditingValue(
      text: searchInput,
      selection: TextSelection.collapsed(offset: searchInput.length),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final section = context.select((AdminController c) => c.section);
    final isDarkMode = context.select((AdminController c) => c.isDarkMode);
    final isSearchPending = context.select(
      (AdminController c) => c.isSearchPending,
    );
    final searchInput = context.select((AdminController c) => c.searchInput);
    final auth = context.watch<AuthController>();
    final now = DateTime.now();
    final textTheme = Theme.of(context).textTheme;
    final hasQuery = searchInput.trim().isNotEmpty;

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
          if (widget.showMenu)
            IconButton(
              tooltip: 'Menú',
              onPressed: widget.onMenuPressed,
              icon: const Icon(Icons.menu_rounded),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _titleFor(section),
                  style: textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _subtitleFor(section),
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
                controller: _searchController,
                onChanged: context.read<AdminController>().updateSearchInput,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Buscar libros o usuarios...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: hasQuery || isSearchPending
                      ? Padding(
                          padding: const EdgeInsetsDirectional.only(end: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSearchPending)
                                const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              if (hasQuery)
                                IconButton(
                                  tooltip: 'Limpiar busqueda',
                                  onPressed: () {
                                    _searchController.clear();
                                    context
                                        .read<AdminController>()
                                        .clearSearch();
                                  },
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                  ),
                                ),
                            ],
                          ),
                        )
                      : null,
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
            message: isDarkMode ? 'Modo claro' : 'Modo oscuro',
            child: Switch(
              value: isDarkMode,
              onChanged: context.read<AdminController>().toggleDarkMode,
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
      AdminSection.users => 'Gestión de Usuarios y Libros',
      AdminSection.tokens => 'Historial de Tokens',
      AdminSection.settings => 'Configuración General',
    };
  }

  String _subtitleFor(AdminSection section) {
    return switch (section) {
      AdminSection.dashboard => 'Resumen en tiempo real de la plataforma.',
      AdminSection.tokens => 'Monitorea movimientos y auditoria de tokens.',
      AdminSection.settings =>
        'Personaliza parametros del panel administrativo.',
      _ => 'Administra usuarios, perfiles y catalogo de libros.',
    };
  }
}
