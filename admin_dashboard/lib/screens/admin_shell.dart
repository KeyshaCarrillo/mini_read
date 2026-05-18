import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/admin_controller.dart';
import '../core/constants.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_topbar.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';
import 'token_history_screen.dart';
import 'users_books_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();
    final isCompact = MediaQuery.sizeOf(context).width < 900;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isCompact
          ? const Drawer(child: AdminSidebar(compact: true))
          : null,
      floatingActionButton: admin.section == AdminSection.users
          ? FloatingActionButton.extended(
              onPressed: () => showAddBookDialog(context),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Anadir Libro'),
            )
          : null,
      body: Row(
        children: [
          if (!isCompact)
            const SizedBox(
              width: AppConstants.sidebarWidth,
              child: AdminSidebar(),
            ),
          Expanded(
            child: Column(
              children: [
                AdminTopbar(
                  showMenu: isCompact,
                  onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: admin.loadAll,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(isCompact ? 16 : 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (admin.errorMessage != null)
                            _ErrorBanner(message: admin.errorMessage!),
                          if (admin.isLoading)
                            const LinearProgressIndicator(minHeight: 2),
                          const SizedBox(height: 16),
                          _ActiveSection(section: admin.section),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveSection extends StatelessWidget {
  final AdminSection section;

  const _ActiveSection({required this.section});

  @override
  Widget build(BuildContext context) {
    return switch (section) {
      AdminSection.dashboard => const DashboardScreen(),
      AdminSection.users => const UsersBooksScreen(),
      AdminSection.tokens => const TokenHistoryScreen(),
      AdminSection.settings => const SettingsScreen(),
    };
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message, style: TextStyle(color: scheme.onErrorContainer)),
    );
  }
}
