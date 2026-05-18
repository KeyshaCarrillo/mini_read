import 'package:flutter/material.dart';

import '../../../../../shared/widgets/status_badge.dart';
import '../../../domain/entities/book.dart';

class BookTable extends StatelessWidget {
  final List<Book> books;
  final ValueChanged<Book> onOpen;

  const BookTable({super.key, required this.books, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final visibleBooks = books.take(8).toList();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Catálogo activo', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text('Tabla enterprise con estados, metadata y acciones contextuales.', style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                TextButton.icon(onPressed: () {}, icon: const Icon(Icons.download_rounded), label: const Text('Exportar')),
              ],
            ),
          ),
          Divider(color: scheme.outline.withValues(alpha: 0.65)),
          Container(
            height: 44,
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.38),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Row(
              children: [
                Expanded(flex: 4, child: _HeaderLabel('Libro')),
                Expanded(flex: 2, child: _HeaderLabel('Audiencia')),
                Expanded(flex: 2, child: _HeaderLabel('Categoría')),
                Expanded(child: _HeaderLabel('Tiempo')),
                SizedBox(width: 48),
              ],
            ),
          ),
          if (visibleBooks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text('No hay libros para mostrar.', style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w700)),
            )
          else
            for (final book in visibleBooks) _BookRow(book: book, onOpen: onOpen),
        ],
      ),
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  final String label;
  const _HeaderLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _BookRow extends StatefulWidget {
  final Book book;
  final ValueChanged<Book> onOpen;

  const _BookRow({required this.book, required this.onOpen});

  @override
  State<_BookRow> createState() => _BookRowState();
}

class _BookRowState extends State<_BookRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = Color(widget.book.accentColor);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        color: _hovered ? scheme.surfaceContainerHighest.withValues(alpha: 0.34) : scheme.surface,
        child: InkWell(
          onTap: () => widget.onOpen(widget.book),
          child: Container(
            constraints: const BoxConstraints(minHeight: 68),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: scheme.outline.withValues(alpha: 0.45)))),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: accent.withValues(alpha: 0.14),
                        child: Icon(widget.book.hasImmersiveImages ? Icons.image_rounded : Icons.auto_stories_rounded, color: accent, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.book.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                            const SizedBox(height: 3),
                            Text(widget.book.author, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: StatusBadge(
                    label: widget.book.audience,
                    color: widget.book.audience == 'Ninos' ? const Color(0xFF4F46E5) : const Color(0xFF0F766E),
                  ),
                ),
                Expanded(flex: 2, child: Text(widget.book.category, style: const TextStyle(fontWeight: FontWeight.w700))),
                Expanded(child: Text('${widget.book.estimatedMinutes}m', style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w800))),
                PopupMenuButton<String>(
                  tooltip: 'Acciones',
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'open', child: Text('Abrir detalle')),
                    PopupMenuItem(value: 'share', child: Text('Compartir')),
                  ],
                  onSelected: (value) {
                    if (value == 'open') widget.onOpen(widget.book);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
