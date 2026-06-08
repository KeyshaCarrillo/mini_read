import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/services/tts_service.dart';
import '../../data/services/user_book_service.dart';
import '../../domain/entities/book.dart';
import '../controllers/library_controller.dart';

class BookDetailPage extends StatefulWidget {
  final LibraryController controller;
  final Book book;
  final UserBookService? userBookService;

  const BookDetailPage({
    super.key,
    required this.controller,
    required this.book,
    this.userBookService,
  });

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _floatController;
  late final AnimationController _openController;
  late final TtsService _ttsService;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    _openController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 980),
    );
    _ttsService = TtsService()..configureSpanish();
    _loadFavoriteState();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    _openController.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  Future<void> _startReading() async {
    final hasPdf = widget.book.pdfUrl.trim().isNotEmpty;
    if (!hasPdf) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Este libro aún no tiene PDF disponible.'),
          ),
        );
      }
      return;
    }

    await _openController.forward(from: 0);
    if (!mounted) return;
    await Navigator.pushNamed(context, '/book-reader', arguments: widget.book);
    if (mounted) _openController.reset();
  }

  Future<void> _loadFavoriteState() async {
    final favorite = await widget.userBookService?.isFavorite(widget.book.id);
    if (mounted && favorite != null) setState(() => _isFavorite = favorite);
  }

  Future<void> _toggleFavorite() async {
    final service = widget.userBookService;
    if (service == null) return;
    final next = !_isFavorite;
    setState(() => _isFavorite = next);
    try {
      if (next) {
        await service.addFavorite(widget.book);
      } else {
        await service.removeFavorite(widget.book.id);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isFavorite = !next);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('No se pudo actualizar favoritos: $error'),
        ),
      );
    }
  }

  Future<void> _shareBook() async {
    final link = widget.book.pdfUrl.trim().isNotEmpty
        ? widget.book.pdfUrl
        : widget.book.sourceUrl;
    await Share.share(
      '${widget.book.title}\n${widget.book.author}\n$link',
      subject: widget.book.title,
    );
  }

  Future<void> _listenStory() async {
    final text = _bookNarrationText(widget.book);
    try {
      if (_ttsService.isPlaying) {
        await _ttsService.pause();
        return;
      }
      if (_ttsService.isPaused) {
        await _ttsService.resume();
        return;
      }
      await _ttsService.play(text);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(error.toString()),
        ),
      );
    }
  }

  String _bookNarrationText(Book book) {
    final pageText = book.pages
        .map(
          (page) => [
            page.title,
            page.body,
          ].where((text) => text.trim().isNotEmpty).join('. '),
        )
        .where((text) => text.trim().isNotEmpty)
        .join('\n\n');

    if (pageText.trim().isNotEmpty) {
      return '${book.title}. ${book.author}. $pageText';
    }

    return [
      book.title,
      if (book.author.trim().isNotEmpty) 'Por ${book.author}',
      if (book.description.trim().isNotEmpty) book.description,
    ].join('. ');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.controller,
        _ttsService,
        _entranceController,
        _floatController,
        _openController,
      ]),
      builder: (context, _) {
        final childMode = widget.controller.activeProfile?.childMode ?? false;
        final book = widget.book;
        final hasPdf = book.pdfUrl.trim().isNotEmpty;
        final canRead = hasPdf;
        final canListen = _bookNarrationText(book).trim().isNotEmpty;
        final classification = childMode ? 'Kids' : book.category;
        final entrance = Curves.easeOutCubic.transform(
          _entranceController.value,
        );

        return Scaffold(
          backgroundColor: AppTheme.obsidian,
          body: Stack(
            children: [
              _PremiumBackdrop(childMode: childMode),
              if (childMode) const _MagicParticles(),
              SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
                        child: Transform.translate(
                          offset: Offset(0, 24 * (1 - entrance)),
                          child: Opacity(
                            opacity: entrance,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _TopBar(title: book.title),
                                const SizedBox(height: 18),
                                _BookCoverStage(
                                  book: book,
                                  childMode: childMode,
                                  floatValue: _floatController.value,
                                  openValue: _openController.value,
                                ),
                                const SizedBox(height: 30),
                                _BookIdentity(book: book),
                                const SizedBox(height: 16),
                                _MetadataRow(
                                  classification: classification,
                                  minutes: book.estimatedMinutes,
                                  pageCount: book.pageCount,
                                  rating: book.rating,
                                  childMode: childMode,
                                ),
                                const SizedBox(height: 24),
                                _PrimaryReadButton(
                                  enabled: canRead,
                                  childMode: childMode,
                                  onPressed: _startReading,
                                ),
                                const SizedBox(height: 12),
                                _ListenStoryButton(
                                  enabled: canListen,
                                  playbackState: _ttsService.state,
                                  onPressed: _listenStory,
                                ),
                                const SizedBox(height: 12),
                                _BookActionRow(
                                  favorite: _isFavorite,
                                  onFavorite: widget.userBookService == null
                                      ? null
                                      : _toggleFavorite,
                                  onShare: _shareBook,
                                ),
                                const SizedBox(height: 24),
                                _SynopsisPanel(book: book),
                                const SizedBox(height: 16),
                                _ContinuePanel(
                                  book: book,
                                  enabled: canRead,
                                  onPressed: _startReading,
                                ),
                                const SizedBox(height: 16),
                                _AiPanel(
                                  premium: widget.controller.isPremium,
                                  childMode: childMode,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IgnorePointer(
                ignoring: _openController.value == 0,
                child: Opacity(
                  opacity: _openController.value > 0 ? 1 : 0,
                  child: _BookOpeningOverlay(
                    book: book,
                    progress: Curves.easeInOutCubic.transform(
                      _openController.value,
                    ),
                  ),
                ),
              ),
              if (!_ttsService.isStopped)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 18,
                  child: SafeArea(
                    top: false,
                    child: _TtsFloatingBar(
                      title: book.title,
                      playbackState: _ttsService.state,
                      onPlay: _listenStory,
                      onPause: _ttsService.pause,
                      onStop: _ttsService.stop,
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

class _TopBar extends StatelessWidget {
  final String title;

  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filled(
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
        ),
      ],
    );
  }
}

class _BookCoverStage extends StatelessWidget {
  final Book book;
  final bool childMode;
  final double floatValue;
  final double openValue;

  const _BookCoverStage({
    required this.book,
    required this.childMode,
    required this.floatValue,
    required this.openValue,
  });

  @override
  Widget build(BuildContext context) {
    final floatOffset = math.sin(floatValue * math.pi) * -10;
    final scale = 1 + (openValue * 0.18);

    return Transform.translate(
      offset: Offset(0, floatOffset),
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 210,
          height: 308,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.gold.withValues(alpha: 0.26),
                blurRadius: 42,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.72),
                blurRadius: 38,
                offset: const Offset(0, 24),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _CoverArtwork(book: book),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.20),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.34),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    color: Colors.black.withValues(alpha: 0.28),
                  ),
                ),
                if (childMode)
                  Positioned(
                    right: 14,
                    top: 14,
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: AppTheme.gold.withValues(alpha: 0.88),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CoverArtwork extends StatelessWidget {
  final Book book;

  const _CoverArtwork({required this.book});

  @override
  Widget build(BuildContext context) {
    if (book.coverUrl.trim().isNotEmpty) {
      return Image.network(
        book.coverUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _FallbackCover(book: book),
      );
    }
    return _FallbackCover(book: book);
  }
}

class _FallbackCover extends StatelessWidget {
  final Book book;

  const _FallbackCover({required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(book.accentColor),
            const Color(0xFF19140B),
            const Color(0xFF050505),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book_rounded, color: AppTheme.gold, size: 58),
          const SizedBox(height: 18),
          Text(
            book.title.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.04,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookIdentity extends StatelessWidget {
  final Book book;

  const _BookIdentity({required this.book});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          book.title.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 35,
            fontWeight: FontWeight.w900,
            height: 1.02,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          book.author,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.gold.withValues(alpha: 0.92),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MetadataRow extends StatelessWidget {
  final String classification;
  final int minutes;
  final int pageCount;
  final double rating;
  final bool childMode;

  const _MetadataRow({
    required this.classification,
    required this.minutes,
    required this.pageCount,
    required this.rating,
    required this.childMode,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        _PremiumPill(
          icon: childMode ? Icons.child_care_rounded : Icons.auto_stories,
          label: classification,
        ),
        _PremiumPill(icon: Icons.schedule_rounded, label: '$minutes min'),
        if (pageCount > 0)
          _PremiumPill(
            icon: Icons.menu_book_rounded,
            label: '$pageCount páginas',
          ),
        if (rating > 0)
          _PremiumPill(
            icon: Icons.star_rounded,
            label: rating.toStringAsFixed(1),
          ),
      ],
    );
  }
}

class _PremiumPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PremiumPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.gold, size: 17),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryReadButton extends StatelessWidget {
  final bool enabled;
  final bool childMode;
  final VoidCallback onPressed;

  const _PrimaryReadButton({
    required this.enabled,
    required this.childMode,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppTheme.gold.withValues(alpha: 0.34),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                ]
              : null,
        ),
        child: FilledButton.icon(
          onPressed: enabled ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.gold,
            foregroundColor: AppTheme.obsidian,
            disabledBackgroundColor: Colors.white.withValues(alpha: 0.12),
            disabledForegroundColor: Colors.white54,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.play_arrow_rounded, size: 28),
          label: Text(
            enabled ? 'Leer ahora' : 'Libro no disponible',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}

class _ListenStoryButton extends StatelessWidget {
  final bool enabled;
  final TtsPlaybackState playbackState;
  final VoidCallback onPressed;

  const _ListenStoryButton({
    required this.enabled,
    required this.playbackState,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final playing = playbackState == TtsPlaybackState.playing;
    final paused = playbackState == TtsPlaybackState.paused;
    final label = playing
        ? 'Pausar narración'
        : paused
        ? 'Continuar narración'
        : 'Escuchar cuento';

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.gold,
          disabledForegroundColor: Colors.white38,
          side: BorderSide(
            color: enabled
                ? AppTheme.gold.withValues(alpha: 0.62)
                : Colors.white.withValues(alpha: 0.12),
          ),
          backgroundColor: Colors.white.withValues(alpha: 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(
          playing ? Icons.pause_rounded : Icons.volume_up_rounded,
          size: 25,
        ),
        label: Text(
          enabled ? label : 'Sin texto para escuchar',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _BookActionRow extends StatelessWidget {
  final bool favorite;
  final VoidCallback? onFavorite;
  final VoidCallback onShare;

  const _BookActionRow({
    required this.favorite,
    required this.onFavorite,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onFavorite,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.gold,
              side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.38)),
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(
              favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            ),
            label: Text(favorite ? 'En favoritos' : 'Agregar a favoritos'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onShare,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.ios_share_rounded),
            label: const Text('Compartir'),
          ),
        ),
      ],
    );
  }
}

class _TtsFloatingBar extends StatelessWidget {
  final String title;
  final TtsPlaybackState playbackState;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onStop;

  const _TtsFloatingBar({
    required this.title,
    required this.playbackState,
    required this.onPlay,
    required this.onPause,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final playing = playbackState == TtsPlaybackState.playing;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: const Color(0xF2141210),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.50),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.gold.withValues(alpha: 0.16),
            ),
            child: const Icon(Icons.graphic_eq_rounded, color: AppTheme.gold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Narración en español',
                  style: TextStyle(
                    color: AppTheme.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          _TtsControlButton(
            tooltip: playing ? 'Pausar' : 'Reproducir',
            icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
            onPressed: playing ? onPause : onPlay,
          ),
          _TtsControlButton(
            tooltip: 'Detener',
            icon: Icons.stop_rounded,
            onPressed: onStop,
          ),
        ],
      ),
    );
  }
}

class _TtsControlButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _TtsControlButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.09),
        foregroundColor: Colors.white,
      ),
      icon: Icon(icon),
    );
  }
}

class _SynopsisPanel extends StatelessWidget {
  final Book book;

  const _SynopsisPanel({required this.book});

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.auto_stories_rounded,
            title: 'Sinopsis',
          ),
          const SizedBox(height: 12),
          Text(
            book.description.trim().isEmpty
                ? 'Una lectura preparada para descubrir nuevas aventuras.'
                : book.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 15,
              height: 1.48,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinuePanel extends StatelessWidget {
  final Book book;
  final bool enabled;
  final VoidCallback onPressed;

  const _ContinuePanel({
    required this.book,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.bookmark_rounded, color: AppTheme.gold),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Continuar leyendo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.58)),
                ),
              ],
            ),
          ),
          IconButton.filled(
            onPressed: enabled ? onPressed : null,
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.gold,
              foregroundColor: AppTheme.obsidian,
            ),
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ],
      ),
    );
  }
}

class _AiPanel extends StatelessWidget {
  final bool premium;
  final bool childMode;

  const _AiPanel({required this.premium, required this.childMode});

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      muted: true,
      child: Row(
        children: [
          Icon(
            premium ? Icons.workspace_premium_rounded : Icons.auto_awesome,
            color: AppTheme.gold.withValues(alpha: 0.78),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              premium
                  ? 'Asistente IA premium disponible para conversar sobre este libro.'
                  : 'Asistente IA disponible con monedas de lectura.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.62),
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final Widget child;
  final bool muted;

  const _GlassPanel({required this.child, this.muted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: muted ? 0.045 : 0.075),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PanelTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _PanelTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.gold, size: 19),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _BookOpeningOverlay extends StatelessWidget {
  final Book book;
  final double progress;

  const _BookOpeningOverlay({required this.book, required this.progress});

  @override
  Widget build(BuildContext context) {
    final fade = (1 - progress).clamp(0.0, 1.0);
    final pageTurn = Curves.easeInOut.transform(progress);

    return Container(
      color: AppTheme.obsidian.withValues(alpha: 0.84 * fade),
      child: Center(
        child: Transform.scale(
          scale: 1 + progress * 0.46,
          child: SizedBox(
            width: 240,
            height: 330,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.translate(
                  offset: Offset(-54 * pageTurn, 0),
                  child: _OpenPage(side: Alignment.centerRight),
                ),
                Transform.translate(
                  offset: Offset(54 * pageTurn, 0),
                  child: _OpenPage(side: Alignment.centerLeft),
                ),
                Transform(
                  alignment: Alignment.centerLeft,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(-math.pi * 0.82 * pageTurn),
                  child: Opacity(
                    opacity: fade,
                    child: _MiniCover(book: book),
                  ),
                ),
                if (progress > 0.52)
                  Transform(
                    alignment: Alignment.centerLeft,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(-math.pi * (progress - 0.52) / 0.48),
                    child: _TurningPage(opacity: progress),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniCover extends StatelessWidget {
  final Book book;

  const _MiniCover({required this.book});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 190,
        height: 286,
        child: _CoverArtwork(book: book),
      ),
    );
  }
}

class _OpenPage extends StatelessWidget {
  final Alignment side;

  const _OpenPage({required this.side});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 116,
      height: 292,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E4),
        borderRadius: BorderRadius.horizontal(
          left: side == Alignment.centerRight
              ? const Radius.circular(18)
              : Radius.zero,
          right: side == Alignment.centerLeft
              ? const Radius.circular(18)
              : Radius.zero,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
    );
  }
}

class _TurningPage extends StatelessWidget {
  final double opacity;

  const _TurningPage({required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Container(
        width: 112,
        height: 290,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              const Color(0xFFFFF1C6),
              Colors.black.withValues(alpha: 0.10),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _PremiumBackdrop extends StatelessWidget {
  final bool childMode;

  const _PremiumBackdrop({required this.childMode});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.65),
          radius: 1.25,
          colors: childMode
              ? const [Color(0xFF4A2B11), Color(0xFF11100D), Color(0xFF030303)]
              : const [Color(0xFF392710), Color(0xFF11100D), Color(0xFF030303)],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _MagicParticles extends StatelessWidget {
  const _MagicParticles();

  @override
  Widget build(BuildContext context) {
    const stars = [
      (0.12, 0.18, 4.0),
      (0.82, 0.22, 5.0),
      (0.72, 0.43, 3.5),
      (0.18, 0.58, 3.0),
      (0.88, 0.68, 4.0),
      (0.38, 0.12, 2.5),
    ];

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              for (final star in stars)
                Positioned(
                  left: constraints.maxWidth * star.$1,
                  top: constraints.maxHeight * star.$2,
                  child: Icon(
                    Icons.star_rounded,
                    size: star.$3 * 3,
                    color: AppTheme.gold.withValues(alpha: 0.22),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
