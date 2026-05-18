import 'package:flutter/material.dart';

import '../controllers/admin_dashboard_controller.dart';
import 'admin_design_tokens.dart';

class AdminScaffold extends StatelessWidget {
  const AdminScaffold({super.key, required this.controller, required this.child});

  final AdminDashboardController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          _Sidebar(controller: controller),
          Expanded(
            child: Column(
              children: [
                _TopBar(controller: controller),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItemData(AdminModule.dashboard, 'Dashboard General', Icons.dashboard_customize_rounded),
      _NavItemData(AdminModule.users, 'Gestión de Usuarios', Icons.manage_accounts_rounded),
      _NavItemData(AdminModule.tokens, 'Historial de Tokens', Icons.generating_tokens_rounded),
      _NavItemData(AdminModule.settings, 'Configuración', Icons.settings_rounded),
    ];

    return Container(
      width: 260,
      color: StitchAdminColors.deepBlue,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: .18)),
                    ),
                    child: const Icon(Icons.auto_stories_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mini Read', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
                        SizedBox(height: 2),
                        Text('Admin Center', style: TextStyle(color: Color(0xFFD9DAFF), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ...items.map((item) => _SidebarButton(
                    item: item,
                    selected: controller.selectedModule == item.module,
                    onTap: () => controller.selectModule(item.module),
                  )),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: StitchAdminColors.goldContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.workspace_premium_rounded, color: StitchAdminColors.gold),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text('Panel exclusivo para administradores', style: TextStyle(color: StitchAdminColors.gold, fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarButton extends StatefulWidget {
  const _SidebarButton({required this.item, required this.selected, required this.onTap});

  final _NavItemData item;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_SidebarButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<_SidebarButton> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => hovered = true),
        onExit: (_) => setState(() => hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: active ? Colors.white : hovered ? Colors.white.withValues(alpha: .10) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(widget.item.icon, color: active ? StitchAdminColors.deepBlue : Colors.white.withValues(alpha: .82), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: TextStyle(
                      color: active ? StitchAdminColors.deepBlue : Colors.white.withValues(alpha: .88),
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 14,
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _titleFor(controller.selectedModule),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(
            width: 320,
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: 'Buscar usuarios, libros o tokens...',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
              ),
            ),
          ),
          const SizedBox(width: 18),
          const Icon(Icons.notifications_none_rounded),
          const SizedBox(width: 18),
          Row(
            children: [
              const Icon(Icons.dark_mode_outlined, size: 18),
              Switch(value: controller.isDarkMode, onChanged: controller.toggleTheme),
            ],
          ),
          const SizedBox(width: 8),
          const CircleAvatar(backgroundColor: StitchAdminColors.deepBlue, child: Text('AD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }

  String _titleFor(AdminModule module) => switch (module) {
        AdminModule.dashboard => 'Dashboard General',
        AdminModule.users => 'Gestión de Usuarios y Libros',
        AdminModule.tokens => 'Historial de Tokens',
        AdminModule.settings => 'Configuración',
      };
}

class _NavItemData {
  const _NavItemData(this.module, this.label, this.icon);
  final AdminModule module;
  final String label;
  final IconData icon;
}
