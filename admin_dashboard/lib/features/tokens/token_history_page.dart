import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/models/admin_models.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/components/premium_panel.dart';
import '../../../shared/components/section_header.dart';
import '../../../shared/components/status_badge.dart';
import '../../../shared/extensions/context_extensions.dart';

class TokenHistoryPage extends ConsumerWidget {
  const TokenHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(tokenTransactionsProvider);
    return ColoredBox(
      color: context.theme.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        padding: AppSpacing.page,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Historial de Tokens', style: context.text.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Auditoría cronológica desde /api/admin/token_transactions.', style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.lg),
          PremiumPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionHeader(title: 'Actividad reciente', subtitle: 'Haz clic en una fila para abrir el detalle completo del movimiento'),
            const SizedBox(height: 16),
            SizedBox(
              height: 560,
              child: transactions.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('No se pudieron cargar transacciones. Revisa ADMIN_AUTH_TOKEN.\n$error', textAlign: TextAlign.center)),
                data: (rows) => DataTable2(
                  fixedTopRows: 1,
                  columnSpacing: 20,
                  columns: const [
                    DataColumn2(label: Text('FECHA')),
                    DataColumn2(label: Text('USUARIO'), size: ColumnSize.L),
                    DataColumn2(label: Text('TIPO')),
                    DataColumn2(label: Text('RECOMPENSA')),
                    DataColumn2(label: Text('TOKENS')),
                    DataColumn2(label: Text('ESTADO')),
                  ],
                  rows: rows.map((tx) => DataRow2(onTap: () => _showTransaction(context, tx), cells: [
                    DataCell(Text(_formatDate(tx.createdAt))),
                    DataCell(Text(tx.user, overflow: TextOverflow.ellipsis)),
                    DataCell(Text(tx.type)),
                    DataCell(Text(tx.rewardType)),
                    DataCell(Text(tx.amount.toString(), style: TextStyle(fontWeight: FontWeight.w900, color: tx.amount >= 0 ? const Color(0xFF10B981) : const Color(0xFFF43F5E)))),
                    DataCell(StatusBadge(label: tx.amount >= 0 ? 'Success' : 'Review')),
                  ])).toList(),
                ),
              ),
            ),
          ])),
        ]),
      ),
    );
  }

  void _showTransaction(BuildContext context, TokenTransaction tx) {
    showDialog<void>(context: context, builder: (context) => AlertDialog(
      title: const Text('Detalle de transacción'),
      content: SizedBox(width: 460, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Detail(label: 'ID de transacción', value: tx.id),
        _Detail(label: 'Usuario', value: tx.user),
        _Detail(label: 'Tipo', value: tx.type),
        _Detail(label: 'Tipo de recompensa', value: tx.rewardType),
        _Detail(label: 'Tokens', value: tx.amount.toString()),
        _Detail(label: 'Fecha', value: _formatDate(tx.createdAt)),
        _Detail(label: 'Descripción', value: tx.description.isEmpty ? 'Sin descripción en Firebase' : tx.description),
      ])),
      actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
    ));
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        SelectableText(value, style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return 'Sin fecha';
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
