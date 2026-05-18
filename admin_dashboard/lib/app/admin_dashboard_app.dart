import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../core/config/app_config.dart';
import '../core/responsive/breakpoints.dart';
import '../core/theme/app_theme.dart';
import '../features/admin/controllers/admin_dashboard_controller.dart';
import '../features/admin/views/dashboard_general_view.dart';
import '../features/admin/views/settings_view.dart';
import '../features/admin/views/tokens_history_view.dart';
import '../features/admin/views/users_books_view.dart';
import '../features/admin/widgets/admin_scaffold.dart';

class AdminDashboardApp extends StatefulWidget {
  const AdminDashboardApp({super.key});

  @override
  State<AdminDashboardApp> createState() => _AdminDashboardAppState();
}

class _AdminDashboardAppState extends State<AdminDashboardApp> {
  late final AdminDashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = AdminDashboardController()..loadInitialData();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          theme: AdminTheme.light(),
          darkTheme: AdminTheme.dark(),
          themeMode: controller.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) => ResponsiveBreakpoints.builder(
            child: child!,
            breakpoints: const [
              Breakpoint(start: 0, end: AdminBreakpoints.tablet - 1, name: MOBILE),
              Breakpoint(start: AdminBreakpoints.tablet, end: AdminBreakpoints.laptop - 1, name: TABLET),
              Breakpoint(start: AdminBreakpoints.laptop, end: AdminBreakpoints.desktop - 1, name: DESKTOP),
              Breakpoint(start: AdminBreakpoints.desktop, end: double.infinity, name: 'WIDE'),
            ],
          ),
          home: AdminScaffold(controller: controller, child: _viewForSelectedModule()),
        );
      },
    );
  }

  Widget _viewForSelectedModule() => switch (controller.selectedModule) {
        AdminModule.dashboard => DashboardGeneralView(controller: controller),
        AdminModule.users => UsersBooksView(controller: controller),
        AdminModule.tokens => TokensHistoryView(controller: controller),
        AdminModule.settings => SettingsView(controller: controller),
      };
}
