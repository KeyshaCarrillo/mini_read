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
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 280,
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
                  background: _CoverHero(book: book),
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
                          _Chip(label: book.category),
                          _Chip(label: book.audience),
                          _Chip(label: '${book.estimatedMinutes} min'),
                          if (book.hasImmersiveImages)
                            const _Chip(label: 'Imagenes inmersivas'),
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
                      _AccessPanel(controller: controller),
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
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/read',
                            arguments: book,
                          ),
                          icon: const Icon(Icons.menu_book_rounded),
                          label: const Text('Empezar lectura'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CoverHero extends StatelessWidget {
  final Book book;

  const _CoverHero({required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(book.accentColor),
      padding: const EdgeInsets.fromLTRB(28, 78, 28, 42),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Icon(
          book.hasImmersiveImages
              ? Icons.auto_awesome_motion_rounded
              : Icons.local_library_rounded,
          size: 78,
          color: Colors.white.withValues(alpha: 0.74),
        ),
      ),
    );
  }
}

class _AccessPanel extends StatelessWidget {
  final LibraryController controller;

  const _AccessPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
