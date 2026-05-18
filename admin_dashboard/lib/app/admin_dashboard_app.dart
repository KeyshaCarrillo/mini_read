import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../core/config/app_config.dart';
import '../core/responsive/breakpoints.dart';
import '../core/theme/app_theme.dart';
import '../features/dashboard/presentation/dashboard_overview_page.dart';
import '../features/settings/settings_page.dart';
import '../features/tokens/token_history_page.dart';
import '../features/users/users_books_page.dart';
import '../routes/app_routes.dart';
import '../shared/layouts/admin_shell.dart';

class AdminDashboardApp extends StatefulWidget {
  const AdminDashboardApp({super.key});

  @override
  State<AdminDashboardApp> createState() => _AdminDashboardAppState();
}

class _AdminDashboardAppState extends State<AdminDashboardApp> {
  ThemeMode themeMode = ThemeMode.system;
  AdminRoute activeRoute = AdminRoutes.dashboard;

  bool get _isDark {
    final platform = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return themeMode == ThemeMode.dark || (themeMode == ThemeMode.system && platform == Brightness.dark);
  }

  Widget get _activePage => switch (activeRoute.path) {
        '/users' => const UsersBooksPage(),
        '/tokens' => const TokenHistoryPage(),
        '/settings' => const SettingsPage(),
        _ => const DashboardOverviewPage(),
      };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.light(),
      darkTheme: AdminTheme.dark(),
      themeMode: themeMode,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: const [
          Breakpoint(start: 0, end: AdminBreakpoints.tablet - 1, name: MOBILE),
          Breakpoint(start: AdminBreakpoints.tablet, end: AdminBreakpoints.laptop - 1, name: TABLET),
          Breakpoint(start: AdminBreakpoints.laptop, end: AdminBreakpoints.desktop - 1, name: DESKTOP),
          Breakpoint(start: AdminBreakpoints.desktop, end: double.infinity, name: 'WIDE'),
        ],
      ),
      home: AdminShell(
        activeRoute: activeRoute,
        onRouteSelected: (route) => setState(() => activeRoute = route),
        isDark: _isDark,
        onThemeToggle: () => setState(() => themeMode = _isDark ? ThemeMode.light : ThemeMode.dark),
        child: _activePage,
      ),
    );
  }
}
