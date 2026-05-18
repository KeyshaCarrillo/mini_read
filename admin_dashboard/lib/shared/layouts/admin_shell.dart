import 'package:flutter/material.dart';

import '../../core/responsive/breakpoints.dart';
import 'admin_sidebar.dart';
import 'admin_topbar.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key, required this.child, required this.isDark, required this.onThemeToggle});

  final Widget child;
  final bool isDark;
  final VoidCallback onThemeToggle;

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
          AdminSidebar(collapsed: collapsed || shouldCollapse, onToggle: () => setState(() => collapsed = !collapsed)),
          Expanded(
            child: Column(
              children: [
                AdminTopbar(isDark: widget.isDark, onThemeToggle: widget.onThemeToggle),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
