import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../domain/entities/book.dart';
import '../controllers/library_controller.dart';

class LibraryHomePage extends StatelessWidget {
  final LibraryController controller;

  const LibraryHomePage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final profile = controller.activeProfile;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              profile == null ? 'Biblioteca' : 'Hola, ${profile.name}',
            ),
            actions: [
              IconButton(
                tooltip: 'Cambiar perfil',
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/profiles'),
                icon: const Icon(Icons.switch_account_rounded),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: [
                _WalletPanel(controller: controller),
                const SizedBox(height: 20),
                _SectionHeader(
                  title: 'Para seguir leyendo',
                  subtitle:
                      'Libros de dominio publico listos para conectar a tu API.',
                ),
                const SizedBox(height: 12),
                _HorizontalBooks(
                  books: controller.generalBooks,
                  onTap: (book) =>
                      Navigator.pushNamed(context, '/book', arguments: book),
                ),
                const SizedBox(height: 24),
                const _SectionHeader(
                  title: 'Niños e inmersion visual',
                  subtitle:
                      'Textos cortos, escenas ilustradas y preguntas adaptadas.',
                ),
                const SizedBox(height: 12),
                for (final book in controller.childBooks) ...[
                  _WideBookTile(
                    book: book,
                    onTap: () =>
                        Navigator.pushNamed(context, '/book', arguments: book),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WalletPanel extends StatelessWidget {
  final LibraryController controller;

  const _WalletPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.ink,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  controller.isPremium ? 'Premium activo' : 'Plan gratis',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Switch(
                value: controller.isPremium,
                onChanged: (_) => controller.togglePremiumPreview(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Metric(
                icon: Icons.paid_rounded,
                label: '${controller.coins} monedas',
              ),
              const SizedBox(width: 10),
              _Metric(
                icon: Icons.local_fire_department_rounded,
                label: '${controller.streakDays} dias',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: controller.claimDailyReward,
                icon: const Icon(Icons.card_giftcard_rounded),
                label: const Text('+20 diaria'),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.36)),
                ),
                onPressed: controller.rewardAdWatched,
                icon: const Icon(Icons.play_circle_rounded),
                label: const Text('+30 anuncio'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Metric({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _HorizontalBooks extends StatelessWidget {
  final List<Book> books;
  final ValueChanged<Book> onTap;

  const _HorizontalBooks({required this.books, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final book = books[index];
          return _BookPoster(book: book, onTap: () => onTap(book));
        },
      ),
    );
  }
}

class _BookPoster extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const _BookPoster({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: SizedBox(
        width: 146,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 174,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Color(book.accentColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  book.title,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.ink.withValues(alpha: 0.64),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WideBookTile extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const _WideBookTile({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 82,
                height: 100,
                decoration: BoxDecoration(
                  color: Color(book.accentColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.ink.withValues(alpha: 0.66),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.image_rounded, size: 16),
                        SizedBox(width: 4),
                        Text('Lectura visual'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.ink,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: AppTheme.ink.withValues(alpha: 0.62),
            height: 1.32,
          ),
        ),
      ],
    );
  }
}
