import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/admin_controller.dart';
import '../core/constants.dart';
import '../core/formatters.dart';
import '../models/admin_user.dart';
import '../models/book.dart';

class UsersBooksScreen extends StatelessWidget {
  const UsersBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Gestion de Usuarios y Libros',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () => showAddBookDialog(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Anadir Libro'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              isScrollable: true,
              tabs: [
                Tab(icon: Icon(Icons.group_rounded), text: 'Usuarios'),
                Tab(icon: Icon(Icons.menu_book_rounded), text: 'Libros'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 560,
            child: TabBarView(
              children: [
                _UsersTable(users: admin.users),
                _BooksTable(books: admin.books),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UsersTable extends StatelessWidget {
  final List<AdminUser> users;

  const _UsersTable({required this.users});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: DataTable2(
          minWidth: 860,
          columnSpacing: 16,
          headingRowColor: WidgetStateProperty.all(
            AppColors.surfaceContainerLow,
          ),
          columns: const [
            DataColumn2(label: Text('Usuario'), size: ColumnSize.L),
            DataColumn(label: Text('Rol')),
            DataColumn(label: Text('Premium')),
            DataColumn2(label: Text('Actualizado'), size: ColumnSize.M),
            DataColumn2(label: Text('Acciones'), size: ColumnSize.L),
          ],
          empty: const Center(child: Text('No hay usuarios para mostrar.')),
          rows: [
            for (final user in users)
              DataRow2(
                cells: [
                  DataCell(
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.surfaceContainerHighest,
                        child: Text(_initials(user.name)),
                      ),
                      title: Text(user.name, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        user.email,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(_RoleChip(role: user.role)),
                  DataCell(
                    Icon(
                      user.isPremium
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: user.isPremium
                          ? AppColors.secondary
                          : AppColors.outline,
                    ),
                  ),
                  DataCell(Text(formatDateTime(user.updatedAt))),
                  DataCell(
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: user.isPremium
                              ? null
                              : () => _runAction(
                                  context,
                                  () => context
                                      .read<AdminController>()
                                      .makePremium(user),
                                ),
                          icon: const Icon(Icons.workspace_premium_rounded),
                          label: const Text('Premium'),
                        ),
                        OutlinedButton.icon(
                          onPressed: user.role == 'admin'
                              ? null
                              : () => _runAction(
                                  context,
                                  () => context
                                      .read<AdminController>()
                                      .makeAdmin(user),
                                ),
                          icon: const Icon(Icons.admin_panel_settings_rounded),
                          label: const Text('Admin'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _runAction(
                            context,
                            () =>
                                context.read<AdminController>().toggleBan(user),
                          ),
                          icon: Icon(
                            user.banned
                                ? Icons.lock_open_rounded
                                : Icons.block_rounded,
                          ),
                          label: Text(user.banned ? 'Activar' : 'Banear'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _BooksTable extends StatelessWidget {
  final List<Book> books;

  const _BooksTable({required this.books});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: DataTable2(
          minWidth: 780,
          columnSpacing: 16,
          headingRowColor: WidgetStateProperty.all(
            AppColors.surfaceContainerLow,
          ),
          columns: const [
            DataColumn2(label: Text('Libro'), size: ColumnSize.L),
            DataColumn(label: Text('Categoria')),
            DataColumn(label: Text('Paginas')),
            DataColumn2(label: Text('Descripcion'), size: ColumnSize.L),
            DataColumn(label: Text('Acciones')),
          ],
          empty: const Center(child: Text('No hay libros registrados.')),
          rows: [
            for (final book in books)
              DataRow2(
                cells: [
                  DataCell(
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.surfaceContainerHighest,
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(book.title, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        book.author,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(Text(book.category)),
                  DataCell(Text('${book.pageCount}')),
                  DataCell(
                    Text(
                      book.description.isEmpty
                          ? 'Sin descripcion'
                          : book.description,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    IconButton(
                      tooltip: 'Eliminar libro',
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () => _confirmDeleteBook(context, book),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String role;

  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'admin' || role == 'owner';
    return Chip(
      label: Text(role),
      backgroundColor: isAdmin
          ? AppColors.primary.withValues(alpha: 0.1)
          : AppColors.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: isAdmin ? AppColors.primary : AppColors.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

Future<void> showAddBookDialog(BuildContext context) async {
  final formKey = GlobalKey<FormState>();
  final id = TextEditingController();
  final title = TextEditingController();
  final author = TextEditingController();
  final category = TextEditingController(text: 'Ninos');
  final pages = TextEditingController(text: '1');
  final description = TextEditingController();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      var saving = false;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Anadir Libro'),
            content: SizedBox(
              width: 520,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: id,
                        decoration: const InputDecoration(
                          labelText: 'ID del libro',
                          hintText: 'opcional, ejemplo: principito',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: title,
                        decoration: const InputDecoration(labelText: 'Titulo'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'El titulo es requerido.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: author,
                        decoration: const InputDecoration(labelText: 'Autor'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: category,
                        decoration: const InputDecoration(
                          labelText: 'Categoria',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: pages,
                        decoration: const InputDecoration(labelText: 'Paginas'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final parsed = int.tryParse(value ?? '');
                          if (parsed == null || parsed <= 0) {
                            return 'Ingresa un numero de paginas valido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: description,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Descripcion',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving
                    ? null
                    : () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton.icon(
                onPressed: saving
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setState(() => saving = true);
                        try {
                          await dialogContext
                              .read<AdminController>()
                              .createBook(
                                Book(
                                  id: id.text,
                                  title: title.text,
                                  author: author.text,
                                  category: category.text,
                                  audience: category.text,
                                  description: description.text,
                                  pageCount: int.parse(pages.text),
                                ),
                              );
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(content: Text('Libro creado.')),
                            );
                          }
                        } catch (error) {
                          setState(() => saving = false);
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(
                              dialogContext,
                            ).showSnackBar(SnackBar(content: Text('$error')));
                          }
                        }
                      },
                icon: saving
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: const Text('Guardar'),
              ),
            ],
          );
        },
      );
    },
  );

  id.dispose();
  title.dispose();
  author.dispose();
  category.dispose();
  pages.dispose();
  description.dispose();
}

Future<void> _confirmDeleteBook(BuildContext context, Book book) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Eliminar libro'),
      content: Text('Deseas eliminar "${book.title}" de la API?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;
  await _runAction(
    context,
    () => context.read<AdminController>().deleteBook(book.id),
  );
}

Future<void> _runAction(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Accion completada.')));
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return 'U';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
