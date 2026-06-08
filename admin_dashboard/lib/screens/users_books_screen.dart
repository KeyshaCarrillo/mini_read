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
    final users = context.select((AdminController c) => c.visibleUsers);
    final books = context.select((AdminController c) => c.visibleBooks);
    final hasSearchQuery = context.select(
      (AdminController c) => c.hasSearchQuery,
    );
    final searchQuery = context.select((AdminController c) => c.searchQuery);
    final isSearchPending = context.select(
      (AdminController c) => c.isSearchPending,
    );
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.outlineVariant),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1400104A),
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gestión de Usuarios y Libros',
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0C165F),
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Administra cuentas, permisos y catalogo desde una vista centralizada.',
                            style: textTheme.titleMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF03108A), Color(0xFF1A35B5)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x3B1A35B5),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: FilledButton.icon(
                        onPressed: () => showAddBookDialog(context),
                        icon: const Icon(Icons.auto_stories_rounded),
                        label: const Text('Añadir Libro'),
                        style: FilledButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          textStyle: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF2FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD7DEFC)),
                    ),
                    child: TabBar(
                      isScrollable: true,
                      dividerHeight: 0,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: const Color(0xFF0C1C7A),
                      unselectedLabelColor: AppColors.onSurfaceVariant,
                      labelStyle: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000C5A),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      tabs: const [
                        Tab(icon: Icon(Icons.group_rounded), text: 'Usuarios'),
                        Tab(
                          icon: Icon(Icons.menu_book_rounded),
                          text: 'Libros',
                        ),
                      ],
                    ),
                  ),
                ),
                if (hasSearchQuery || isSearchPending) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F7FF),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFD8E0FF)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSearchPending)
                              const SizedBox.square(
                                dimension: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              const Icon(Icons.search_rounded, size: 14),
                            const SizedBox(width: 8),
                            Text(
                              hasSearchQuery
                                  ? 'Busqueda: "$searchQuery"'
                                  : 'Buscando...',
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFF),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: Text(
                          '${users.length} usuarios • ${books.length} libros',
                          style: textTheme.labelLarge?.copyWith(
                            color: const Color(0xFF2B3765),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 600,
            child: TabBarView(
              children: [
                _UsersTable(users: users, hasSearchQuery: hasSearchQuery),
                _BooksTable(books: books, hasSearchQuery: hasSearchQuery),
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
  final bool hasSearchQuery;

  const _UsersTable({required this.users, required this.hasSearchQuery});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000F4A),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: DataTable2(
          minWidth: 900,
          columnSpacing: 18,
          horizontalMargin: 10,
          bottomMargin: 10,
          headingRowHeight: 56,
          dataRowHeight: 78,
          headingTextStyle: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF16204A),
          ),
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF4F6FF)),
          dataRowColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return const Color(0xFFF7F9FF);
            }
            return Colors.white;
          }),
          columns: const [
            DataColumn2(label: Text('Usuario'), size: ColumnSize.L),
            DataColumn(label: Text('Rol')),
            DataColumn(label: Text('Premium')),
            DataColumn2(label: Text('Actualizado'), size: ColumnSize.M),
            DataColumn(label: Text('Acciones')),
          ],
          empty: _TableEmptyState(
            icon: Icons.person_search_rounded,
            title: hasSearchQuery
                ? 'Sin usuarios que coincidan'
                : 'No hay usuarios para mostrar',
            subtitle: hasSearchQuery
                ? 'Prueba con nombre, correo, username o nickname.'
                : 'Cuando existan usuarios apareceran en esta tabla.',
          ),
          rows: [
            for (final user in users)
              DataRow2(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: _avatarColor(user.name),
                          child: Text(
                            _initials(user.name),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF121833),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.email,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(_RoleChip(role: user.role)),
                  DataCell(_PremiumChip(isPremium: user.isPremium)),
                  DataCell(
                    Text(
                      formatDateTime(user.updatedAt),
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  DataCell(_UserActionsMenu(user: user)),
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
  final bool hasSearchQuery;

  const _BooksTable({required this.books, required this.hasSearchQuery});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000F4A),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: DataTable2(
          minWidth: 820,
          columnSpacing: 16,
          horizontalMargin: 10,
          bottomMargin: 10,
          headingRowHeight: 56,
          dataRowHeight: 74,
          headingTextStyle: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF16204A),
          ),
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF4F6FF)),
          dataRowColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return const Color(0xFFF7F9FF);
            }
            return Colors.white;
          }),
          columns: const [
            DataColumn2(label: Text('Libro'), size: ColumnSize.L),
            DataColumn(label: Text('Categoria')),
            DataColumn(label: Text('Paginas')),
            DataColumn2(label: Text('Descripcion'), size: ColumnSize.L),
            DataColumn(label: Text('Acciones')),
          ],
          empty: _TableEmptyState(
            icon: Icons.menu_book_rounded,
            title: hasSearchQuery
                ? 'Sin libros que coincidan'
                : 'No hay libros registrados',
            subtitle: hasSearchQuery
                ? 'Prueba con titulo, autor o categoria.'
                : 'Agrega libros para visualizarlos aqui.',
          ),
          rows: [
            for (final book in books)
              DataRow2(
                cells: [
                  DataCell(
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFEFF3FF),
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
                    Wrap(
                      spacing: 6,
                      children: [
                        IconButton.filledTonal(
                          tooltip: 'Ver libro',
                          icon: const Icon(Icons.visibility_rounded),
                          onPressed: () => _showBookDetails(context, book),
                        ),
                        IconButton.filledTonal(
                          tooltip: 'Editar libro',
                          icon: const Icon(Icons.edit_rounded),
                          onPressed: () => _showEditBookDialog(context, book),
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

class _RoleChip extends StatelessWidget {
  final String role;

  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'admin' || role == 'owner';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: isAdmin ? const Color(0xFFE8EEFF) : const Color(0xFFF2F4FA),
        border: Border.all(
          color: isAdmin ? const Color(0xFFCDD8FF) : const Color(0xFFE1E6F2),
        ),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: isAdmin ? const Color(0xFF1532A5) : AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PremiumChip extends StatelessWidget {
  final bool isPremium;

  const _PremiumChip({required this.isPremium});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: isPremium ? const Color(0xFFFFF4DC) : const Color(0xFFF2F4FA),
        border: Border.all(
          color: isPremium ? const Color(0xFFF0D38A) : const Color(0xFFE1E6F2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPremium ? Icons.workspace_premium_rounded : Icons.person_rounded,
            size: 16,
            color: isPremium ? const Color(0xFF775A19) : AppColors.onSurface,
          ),
          const SizedBox(width: 6),
          Text(
            isPremium ? 'Premium' : 'Standard',
            style: TextStyle(
              color: isPremium
                  ? const Color(0xFF6A4C0F)
                  : AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TableEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF3FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

enum _UserAction { makeAdmin, makePremium, toggleBan }

class _UserActionsMenu extends StatelessWidget {
  final AdminUser user;

  const _UserActionsMenu({required this.user});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_UserAction>(
      tooltip: 'Acciones',
      onSelected: (action) => _handleUserAction(context, user, action),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _UserAction.makeAdmin,
          enabled: user.role != 'admin',
          child: const Row(
            children: [
              Icon(Icons.admin_panel_settings_rounded, size: 18),
              SizedBox(width: 10),
              Text('Convertir en Admin'),
            ],
          ),
        ),
        PopupMenuItem(
          value: _UserAction.makePremium,
          enabled: !user.isPremium,
          child: const Row(
            children: [
              Icon(Icons.workspace_premium_rounded, size: 18),
              SizedBox(width: 10),
              Text('Dar Premium'),
            ],
          ),
        ),
        PopupMenuItem(
          value: _UserAction.toggleBan,
          child: Row(
            children: [
              Icon(
                user.banned ? Icons.lock_open_rounded : Icons.block_rounded,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(user.banned ? 'Activar usuario' : 'Banear usuario'),
            ],
          ),
        ),
      ],
      icon: const Icon(Icons.more_vert_rounded),
    );
  }
}

Future<void> _handleUserAction(
  BuildContext context,
  AdminUser user,
  _UserAction action,
) async {
  switch (action) {
    case _UserAction.makeAdmin:
      await _runAction(
        context,
        () => context.read<AdminController>().makeAdmin(user),
      );
      return;
    case _UserAction.makePremium:
      await _runAction(
        context,
        () => context.read<AdminController>().makePremium(user),
      );
      return;
    case _UserAction.toggleBan:
      await _runAction(
        context,
        () => context.read<AdminController>().toggleBan(user),
      );
      return;
  }
}

Color _avatarColor(String seed) {
  final hash = seed.hashCode.abs();
  final palette = [
    const Color(0xFF3654C7),
    const Color(0xFF2D7EB6),
    const Color(0xFF7348B6),
    const Color(0xFF1B6D66),
    const Color(0xFF43509A),
  ];
  return palette[hash % palette.length];
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

Future<void> _showBookDetails(BuildContext context, Book book) async {
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Detalle de Libro'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BookDetailRow(label: 'Titulo', value: book.title),
            _BookDetailRow(label: 'Autor', value: book.author),
            _BookDetailRow(label: 'Categoria', value: book.category),
            _BookDetailRow(label: 'Paginas', value: '${book.pageCount}'),
            _BookDetailRow(
              label: 'Descripcion',
              value: book.description.isEmpty
                  ? 'Sin descripcion'
                  : book.description,
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}

Future<void> _showEditBookDialog(BuildContext context, Book book) async {
  final formKey = GlobalKey<FormState>();
  final title = TextEditingController(text: book.title);
  final author = TextEditingController(text: book.author);
  final category = TextEditingController(text: book.category);
  final description = TextEditingController(text: book.description);

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      var saving = false;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Editar Libro'),
            content: SizedBox(
              width: 520,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                              .updateBook(book.id, {
                                'title': title.text.trim(),
                                'author': author.text.trim(),
                                'category': category.text.trim(),
                                'audience': category.text.trim(),
                                'description': description.text.trim(),
                              });
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('Libro actualizado.'),
                              ),
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
                label: const Text('Guardar cambios'),
              ),
            ],
          );
        },
      );
    },
  );

  title.dispose();
  author.dispose();
  category.dispose();
  description.dispose();
}

class _BookDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _BookDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: textTheme.bodyLarge),
        ],
      ),
    );
  }
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
