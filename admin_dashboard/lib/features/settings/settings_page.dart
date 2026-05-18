import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/services/admin_api_service.dart';
import '../../shared/components/premium_panel.dart';
import '../../shared/components/section_header.dart';
import '../../shared/extensions/context_extensions.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hasToken = const String.fromEnvironment('ADMIN_AUTH_TOKEN').trim().isNotEmpty;
    return ColoredBox(
      color: context.theme.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        padding: AppSpacing.page,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Configuración', style: context.text.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.lg),
          PremiumPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionHeader(title: 'Conexión API/Firebase', subtitle: 'Dashboard independiente Flutter Web para administradores'),
            const SizedBox(height: 18),
            _Row(label: 'Base URL', value: AdminApiService.baseUrl),
            _Row(label: 'Token admin', value: hasToken ? 'Configurado por --dart-define=ADMIN_AUTH_TOKEN' : 'Pendiente: los endpoints admin requieren Bearer token Firebase'),
            _Row(label: 'Libros públicos', value: 'GET /api/books funciona sin token para mostrar inventario'),
            _Row(label: 'Colecciones admin', value: 'users, token_transactions, ia_chats'),
          ])),
        ]),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 150, child: Text(label, style: context.text.labelLarge?.copyWith(fontWeight: FontWeight.w900))),
        Expanded(child: SelectableText(value, style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant))),
      ]),
    );
  }
}
