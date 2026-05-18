import 'package:flutter/material.dart';

class AdminRoute {
  const AdminRoute({required this.path, required this.label, required this.icon});
  final String path;
  final String label;
  final IconData icon;
}

abstract final class AdminRoutes {
  static const dashboard = AdminRoute(path: '/dashboard', label: 'Overview', icon: Icons.grid_view_rounded);
  static const analytics = AdminRoute(path: '/analytics', label: 'Analytics', icon: Icons.query_stats_rounded);
  static const users = AdminRoute(path: '/users', label: 'Users', icon: Icons.group_outlined);
  static const reports = AdminRoute(path: '/reports', label: 'Reports', icon: Icons.description_outlined);
  static const tokens = AdminRoute(path: '/tokens', label: 'Tokens', icon: Icons.generating_tokens_outlined);
  static const activity = AdminRoute(path: '/activity', label: 'Activity', icon: Icons.timeline_rounded);
  static const settings = AdminRoute(path: '/settings', label: 'Settings', icon: Icons.tune_rounded);

  static const primary = [dashboard, analytics, users, reports, tokens, activity];
  static const utility = [settings];
}
