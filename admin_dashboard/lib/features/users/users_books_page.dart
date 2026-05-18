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

class UsersBooksPage extends ConsumerWidget {
  const UsersBooksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);
    final books = ref.watch(booksProvider);
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBookDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Añadir Libro'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.page,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Gestión de Usuarios y Libros', style: context.text.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Datos reales consumidos desde Firebase mediante la API administrativa.', style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.lg),
          _UsersTable(users: users),
          const SizedBox(height: AppSpacing.lg),
          _BooksInventory(books: books),
          const SizedBox(height: 72),
        ]),
      ),
    );
  }
}

class _UsersTable extends ConsumerWidget {
  const _UsersTable({required this.users});
  final AsyncValue<List<AdminUser>> users;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PremiumPanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader(title: 'Tabla de usuarios administrados', subtitle: 'PATCH /api/admin/users/:docId para premium o baneo'),
        const SizedBox(height: 16),
        SizedBox(
          height: 430,
          child: users.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _AuthError(message: error.toString()),
            data: (rows) => DataTable2(
              fixedTopRows: 1,
              columns: const [
                DataColumn2(label: Text('USUARIO'), size: ColumnSize.L),
                DataColumn2(label: Text('ROL')),
                DataColumn2(label: Text('PLAN')),
                DataColumn2(label: Text('TOKENS')),
                DataColumn2(label: Text('ACCIÓN'), size: ColumnSize.L),
              ],
              rows: rows.map((user) => DataRow2(cells: [
                    DataCell(Row(children: [
                      CircleAvatar(radius: 17, backgroundColor: context.colors.primary.withValues(alpha: .10), child: Text(user.initials, style: TextStyle(color: context.colors.primary, fontWeight: FontWeight.w900, fontSize: 11))),
                      const SizedBox(width: 10),
                      Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(user.name, style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w800)),
                        Text(user.email, overflow: TextOverflow.ellipsis, style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant)),
                      ])),
                    ])),
                    DataCell(Text(user.role)),
                    DataCell(StatusBadge(label: user.isPremium ? 'Premium' : user.plan)),
                    DataCell(Text(user.tokens.toString())),
                    DataCell(Wrap(spacing: 8, children: [
                      FilledButton.tonal(onPressed: () => _patchUser(context, ref, user.id, {'isPremium': true, 'plan': 'Premium'}), child: const Text('Hacer Premium')),
                      OutlinedButton(onPressed: () => _patchUser(context, ref, user.id, {'isBanned': !user.isBanned}), child: Text(user.isBanned ? 'Desbanear' : 'Banear')),
                    ])),
                  ])).toList(),
            ),
          ),
        ),
      ]),
    );
  }
}

class _BooksInventory extends ConsumerWidget {
  const _BooksInventory({required this.books});
  final AsyncValue<List<AdminBook>> books;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PremiumPanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader(title: 'Inventario de libros', subtitle: 'GET/POST/PATCH/DELETE /api/books conectado al backend'),
        const SizedBox(height: 16),
        books.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
          error: (error, _) => Center(child: Text('No se pudieron cargar libros: $error')),
          data: (rows) => LayoutBuilder(builder: (context, constraints) {
            final columns = constraints.maxWidth > 1100 ? 4 : constraints.maxWidth > 760 ? 3 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rows.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 14, mainAxisSpacing: 14, mainAxisExtent: 176),
              itemBuilder: (context, index) {
                final book = rows[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [Icon(Icons.menu_book_rounded, color: context.colors.primary), const Spacer(), Text('${book.pages} pág.', style: context.text.labelSmall)]),
                      const SizedBox(height: 12),
                      Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text(book.category, style: context.text.labelMedium?.copyWith(color: context.colors.onSurfaceVariant)),
                      const Spacer(),
                      Row(children: [
                        TextButton(onPressed: () => _showBookDialog(context, ref, book: book), child: const Text('Editar')),
                        const Spacer(),
                        IconButton(onPressed: () => _deleteBook(context, ref, book), icon: const Icon(Icons.delete_outline_rounded)),
                      ]),
                    ]),
                  ),
                );
              },
            );
          }),
        ),
      ]),
    );
  }
}

class _AuthError extends StatelessWidget {
  const _AuthError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text('La API administrativa requiere token Firebase admin. Ejecuta con --dart-define=ADMIN_AUTH_TOKEN=<idToken>.\n\n$message', textAlign: TextAlign.center),
    ));
  }
}

Future<void> _patchUser(BuildContext context, WidgetRef ref, String docId, Map<String, dynamic> values) async {
  try {
    await ref.read(adminApiServiceProvider).patchUser(docId, values);
    ref.invalidate(usersProvider);
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario actualizado en Firebase.')));
  } catch (error) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo actualizar: $error')));
  }
}

Future<void> _deleteBook(BuildContext context, WidgetRef ref, AdminBook book) async {
  try {
    await ref.read(adminApiServiceProvider).deleteBook(book.id);
    ref.invalidate(booksProvider);
    ref.invalidate(dashboardSnapshotProvider);
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${book.title} eliminado.')));
  } catch (error) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo eliminar: $error')));
  }
}

Future<void> _showBookDialog(BuildContext context, WidgetRef ref, {AdminBook? book}) async {
  final id = TextEditingController(text: book?.id ?? '');
  final title = TextEditingController(text: book?.title ?? '');
  final category = TextEditingController(text: book?.category ?? 'Niños');
  final pages = TextEditingController(text: (book?.pages ?? 12).toString());
  final author = TextEditingController(text: book?.author ?? '');
  final formKey = GlobalKey<FormState>();

  await showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
    title: Text(book == null ? 'Añadir Libro' : 'Editar Libro'),
    content: SizedBox(width: 480, child: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
      TextFormField(controller: id, enabled: book == null, decoration: const InputDecoration(labelText: 'ID del documento'), validator: (value) => (value == null || value.isEmpty) ? 'Obligatorio' : null),
      TextFormField(controller: title, decoration: const InputDecoration(labelText: 'Título'), validator: (value) => (value == null || value.isEmpty) ? 'Obligatorio' : null),
      TextFormField(controller: category, decoration: const InputDecoration(labelText: 'Categoría')),
      TextFormField(controller: pages, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Páginas')),
      TextFormField(controller: author, decoration: const InputDecoration(labelText: 'Autor/a')),
    ]))),
    actions: [
      TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
      FilledButton(onPressed: () async {
        if (!formKey.currentState!.validate()) return;
        final payload = AdminBook(id: id.text.trim(), title: title.text.trim(), category: category.text.trim(), pages: int.tryParse(pages.text) ?? 0, author: author.text.trim());
        try {
          if (book == null) {
            await ref.read(adminApiServiceProvider).createBook(payload);
          } else {
            await ref.read(adminApiServiceProvider).updateBook(payload);
          }
          ref.invalidate(booksProvider);
          ref.invalidate(dashboardSnapshotProvider);
          if (dialogContext.mounted) Navigator.pop(dialogContext);
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Libro sincronizado con Firebase.')));
        } catch (error) {
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo guardar: $error')));
        }
      }, child: const Text('Guardar')),
    ],
  ));
}
