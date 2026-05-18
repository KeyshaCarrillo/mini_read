import 'package:flutter/material.dart';

class AdminRoute {
  const AdminRoute({required this.path, required this.label, required this.icon});
  final String path;
  final String label;
  final IconData icon;
}

abstract final class AdminRoutes {
  static const dashboard = AdminRoute(path: '/dashboard', label: 'Dashboard General', icon: Icons.grid_view_rounded);
  static const users = AdminRoute(path: '/users', label: 'Gestión de Usuarios', icon: Icons.group_outlined);
  static const tokens = AdminRoute(path: '/tokens', label: 'Historial de Tokens', icon: Icons.generating_tokens_outlined);
  static const settings = AdminRoute(path: '/settings', label: 'Configuración', icon: Icons.tune_rounded);

  static const primary = [dashboard, users, tokens];
  static const utility = [settings];
}
