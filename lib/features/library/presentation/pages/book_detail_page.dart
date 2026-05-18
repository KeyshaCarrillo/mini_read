import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../domain/entities/book.dart';
import '../controllers/library_controller.dart';

class BookDetailPage extends StatelessWidget {
  final LibraryController controller;
  final Book book;

  const BookDetailPage({
    super.key,
    required this.controller,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final childMode = controller.activeProfile?.childMode ?? false;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: childMode
                    ? const [Color(0xFFFFF0A8), Color(0xFFFFF7E8)]
                    : const [Color(0xFFFFFCF4), Color(0xFFF7EFE4)],
              ),
            ),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: childMode ? 310 : 280,
                  backgroundColor: Color(book.accentColor),
                  foregroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsetsDirectional.only(
                      start: 56,
                      bottom: 16,
                      end: 16,
                    ),
                    title: Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    background: _CoverHero(book: book, childMode: childMode),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _Chip(label: book.category, childMode: childMode),
                            _Chip(label: book.audience, childMode: childMode),
                            _Chip(
                              label: '${book.estimatedMinutes} min',
                              childMode: childMode,
                            ),
                            if (book.hasImmersiveImages)
                              _Chip(
                                label: 'Imagenes inmersivas',
                                childMode: childMode,
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          book.description,
                          style: const TextStyle(
                            color: AppTheme.ink,
                            fontSize: 18,
                            height: 1.38,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _AccessPanel(
                          controller: controller,
                          childMode: childMode,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Fuente: ${book.sourceName}',
                          style: TextStyle(
                            color: AppTheme.ink.withValues(alpha: 0.62),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: book.pages.isEmpty
                                ? null
                                : () => Navigator.pushNamed(
                                    context,
                                    '/read',
                                    arguments: book,
                                  ),
                            icon: const Icon(Icons.menu_book_rounded),
                            label: Text(
                              book.pages.isEmpty
                                  ? 'Libro sin paginas'
                                  : childMode
                                  ? 'Abrir cuento'
                                  : 'Empezar lectura',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CoverHero extends StatelessWidget {
  final Book book;
  final bool childMode;

  const _CoverHero({required this.book, required this.childMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(book.accentColor),
        gradient: childMode
            ? LinearGradient(
                colors: [Color(book.accentColor), const Color(0xFFFFC857)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      padding: const EdgeInsets.fromLTRB(28, 78, 28, 42),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Icon(
              childMode ? Icons.star_rounded : Icons.bookmark_rounded,
              size: childMode ? 70 : 56,
              color: Colors.white.withValues(alpha: 0.24),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Icon(
              book.hasImmersiveImages
                  ? Icons.auto_awesome_motion_rounded
                  : Icons.local_library_rounded,
              size: childMode ? 92 : 78,
              color: Colors.white.withValues(alpha: 0.74),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessPanel extends StatelessWidget {
  final LibraryController controller;
  final bool childMode;

  const _AccessPanel({required this.controller, required this.childMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: childMode ? 0.86 : 1),
        borderRadius: BorderRadius.circular(childMode ? 16 : 8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(
            controller.isPremium
                ? Icons.workspace_premium_rounded
                : Icons.paid_rounded,
            color: AppTheme.coral,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              controller.isPremium
                  ? 'Chat IA ilimitado en modo premium.'
                  : 'Chat IA con monedas: 5 por pagina, 10 general.',
              style: const TextStyle(
                color: AppTheme.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool childMode;

  const _Chip({required this.label, required this.childMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: childMode ? const Color(0xFFFFF0A8) : Colors.white,
        borderRadius: BorderRadius.circular(childMode ? 99 : 8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.ink,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
