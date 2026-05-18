import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/admin_controller.dart';
import '../core/constants.dart';
import '../core/formatters.dart';
import '../models/token_transaction.dart';

class TokenHistoryScreen extends StatelessWidget {
  const TokenHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<AdminController>().transactions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Historial de Tokens',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Auditoria cronologica de recompensas, consumos de IA y movimientos de perfiles.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 620,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: DataTable2(
                minWidth: 920,
                columnSpacing: 16,
                headingRowColor: WidgetStateProperty.all(
                  AppColors.surfaceContainerLow,
                ),
                empty: const Center(
                  child: Text('No hay transacciones registradas.'),
                ),
                columns: const [
                  DataColumn2(label: Text('Transaccion'), size: ColumnSize.L),
                  DataColumn(label: Text('Tipo')),
                  DataColumn(label: Text('Monto')),
                  DataColumn2(label: Text('Usuario'), size: ColumnSize.L),
                  DataColumn(label: Text('Fecha')),
                ],
                rows: [
                  for (final transaction in transactions)
                    DataRow2(
                      onTap: () => _showTransactionDetail(context, transaction),
                      cells: [
                        DataCell(Text(transaction.id)),
                        DataCell(_TypeChip(transaction: transaction)),
                        DataCell(
                          Text(
                            '${transaction.amount > 0 ? '+' : ''}${transaction.amount}',
                            style: TextStyle(
                              color: transaction.amount >= 0
                                  ? AppColors.secondary
                                  : AppColors.error,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        DataCell(Text(transaction.uid)),
                        DataCell(Text(formatDateTime(transaction.createdAt))),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final TokenTransaction transaction;

  const _TypeChip({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        transaction.isReward
            ? Icons.add_circle_outline_rounded
            : Icons.remove_circle_outline_rounded,
        size: 18,
      ),
      label: Text(transaction.label),
      backgroundColor: transaction.isReward
          ? AppColors.secondaryContainer.withValues(alpha: 0.45)
          : AppColors.primary.withValues(alpha: 0.08),
    );
  }
}

void _showTransactionDetail(
  BuildContext context,
  TokenTransaction transaction,
) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Detalle de transaccion'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(label: 'ID', value: transaction.id),
            _DetailRow(label: 'Usuario', value: transaction.uid),
            _DetailRow(label: 'Perfil', value: transaction.profileId),
            _DetailRow(
              label: 'Libro',
              value: transaction.bookId.isEmpty
                  ? 'No aplica'
                  : transaction.bookId,
            ),
            _DetailRow(label: 'Tipo de recompensa', value: transaction.label),
            _DetailRow(
              label: 'Movimiento',
              value: '${transaction.amount} tokens',
            ),
            _DetailRow(
              label: 'Fecha',
              value: formatDateTime(transaction.createdAt),
            ),
            const SizedBox(height: 12),
            Text(
              transaction.isReward
                  ? 'Este movimiento agrego tokens al perfil del usuario.'
                  : 'Este movimiento consumio tokens, normalmente por una consulta de IA.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(child: SelectableText(value.isEmpty ? 'Sin dato' : value)),
        ],
      ),
    );
  }
}
