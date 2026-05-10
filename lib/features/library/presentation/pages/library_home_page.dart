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
        final childMode = profile?.childMode ?? false;
        final featuredBooks = controller.recommendedBooks;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(profile == null ? 'Biblioteca' : profile.name),
            actions: [
              IconButton(
                tooltip: 'Cambiar perfil',
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/profiles'),
                icon: const Icon(Icons.switch_account_rounded),
              ),
            ],
          ),
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 360),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: childMode
                    ? const [
                        Color(0xFFFFF0A8),
                        Color(0xFFFFB7D2),
                        Color(0xFFB7F3E5),
                        Color(0xFFAEC6FF),
                      ]
                    : const [
                        Color(0xFFFFFCF4),
                        Color(0xFFEAF3F0),
                        Color(0xFFF5E7DC),
                      ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  if (childMode)
                    const _KidBackdrop()
                  else
                    const _CalmBackdrop(),
                  ListView(
                    padding: const EdgeInsets.fromLTRB(16, 76, 16, 30),
                    children: [
                      _WelcomePanel(
                        controller: controller,
                        childMode: childMode,
                      ),
                      const SizedBox(height: 22),
                      _SectionHeader(
                        title: childMode
                            ? 'Tus cuentos favoritos'
                            : 'Recomendado para ti',
                        subtitle: profile == null
                            ? 'Libros listos para explorar.'
                            : 'Basado en: ${profile.favoriteCategories.join(', ')}',
                        childMode: childMode,
                      ),
                      const SizedBox(height: 12),
                      _HorizontalBooks(
                        books: featuredBooks,
                        childMode: childMode,
                        onTap: (book) => Navigator.pushNamed(
                          context,
                          '/book',
                          arguments: book,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: childMode
                            ? 'Lecturas con imagenes'
                            : 'Biblioteca infantil',
                        subtitle: childMode
                            ? 'Paginas mas visuales para leer con calma.'
                            : 'Modo visual, textos cortos y preguntas adaptadas.',
                        childMode: childMode,
                      ),
                      const SizedBox(height: 12),
                      for (final book in controller.childBooks) ...[
                        _WideBookTile(
                          book: book,
                          childMode: childMode,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/book',
                            arguments: book,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      if (!childMode) ...[
                        const SizedBox(height: 14),
                        _SectionHeader(
                          title: 'Clasicos para adultos',
                          subtitle:
                              'Romance, drama, suspenso y aventura para crecer el catalogo.',
                          childMode: false,
                        ),
                        const SizedBox(height: 12),
                        for (final book in controller.generalBooks.take(3)) ...[
                          _WideBookTile(
                            book: book,
                            childMode: false,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/book',
                              arguments: book,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  final LibraryController controller;
  final bool childMode;

  const _WelcomePanel({required this.controller, required this.childMode});

  @override
  Widget build(BuildContext context) {
    final profile = controller.activeProfile;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: childMode ? Colors.white.withValues(alpha: 0.76) : AppTheme.ink,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: childMode ? 0.08 : 0.14),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Color(profile?.accentColor ?? 0xFF5B7C62),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  childMode
                      ? Icons.auto_awesome_rounded
                      : Icons.local_library_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      childMode
                          ? 'Hora de imaginar'
                          : 'Tu biblioteca esta lista',
                      style: TextStyle(
                        color: childMode ? AppTheme.ink : Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile?.readingMood ?? 'Elige un libro para empezar.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: childMode
                            ? AppTheme.ink.withValues(alpha: 0.64)
                            : Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Metric(
                icon: Icons.paid_rounded,
                label: '${controller.coins} monedas',
                childMode: childMode,
              ),
              _Metric(
                icon: Icons.local_fire_department_rounded,
                label: '${controller.streakDays} dias',
                childMode: childMode,
              ),
              _Metric(
                icon: controller.isPremium
                    ? Icons.workspace_premium_rounded
                    : Icons.lock_open_rounded,
                label: controller.isPremium ? 'Premium' : 'Gratis',
                childMode: childMode,
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
                  foregroundColor: childMode ? AppTheme.ink : Colors.white,
                  side: BorderSide(
                    color: childMode
                        ? AppTheme.ink.withValues(alpha: 0.16)
                        : Colors.white.withValues(alpha: 0.36),
                  ),
                ),
                onPressed: controller.rewardAdWatched,
                icon: const Icon(Icons.play_circle_rounded),
                label: const Text('+30 anuncio'),
              ),
              FilterChip(
                selected: controller.isPremium,
                label: const Text('Premium demo'),
                avatar: const Icon(Icons.workspace_premium_rounded, size: 18),
                onSelected: (_) => controller.togglePremiumPreview(),
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
  final bool childMode;

  const _Metric({
    required this.icon,
    required this.label,
    required this.childMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: childMode
            ? Colors.white.withValues(alpha: 0.82)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: childMode ? AppTheme.coral : Colors.white,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: childMode ? AppTheme.ink : Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalBooks extends StatelessWidget {
  final List<Book> books;
  final bool childMode;
  final ValueChanged<Book> onTap;

  const _HorizontalBooks({
    required this.books,
    required this.childMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: childMode ? 254 : 238,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final book = books[index];
          return _BookPoster(
            book: book,
            childMode: childMode,
            onTap: () => onTap(book),
          );
        },
      ),
    );
  }
}

class _BookPoster extends StatelessWidget {
  final Book book;
  final bool childMode;
  final VoidCallback onTap;

  const _BookPoster({
    required this.book,
    required this.childMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Color(book.accentColor);

    return InkWell(
      borderRadius: BorderRadius.circular(childMode ? 22 : 14),
      onTap: onTap,
      child: SizedBox(
        width: childMode ? 164 : 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: childMode ? 190 : 174,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(childMode ? 22 : 14),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.24),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Icon(
                      childMode
                          ? Icons.auto_awesome_rounded
                          : Icons.bookmark_rounded,
                      color: Colors.white.withValues(alpha: 0.62),
                      size: childMode ? 34 : 26,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      book.title,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1.02,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${book.category} · ${book.estimatedMinutes} min',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.ink.withValues(alpha: 0.64),
                fontSize: 12,
                fontWeight: FontWeight.w700,
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
  final bool childMode;
  final VoidCallback onTap;

  const _WideBookTile({
    required this.book,
    required this.childMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Color(book.accentColor);

    return Card(
      color: Colors.white.withValues(alpha: childMode ? 0.82 : 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(childMode ? 18 : 10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(childMode ? 18 : 10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 82,
                height: 100,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(childMode ? 18 : 10),
                ),
                child: Icon(
                  book.hasImmersiveImages
                      ? Icons.image_rounded
                      : Icons.auto_stories_rounded,
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
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.ink.withValues(alpha: 0.66),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          book.hasImmersiveImages
                              ? Icons.auto_awesome_motion_rounded
                              : Icons.schedule_rounded,
                          size: 16,
                          color: accent,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            book.hasImmersiveImages
                                ? 'Lectura visual'
                                : '${book.estimatedMinutes} min de lectura',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
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
  final bool childMode;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.childMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (childMode) ...[
              const Icon(Icons.star_rounded, color: AppTheme.coral, size: 22),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppTheme.ink,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
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

class _KidBackdrop extends StatelessWidget {
  const _KidBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 82,
            right: 26,
            child: Icon(
              Icons.castle_rounded,
              color: Colors.white.withValues(alpha: 0.44),
              size: 94,
            ),
          ),
          Positioned(
            top: 172,
            left: 24,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppTheme.coral.withValues(alpha: 0.34),
              size: 58,
            ),
          ),
          Positioned(
            bottom: 92,
            right: 36,
            child: Icon(
              Icons.palette_rounded,
              color: Colors.white.withValues(alpha: 0.36),
              size: 88,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalmBackdrop extends StatelessWidget {
  const _CalmBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 94,
            right: 26,
            child: Icon(
              Icons.local_library_rounded,
              color: AppTheme.moss.withValues(alpha: 0.12),
              size: 106,
            ),
          ),
          Positioned(
            bottom: 72,
            left: 26,
            child: Icon(
              Icons.bookmark_rounded,
              color: AppTheme.plum.withValues(alpha: 0.12),
              size: 90,
            ),
          ),
        ],
      ),
    );
  }
}
