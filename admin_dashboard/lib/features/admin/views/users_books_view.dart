import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../controllers/admin_dashboard_controller.dart';
import '../models/admin_entities.dart';
import '../widgets/admin_cards.dart';
import '../widgets/admin_design_tokens.dart';

class UsersBooksView extends StatelessWidget {
  const UsersBooksView({super.key, required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: StitchAdminColors.deepBlue,
        foregroundColor: Colors.white,
        onPressed: () => _showAddBookDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Añadir Libro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminPanel(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Usuarios administrados', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                              const SizedBox(height: 5),
                              Text('Acciones rápidas con PATCH a /api/admin/users/:docId.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        IconButton.filledTonal(onPressed: controller.refresh, icon: const Icon(Icons.refresh_rounded)),
                      ],
                    ),
                  ),
                  SizedBox(height: 430, child: _UsersTable(controller: controller)),
                ],
              ),
            ),
            const SizedBox(height: 22),
            AdminPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('Inventario de libros (${controller.books.length})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900))),
                      FilledButton.icon(onPressed: () => _showAddBookDialog(context), icon: const Icon(Icons.add_rounded), label: const Text('Añadir Libro')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: controller.books.take(18).map((book) => _BookChip(book: book)).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddBookDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final id = TextEditingController();
    final title = TextEditingController();
    final category = TextEditingController();
    final pages = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Añadir nuevo libro'),
        content: SizedBox(
          width: 440,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: id, decoration: const InputDecoration(labelText: 'ID del libro'), validator: _required),
                const SizedBox(height: 12),
                TextFormField(controller: title, decoration: const InputDecoration(labelText: 'Título'), validator: _required),
                const SizedBox(height: 12),
                TextFormField(controller: category, decoration: const InputDecoration(labelText: 'Categoría'), validator: _required),
                const SizedBox(height: 12),
                TextFormField(controller: pages, decoration: const InputDecoration(labelText: 'Páginas'), keyboardType: TextInputType.number, validator: _required),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(dialogContext);
              await controller.addBook(AdminBook(id: id.text.trim(), title: title.text.trim(), category: category.text.trim(), pages: int.tryParse(pages.text.trim()) ?? 0));
              navigator.pop();
              messenger.showSnackBar(const SnackBar(content: Text('Libro enviado correctamente.')));
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Campo requerido' : null;
}

class _UsersTable extends StatelessWidget {
  const _UsersTable({required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return DataTable2(
      fixedTopRows: 1,
      headingRowHeight: 46,
      dataRowHeight: 68,
      horizontalMargin: 22,
      columnSpacing: 18,
      border: TableBorder(top: BorderSide(color: Theme.of(context).dividerColor), horizontalInside: BorderSide(color: Theme.of(context).dividerColor)),
      columns: const [
        DataColumn2(label: Text('USUARIO'), size: ColumnSize.L),
        DataColumn2(label: Text('PLAN'), size: ColumnSize.S),
        DataColumn2(label: Text('TOKENS'), size: ColumnSize.S),
        DataColumn2(label: Text('ESTADO'), size: ColumnSize.S),
        DataColumn2(label: Text('ACCIONES'), size: ColumnSize.L),
      ],
      rows: controller.users.map((user) => DataRow2(cells: [
            DataCell(Row(children: [
              CircleAvatar(backgroundColor: StitchAdminColors.deepBlue.withValues(alpha: .10), child: Text(_initials(user.name), style: const TextStyle(color: StitchAdminColors.deepBlue, fontWeight: FontWeight.w900))),
              const SizedBox(width: 12),
              Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(user.email, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ])),
            ])),
            DataCell(user.isPremium ? const PremiumBadge(label: 'Premium') : const Text('Free')),
            DataCell(Text('${user.tokens}')),
            DataCell(Text(user.status, style: TextStyle(color: user.isBanned ? Colors.red : const Color(0xFF059669), fontWeight: FontWeight.w800))),
            DataCell(Wrap(spacing: 8, children: [
              OutlinedButton(onPressed: user.isPremium ? null : () => controller.makePremium(user), child: const Text('Hacer Premium')),
              TextButton(onPressed: user.isBanned ? null : () => controller.banUser(user), child: const Text('Banear')),
            ])),
          ])).toList(),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }
}

class _BookChip extends StatelessWidget {
  const _BookChip({required this.book});

  final AdminBook book;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor), borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text('${book.category} • ${book.pages} páginas', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]),
    );
  }
}
