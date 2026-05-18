import 'package:flutter/material.dart';

import '../controllers/admin_dashboard_controller.dart';
import '../widgets/admin_cards.dart';
import '../widgets/admin_design_tokens.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          AdminPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Configuración del Centro Administrativo', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 18),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Cambia inmediatamente el tema del dashboard web.'),
                  value: controller.isDarkMode,
                  onChanged: controller.toggleTheme,
                ),
                const Divider(height: 30),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(backgroundColor: StitchAdminColors.deepBlue, child: Icon(Icons.api_rounded, color: Colors.white)),
                  title: const Text('Backend conectado'),
                  subtitle: const Text('https://book-api-nu-six.vercel.app'),
                  trailing: FilledButton.icon(onPressed: controller.refresh, icon: const Icon(Icons.sync_rounded), label: const Text('Sincronizar')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
