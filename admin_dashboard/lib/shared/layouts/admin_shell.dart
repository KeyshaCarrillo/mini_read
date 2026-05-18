import 'package:flutter/material.dart';

import '../../core/responsive/breakpoints.dart';
import '../../routes/app_routes.dart';
import 'admin_sidebar.dart';
import 'admin_topbar.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key, required this.child, required this.isDark, required this.onThemeToggle, required this.activeRoute, required this.onRouteSelected});

  final Widget child;
  final bool isDark;
  final VoidCallback onThemeToggle;
  final AdminRoute activeRoute;
  final ValueChanged<AdminRoute> onRouteSelected;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  bool collapsed = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final shouldCollapse = width < AdminBreakpoints.laptop;
    return Scaffold(
      body: Row(
        children: [
          AdminSidebar(
            collapsed: collapsed || shouldCollapse,
            activeRoute: widget.activeRoute,
            onRouteSelected: widget.onRouteSelected,
            onToggle: () => setState(() => collapsed = !collapsed),
          ),
          Expanded(
            child: Column(
              children: [
                AdminTopbar(title: widget.activeRoute.label, isDark: widget.isDark, onThemeToggle: widget.onThemeToggle),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
