import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../controllers/admin_dashboard_controller.dart';
import '../models/admin_entities.dart';
import '../widgets/admin_cards.dart';

class TokensHistoryView extends StatelessWidget {
  const TokensHistoryView({super.key, required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: AdminPanel(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Actividad reciente de tokens', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text('Haz clic en cualquier fila para ver el detalle completo del movimiento.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ]),
                  ),
                  IconButton.filledTonal(onPressed: controller.refresh, icon: const Icon(Icons.refresh_rounded)),
                ],
              ),
            ),
            SizedBox(
              height: 560,
              child: DataTable2(
                fixedTopRows: 1,
                headingRowHeight: 46,
                dataRowHeight: 62,
                horizontalMargin: 22,
                columnSpacing: 18,
                border: TableBorder(top: BorderSide(color: Theme.of(context).dividerColor), horizontalInside: BorderSide(color: Theme.of(context).dividerColor)),
                columns: const [
                  DataColumn2(label: Text('ID'), size: ColumnSize.M),
                  DataColumn2(label: Text('USUARIO'), size: ColumnSize.L),
                  DataColumn2(label: Text('TIPO'), size: ColumnSize.M),
                  DataColumn2(label: Text('RECOMPENSA'), size: ColumnSize.L),
                  DataColumn2(label: Text('TOKENS'), size: ColumnSize.S),
                  DataColumn2(label: Text('FECHA'), size: ColumnSize.M),
                ],
                rows: controller.tokenTransactions.map((transaction) => DataRow2(
                      onTap: () => _showDetail(context, transaction),
                      cells: [
                        DataCell(Text(transaction.id.isEmpty ? '—' : transaction.id, overflow: TextOverflow.ellipsis)),
                        DataCell(Text(transaction.user, overflow: TextOverflow.ellipsis)),
                        DataCell(Text(transaction.type)),
                        DataCell(Text(transaction.rewardType, overflow: TextOverflow.ellipsis)),
                        DataCell(Text('${transaction.amount}', style: TextStyle(color: transaction.amount >= 0 ? const Color(0xFF059669) : Colors.red, fontWeight: FontWeight.w900))),
                        DataCell(Text(_formatDate(transaction.createdAt))),
                      ],
                    )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, TokenTransaction transaction) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalle de transacción'),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailLine(label: 'ID de transacción', value: transaction.id.isEmpty ? 'Sin ID' : transaction.id),
              _DetailLine(label: 'Usuario', value: transaction.user),
              _DetailLine(label: 'Tipo', value: transaction.type),
              _DetailLine(label: 'Tipo de recompensa', value: transaction.rewardType),
              _DetailLine(label: 'Cantidad', value: '${transaction.amount} tokens'),
              _DetailLine(label: 'Fecha', value: _formatDate(transaction.createdAt)),
            ],
          ),
        ),
        actions: [FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar'))],
      ),
    );
  }

  String _formatDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)} ${two(date.hour)}:${two(date.minute)}';
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ]),
    );
  }
}
