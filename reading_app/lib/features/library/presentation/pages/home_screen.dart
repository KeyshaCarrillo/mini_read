import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../../../app/app_theme.dart';
import '../../domain/entities/book.dart';
import '../controllers/home_controller.dart';

// ─────────────────────────────────────────────
//  Paletas por modo
// ─────────────────────────────────────────────
enum _ProfileMode { child, teen, adult }

_ProfileMode _resolveMode(dynamic profile) {
  if (profile == null) return _ProfileMode.adult;
  if (profile.childMode == true) return _ProfileMode.child;
  if (profile.role == 'teen') return _ProfileMode.teen;
  return _ProfileMode.adult;
}

class _Palette {
  final List<Color> gradient;
  final Color surface; // fondo de paneles principales
  final Color surfaceAlt; // fondo de action panels
  final Color onSurface; // texto sobre surface
  final Color onSurfaceMuted; // texto secundario sobre surface
  final Color metricChip; // fondo del chip de métrica
  final Color onMetricChip; // texto/ícono del chip
  final Color sectionTitle; // títulos de sección
  final Color sectionSubtitle; // subtítulos de sección
  final Color appBarForeground; // color de título e íconos en AppBar
  final Color searchFill; // fondo del campo de búsqueda
  final Color searchBorder; // borde del campo de búsqueda
  final Color searchHint; // hint text del campo
  final Color searchText; // texto escrito en el campo
  final Color searchIcon; // ícono de lupa
  final double panelRadius;
  final double actionPanelRadius;

  const _Palette({
    required this.gradient,
    required this.surface,
    required this.surfaceAlt,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.metricChip,
    required this.onMetricChip,
    required this.sectionTitle,
    required this.sectionSubtitle,
    required this.appBarForeground,
    required this.searchFill,
    required this.searchBorder,
    required this.searchHint,
    required this.searchText,
    required this.searchIcon,
    required this.panelRadius,
    required this.actionPanelRadius,
  });
}

// ── Adulto: biblioteca nocturna ──────────────
const _Palette _adultPalette = _Palette(
  gradient: [
    Color(0xFF1C2B22), // verde noche
    Color(0xFF2A2118), // café oscuro cálido
    Color(0xFF1A2028), // azul noche
  ],
  surface: Color(0x1AFFFFFF), // glassmorphism sobre oscuro
  surfaceAlt: Color(0xEBFFFFFF), // blanco sólido para contraste
  onSurface: Colors.white,
  onSurfaceMuted: Color(0x8CFFFFFF),
  metricChip: Color(0x2EFFFFFF),
  onMetricChip: Colors.white,
  sectionTitle: Colors.white,
  sectionSubtitle: Color(0x80FFFFFF),
  appBarForeground: Colors.white,
  searchFill: Color(0x1AFFFFFF),
  searchBorder: Color(0x2EFFFFFF),
  searchHint: Color(0x66FFFFFF),
  searchText: Colors.white,
  searchIcon: Color(0x80FFFFFF),
  panelRadius: 8,
  actionPanelRadius: 8,
);

// ── Adolescente: violeta profundo ────────────
const _Palette _teenPalette = _Palette(
  gradient: [
    Color(0xFF1A1530), // violeta muy oscuro
    Color(0xFF241E3A), // índigo
    Color(0xFF1E2535), // azul pizarra
  ],
  surface: Color(0x1AFFFFFF),
  surfaceAlt: Color(0xEBFFFFFF),
  onSurface: Colors.white,
  onSurfaceMuted: Color(0x8CFFFFFF),
  metricChip: Color(0x2EFFFFFF),
  onMetricChip: Colors.white,
  sectionTitle: Colors.white,
  sectionSubtitle: Color(0x80FFFFFF),
  appBarForeground: Colors.white,
  searchFill: Color(0x1AFFFFFF),
  searchBorder: Color(0x2EFFFFFF),
  searchHint: Color(0x66FFFFFF),
  searchText: Colors.white,
  searchIcon: Color(0x80FFFFFF),
  panelRadius: 12,
  actionPanelRadius: 10,
);

// ── Niño: pastel vibrante ────────────────────
const _Palette _childPalette = _Palette(
  gradient: [
    Color(0xFFFFF3B0), // amarillo cálido
    Color(0xFFFFCCE0), // rosa claro
    Color(0xFFB8EEFF), // celeste suave
  ],
  surface: Color(0xC8FFFFFF), // blanco traslúcido sobre pasteles
  surfaceAlt: Color(0xD9FFFFFF),
  onSurface: Color(0xFF1C1A17),
  onSurfaceMuted: Color(0x9E1C1A17),
  metricChip: Color(0xCCFFFFFF),
  onMetricChip: Color(0xFF1C1A17),
  sectionTitle: Color(0xFF1C1A17),
  sectionSubtitle: Color(0x9E1C1A17),
  appBarForeground: Color(0xFF1C1A17),
  searchFill: Color(0xCCFFFFFF),
  searchBorder: Color(0x33000000),
  searchHint: Color(0x661C1A17),
  searchText: Color(0xFF1C1A17),
  searchIcon: Color(0x801C1A17),
  panelRadius: 22,
  actionPanelRadius: 18,
);

_Palette _paletteFor(_ProfileMode mode) {
  switch (mode) {
    case _ProfileMode.child:
      return _childPalette;
    case _ProfileMode.teen:
      return _teenPalette;
    case _ProfileMode.adult:
      return _adultPalette;
  }
}

// ─────────────────────────────────────────────
//  HomeScreen
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Book> _filtered(List<Book> books) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return books;
    return books
        .where(
          (b) =>
              b.title.toLowerCase().contains(q) ||
              b.category.toLowerCase().contains(q) ||
              b.description.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, controller, _) {
        final profile = controller.activeProfile;
        final mode = _resolveMode(profile);
        final palette = _paletteFor(mode);
        final childMode = mode == _ProfileMode.child;
        final allBooks = controller.catalogBooks;
        final featuredBooks = _filtered(allBooks);

        if (childMode) {
          return _KidsHomeScaffold(
            controller: controller,
            books: featuredBooks,
            allBooks: allBooks,
            searchController: _searchController,
            query: _query,
            onSearchChanged: (value) => setState(() => _query = value),
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: palette.appBarForeground,
            iconTheme: IconThemeData(color: palette.appBarForeground),
            titleTextStyle: TextStyle(
              color: palette.appBarForeground,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
            title: Text(profile == null ? 'Biblioteca' : profile.name),
            actions: [
              IconButton(
                tooltip: 'Cambiar perfil',
                onPressed: () => Navigator.pushNamed(context, '/profiles'),
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: palette.appBarForeground.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.switch_account_rounded,
                    color: palette.appBarForeground,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 360),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: palette.gradient,
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  if (childMode)
                    const _KidBackdrop()
                  else if (mode == _ProfileMode.teen)
                    const _TeenBackdrop()
                  else
                    const _CalmBackdrop(),
                  ListView(
                    padding: const EdgeInsets.fromLTRB(16, 76, 16, 30),
                    children: [
                      _WelcomePanel(
                        controller: controller,
                        palette: palette,
                        childMode: childMode,
                      ),
                      const SizedBox(height: 14),
                      const _LibraryCategoryRail(),
                      const SizedBox(height: 14),
                      // ── Barra de búsqueda ──
                      _SearchBar(
                        controller: _searchController,
                        palette: palette,
                        onChanged: (v) => setState(() => _query = v),
                      ),
                      const SizedBox(height: 12),
                      if (controller.loading)
                        _HomeLoadingBanner(
                          palette: palette,
                          message: controller.loadPhase.isEmpty
                              ? 'Actualizando biblioteca...'
                              : controller.loadPhase,
                        ),
                      if (childMode)
                        const SizedBox.shrink()
                      else if (controller.isPremium)
                        _PremiumStreakPanel(
                          controller: controller,
                          palette: palette,
                          childMode: childMode,
                        )
                      else ...[
                        _FreeRewardsPanel(
                          controller: controller,
                          palette: palette,
                          childMode: childMode,
                        ),
                      ],
                      if (controller.books.isEmpty) ...[
                        const SizedBox(height: 24),
                        _EmptyCatalogPanel(
                          palette: palette,
                          childMode: childMode,
                        ),
                      ] else if (featuredBooks.isEmpty) ...[
                        const SizedBox(height: 24),
                        _FilteredEmptyPanel(
                          palette: palette,
                          isSearch: _query.isNotEmpty,
                          childMode: childMode,
                        ),
                      ] else ...[
                        const SizedBox(height: 22),
                        _SectionHeader(
                          title: childMode
                              ? 'Tus cuentos favoritos'
                              : 'Recomendado para ti',
                          subtitle: _catalogSubtitle(controller),
                          palette: palette,
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
                              ? 'Lecturas con imágenes'
                              : 'Catálogo disponible',
                          subtitle: childMode
                              ? 'Solo contenido para niños y con ritmo visual.'
                              : 'Filtrado por edad y ordenado por tus gustos.',
                          palette: palette,
                          childMode: childMode,
                        ),
                        const SizedBox(height: 12),
                        for (final book in featuredBooks) ...[
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

  String _catalogSubtitle(HomeController controller) {
    final profile = controller.activeProfile;
    if (profile == null || profile.favoriteCategories.isEmpty) {
      return 'Libros listos para explorar.';
    }
    if (profile.role == 'teen') {
      return 'Coincidencias estrictas con: ${profile.favoriteCategories.join(', ')}';
    }
    return 'Priorizado por: ${profile.favoriteCategories.join(', ')}';
  }
}

// ─────────────────────────────────────────────
//  Barra de búsqueda
// ─────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final _Palette palette;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.palette,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: palette.searchFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.searchBorder),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search_rounded, color: palette.searchIcon, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: const InputDecorationTheme(
                  fillColor: Colors.transparent,
                  filled: true,
                  border: InputBorder.none,
                ),
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: TextStyle(color: palette.searchText),
                cursorColor: palette.searchText,
                decoration: InputDecoration(
                  hintText: 'Buscar libros, categorías…',
                  hintStyle: TextStyle(color: palette.searchHint),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.cancel_rounded,
                  color: palette.searchIcon,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  _WelcomePanel  (ahora recibe _Palette)
// ─────────────────────────────────────────────
class _LibraryCategoryRail extends StatelessWidget {
  const _LibraryCategoryRail();

  static const _items = [
    ('Infantil', Icons.auto_stories_rounded, Color(0xFFFF9FB7), '/infantil'),
    ('Juvenil', Icons.explore_rounded, Color(0xFF8EA7FF), null),
    ('Fantasía', Icons.castle_rounded, Color(0xFFD7A7F9), null),
    ('Romance', Icons.favorite_rounded, Color(0xFFFF8FB3), null),
    ('Terror', Icons.dark_mode_rounded, Color(0xFF7C6A8A), null),
    ('Educación', Icons.school_rounded, Color(0xFF77C7EE), null),
    ('Historia', Icons.history_edu_rounded, Color(0xFFFFB36B), null),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = _items[index];
          return InkWell(
            onTap: () {
              final route = item.$4;
              if (route != null) {
                Navigator.pushNamed(context, route);
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text('${item.$1} estará disponible pronto.'),
                ),
              );
            },
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 88,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: item.$3.withValues(alpha: 0.58)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.$2, color: item.$3, size: 27),
                  const SizedBox(height: 7),
                  Text(
                    item.$1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF28231E),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  final HomeController controller;
  final _Palette palette;
  final bool childMode;

  const _WelcomePanel({
    required this.controller,
    required this.palette,
    required this.childMode,
  });

  @override
  Widget build(BuildContext context) {
    final profile = controller.activeProfile;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(palette.panelRadius),
        border: Border.all(
          color: palette.onSurface.withValues(alpha: childMode ? 0.4 : 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: childMode ? 0.08 : 0.18),
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
                  borderRadius: BorderRadius.circular(childMode ? 18 : 8),
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
                          : 'Tu biblioteca está lista',
                      style: TextStyle(
                        color: palette.onSurface,
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
                      style: TextStyle(color: palette.onSurfaceMuted),
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
              if (!controller.isPremium)
                _Metric(
                  icon: Icons.paid_rounded,
                  label: '${controller.coins} monedas',
                  palette: palette,
                ),
              _Metric(
                icon: Icons.local_fire_department_rounded,
                label: '${controller.streakDays} días',
                palette: palette,
              ),
              _Metric(
                icon: controller.isPremium
                    ? Icons.workspace_premium_rounded
                    : Icons.lock_open_rounded,
                label: controller.isPremium ? 'Premium' : 'Gratis',
                palette: palette,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Panels de acción  (ahora usan _Palette)
// ─────────────────────────────────────────────
class _FreeRewardsPanel extends StatelessWidget {
  final HomeController controller;
  final _Palette palette;
  final bool childMode;

  const _FreeRewardsPanel({
    required this.controller,
    required this.palette,
    required this.childMode,
  });

  @override
  Widget build(BuildContext context) {
    return _ActionPanel(
      palette: palette,
      icon: Icons.play_circle_rounded,
      title: 'Ganar monedas viendo anuncios en video',
      body: 'Suma 30 monedas para consultas de IA sobre páginas o libros.',
      action: OutlinedButton.icon(
        onPressed: controller.actionLoading
            ? null
            : () => controller.rewardAdWatched(),
        icon: const Icon(Icons.add_circle_rounded),
        label: const Text('+30 monedas'),
      ),
    );
  }
}

class _HomeLoadingBanner extends StatelessWidget {
  final _Palette palette;
  final String message;

  const _HomeLoadingBanner({required this.palette, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.surfaceAlt.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(palette.actionPanelRadius),
          border: Border.all(color: AppTheme.gold.withValues(alpha: 0.28)),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppTheme.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumStreakPanel extends StatelessWidget {
  final HomeController controller;
  final _Palette palette;
  final bool childMode;

  const _PremiumStreakPanel({
    required this.controller,
    required this.palette,
    required this.childMode,
  });

  @override
  Widget build(BuildContext context) {
    return _ActionPanel(
      palette: palette,
      icon: Icons.local_fire_department_rounded,
      title: 'Racha Diaria Premium',
      body:
          'Tu constancia sigue creciendo. Las consultas con IA son ilimitadas.',
      action: FilledButton.icon(
        onPressed: () => _showShareModal(context, controller),
        icon: const Icon(Icons.ios_share_rounded),
        label: const Text('Compartir Racha'),
      ),
    );
  }

  Future<void> _showShareModal(
    BuildContext context,
    HomeController controller,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.ink,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: AppTheme.gold,
                      size: 40,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '${controller.streakDays} días leyendo',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${controller.activeProfile?.name ?? 'Mini Read'} mantiene su racha Premium en Mini Read.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    await controller.sharePremiumStreak();
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Enviar por WhatsApp'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  _ActionPanel  (ahora usa _Palette)
// ─────────────────────────────────────────────
class _ActionPanel extends StatelessWidget {
  final _Palette palette;
  final IconData icon;
  final String title;
  final String body;
  final Widget action;

  const _ActionPanel({
    required this.palette,
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(palette.actionPanelRadius),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.coral, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    color: AppTheme.ink.withValues(alpha: 0.62),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Flexible(child: action),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  _SectionHeader  (ahora usa _Palette)
// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final _Palette palette;
  final bool childMode;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.palette,
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
                style: TextStyle(
                  color: palette.sectionTitle,
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
          style: TextStyle(color: palette.sectionSubtitle, height: 1.32),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  _Metric  (ahora usa _Palette)
// ─────────────────────────────────────────────
class _Metric extends StatelessWidget {
  final IconData icon;
  final String label;
  final _Palette palette;

  const _Metric({
    required this.icon,
    required this.label,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: palette.metricChip,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: palette.onMetricChip, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: palette.onMetricChip,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Empty panels  (ahora usan _Palette)
// ─────────────────────────────────────────────
class _EmptyCatalogPanel extends StatelessWidget {
  final _Palette palette;
  final bool childMode;

  const _EmptyCatalogPanel({required this.palette, required this.childMode});

  @override
  Widget build(BuildContext context) {
    return _InfoPanel(
      palette: palette,
      icon: childMode ? Icons.auto_stories_rounded : Icons.cloud_off_rounded,
      iconColor: childMode
          ? AppTheme.coral
          : Theme.of(context).colorScheme.primary,
      text: childMode
          ? 'Estamos preparando nuevos cuentos infantiles. Vuelve pronto para descubrir más aventuras.'
          : 'No se encontraron libros en Firestore. Verifica documentos activos en la colección books.',
    );
  }
}

class _FilteredEmptyPanel extends StatelessWidget {
  final _Palette palette;
  final bool isSearch;
  final bool childMode;

  const _FilteredEmptyPanel({
    required this.palette,
    this.isSearch = false,
    required this.childMode,
  });

  @override
  Widget build(BuildContext context) {
    return _InfoPanel(
      palette: palette,
      icon: isSearch
          ? Icons.search_off_rounded
          : childMode
          ? Icons.auto_stories_rounded
          : Icons.tune_rounded,
      iconColor: AppTheme.coral,
      text: isSearch
          ? 'No se encontraron libros que coincidan con tu búsqueda. Prueba con otras palabras clave.'
          : childMode
          ? 'Todavía no hay cuentos disponibles para esta categoría. Prueba otra aventura.'
          : 'El catálogo cargó bien, pero no hay libros que coincidan con este perfil y sus preferencias.',
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final _Palette palette;
  final IconData icon;
  final Color iconColor;
  final String text;

  const _InfoPanel({
    required this.palette,
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(palette.actionPanelRadius),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppTheme.ink,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Book widgets  (sin cambios de lógica)
// ─────────────────────────────────────────────
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
      borderRadius: BorderRadius.circular(childMode ? 22 : 8),
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
                borderRadius: BorderRadius.circular(childMode ? 22 : 8),
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
        borderRadius: BorderRadius.circular(childMode ? 18 : 8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(childMode ? 18 : 8),
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
                  borderRadius: BorderRadius.circular(childMode ? 18 : 8),
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

// ─────────────────────────────────────────────
//  Benefit row (modal Premium)
// ─────────────────────────────────────────────
// ─────────────────────────────────────────────
//  Backdrops
// ─────────────────────────────────────────────
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

class _KidsHomeScaffold extends StatefulWidget {
  final HomeController controller;
  final List<Book> books;
  final List<Book> allBooks;
  final TextEditingController searchController;
  final String query;
  final ValueChanged<String> onSearchChanged;

  const _KidsHomeScaffold({
    required this.controller,
    required this.books,
    required this.allBooks,
    required this.searchController,
    required this.query,
    required this.onSearchChanged,
  });

  @override
  State<_KidsHomeScaffold> createState() => _KidsHomeScaffoldState();
}

class _KidsHomeScaffoldState extends State<_KidsHomeScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _introController;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedCategory = 'Todos';
  int _selectedTab = 0;
  bool _favoritesLoading = true;
  final Set<String> _favoriteIds = <String>{};
  final Map<String, DateTime> _favoriteDates = <String, DateTime>{};

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..forward();
    _loadFavorites();
  }

  @override
  void dispose() {
    _introController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<Book> get _visibleBooks {
    if (_selectedCategory == 'Todos') return widget.allBooks;
    return widget.allBooks
        .where(
          (book) =>
              book.category.toLowerCase() == _selectedCategory.toLowerCase() ||
              book.tags.any(
                (tag) => tag.toLowerCase() == _selectedCategory.toLowerCase(),
              ),
        )
        .toList(growable: false);
  }

  CollectionReference<Map<String, dynamic>>? get _favoritesRef {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites');
  }

  Future<void> _loadFavorites() async {
    final ref = _favoritesRef;
    if (ref == null) {
      if (mounted) setState(() => _favoritesLoading = false);
      return;
    }

    try {
      final snapshot = await ref.orderBy('createdAt', descending: true).get();
      if (!mounted) return;
      setState(() {
        _favoriteIds
          ..clear()
          ..addAll(snapshot.docs.map((doc) => doc.id));
        _favoriteDates
          ..clear()
          ..addEntries(
            snapshot.docs.map((doc) {
              final timestamp = doc.data()['createdAt'];
              final date = timestamp is Timestamp
                  ? timestamp.toDate()
                  : DateTime.fromMillisecondsSinceEpoch(0);
              return MapEntry(doc.id, date);
            }),
          );
        _favoritesLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _favoritesLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('No se pudieron cargar favoritos: $error'),
        ),
      );
    }
  }

  Future<void> _toggleFavorite(Book book) async {
    final ref = _favoritesRef;
    if (ref == null) return;

    final isFavorite = _favoriteIds.contains(book.id);
    setState(() {
      if (isFavorite) {
        _favoriteIds.remove(book.id);
        _favoriteDates.remove(book.id);
      } else {
        _favoriteIds.add(book.id);
        _favoriteDates[book.id] = DateTime.now();
      }
    });

    try {
      if (isFavorite) {
        await ref.doc(book.id).delete();
      } else {
        await ref.doc(book.id).set({
          'bookId': book.id,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        if (isFavorite) {
          _favoriteIds.add(book.id);
          _favoriteDates[book.id] = DateTime.now();
        } else {
          _favoriteIds.remove(book.id);
          _favoriteDates.remove(book.id);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('No se pudo actualizar favoritos: $error'),
        ),
      );
    }
  }

  List<Book> _favoriteBooks(List<Book> books) {
    final favorites = books
        .where((book) => _favoriteIds.contains(book.id))
        .toList(growable: false);
    favorites.sort((a, b) {
      final left =
          _favoriteDates[a.id] ?? DateTime.fromMillisecondsSinceEpoch(0);
      final right =
          _favoriteDates[b.id] ?? DateTime.fromMillisecondsSinceEpoch(0);
      return right.compareTo(left);
    });
    return favorites;
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.controller.activeProfile;
    final visibleBooks = _visibleBooks;
    final heroBook = visibleBooks.isNotEmpty
        ? visibleBooks.first
        : widget.allBooks.isNotEmpty
        ? widget.allBooks.first
        : null;
    final recommendations = visibleBooks.isNotEmpty
        ? visibleBooks
        : widget.allBooks;
    final classics = recommendations
        .where((book) => _containsAny(book, ['cuento', 'clasico', 'infantil']))
        .toList(growable: false);
    final fantasy = recommendations
        .where((book) => _containsAny(book, ['fantasia', 'aventura', 'magia']))
        .toList(growable: false);
    final favoriteBooks = _favoriteBooks(widget.allBooks);

    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      body: AnimatedBuilder(
        animation: _introController,
        builder: (context, _) {
          final intro = Curves.easeOutCubic.transform(_introController.value);
          return Stack(
            children: [
              const _KidsPremiumBackdrop(),
              const _KidsSparkleLayer(),
              SafeArea(
                child: ListView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 104),
                  children: [
                    Transform.translate(
                      offset: Offset(0, 18 * (1 - intro)),
                      child: Opacity(
                        opacity: intro,
                        child: _KidsHeader(
                          profileName: profile?.name ?? 'Mini Read',
                          avatarUrl: profile?.avatarUrl ?? '',
                          accentColor: Color(
                            profile?.accentColor ?? 0xFFD4AF37,
                          ),
                          onProfiles: () =>
                              Navigator.pushNamed(context, '/profiles'),
                          onNotifications: () =>
                              _showKidsNotifications(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_selectedTab == 1) ...[
                      _KidsSearchView(
                        controller: widget.searchController,
                        focusNode: _searchFocusNode,
                        books: widget.books,
                        favoriteIds: _favoriteIds,
                        onChanged: widget.onSearchChanged,
                        onFavorite: _toggleFavorite,
                        onTap: _openBook,
                      ),
                    ] else if (_selectedTab == 2) ...[
                      _KidsLibraryView(
                        books: recommendations,
                        favoriteIds: _favoriteIds,
                        onFavorite: _toggleFavorite,
                        onTap: _openBook,
                      ),
                    ] else if (_selectedTab == 3) ...[
                      _KidsFavoritesView(
                        loading: _favoritesLoading,
                        books: favoriteBooks,
                        favoriteIds: _favoriteIds,
                        onFavorite: _toggleFavorite,
                        onTap: _openBook,
                      ),
                    ] else ...[
                      if (heroBook != null)
                        _KidsHeroBanner(
                          book: heroBook,
                          favorite: _favoriteIds.contains(heroBook.id),
                          onRead: () => Navigator.pushNamed(
                            context,
                            heroBook.pdfUrl.trim().isNotEmpty
                                ? '/pdf-reader'
                                : '/book',
                            arguments: heroBook,
                          ),
                          onFavorite: () => _toggleFavorite(heroBook),
                        ),
                      const SizedBox(height: 18),
                      _KidsCategoryCarousel(
                        selected: _selectedCategory,
                        categories: _kidsCategories(widget.allBooks),
                        onSelected: (category) =>
                            setState(() => _selectedCategory = category),
                      ),
                      if (widget.controller.loading) ...[
                        const SizedBox(height: 16),
                        _KidsLoadingStrip(
                          message: widget.controller.loadPhase.isEmpty
                              ? 'Preparando aventuras...'
                              : widget.controller.loadPhase,
                        ),
                      ],
                      if (recommendations.isEmpty) ...[
                        const SizedBox(height: 24),
                        const _KidsEmptyCatalog(),
                      ] else ...[
                        const SizedBox(height: 26),
                        _KidsBookSection(
                          title: 'Continúa leyendo',
                          icon: Icons.star_rounded,
                          books: recommendations,
                          favoriteIds: _favoriteIds,
                          onFavorite: _toggleFavorite,
                          onTap: _openBook,
                        ),
                        const SizedBox(height: 24),
                        _KidsBookSection(
                          title: 'Recomendados',
                          icon: Icons.auto_stories_rounded,
                          books: recommendations.reversed.toList(
                            growable: false,
                          ),
                          favoriteIds: _favoriteIds,
                          onFavorite: _toggleFavorite,
                          onTap: _openBook,
                        ),
                        const SizedBox(height: 24),
                        _KidsBookSection(
                          title: 'Nuevos cuentos',
                          icon: Icons.new_releases_rounded,
                          books: recommendations,
                          favoriteIds: _favoriteIds,
                          onFavorite: _toggleFavorite,
                          onTap: _openBook,
                        ),
                        if (fantasy.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _KidsBookSection(
                            title: 'Aventuras mágicas',
                            icon: Icons.castle_rounded,
                            books: fantasy,
                            favoriteIds: _favoriteIds,
                            onFavorite: _toggleFavorite,
                            onTap: _openBook,
                          ),
                        ],
                        if (classics.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _KidsBookSection(
                            title: 'Clásicos',
                            icon: Icons.local_library_rounded,
                            books: classics,
                            favoriteIds: _favoriteIds,
                            onFavorite: _toggleFavorite,
                            onTap: _openBook,
                          ),
                        ],
                        const SizedBox(height: 24),
                        _KidsBookSection(
                          title: 'Aprendizaje',
                          icon: Icons.psychology_rounded,
                          books: recommendations,
                          favoriteIds: _favoriteIds,
                          onFavorite: _toggleFavorite,
                          onTap: _openBook,
                        ),
                        const SizedBox(height: 24),
                        _KidsBookSection(
                          title: 'Más populares',
                          icon: Icons.trending_up_rounded,
                          books: recommendations.reversed.toList(
                            growable: false,
                          ),
                          favoriteIds: _favoriteIds,
                          onFavorite: _toggleFavorite,
                          onTap: _openBook,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: _KidsBottomNavigation(
                  currentIndex: _selectedTab,
                  onHome: () => setState(() => _selectedTab = 0),
                  onSearch: () {
                    setState(() => _selectedTab = 1);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _searchFocusNode.requestFocus();
                    });
                  },
                  onLibrary: () => setState(() => _selectedTab = 2),
                  onFavorites: () => setState(() => _selectedTab = 3),
                  onProfile: () => Navigator.pushNamed(context, '/profile'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openBook(Book book) {
    Navigator.pushNamed(context, '/book', arguments: book);
  }

  Future<void> _showKidsNotifications(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF11100D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _KidsNotificationsSheet(),
    );
  }

  bool _containsAny(Book book, List<String> terms) {
    final haystack = [
      book.title,
      book.category,
      book.description,
      ...book.tags,
    ].join(' ').toLowerCase();
    return terms.any((term) => haystack.contains(term));
  }

  List<String> _kidsCategories(List<Book> books) {
    final categories = <String>{
      'Todos',
      'Aventuras',
      'Fantasía',
      'Clásicos',
      'Aprendizaje',
      'Animales',
      'Princesas',
    };
    return categories.toList(growable: false);
  }
}

class _KidsHeader extends StatelessWidget {
  final String profileName;
  final String avatarUrl;
  final Color accentColor;
  final VoidCallback onProfiles;
  final VoidCallback onNotifications;

  const _KidsHeader({
    required this.profileName,
    required this.avatarUrl,
    required this.accentColor,
    required this.onProfiles,
    required this.onNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _KidsAvatar(url: avatarUrl, name: profileName, color: accentColor),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profileName.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        _NotificationBell(onTap: onNotifications),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: onProfiles,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.09),
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.switch_account_rounded),
        ),
      ],
    );
  }
}

class _KidsAvatar extends StatelessWidget {
  final String url;
  final String name;
  final Color color;

  const _KidsAvatar({
    required this.url,
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? 'M' : name.trim()[0].toUpperCase();
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.gold.withValues(alpha: 0.54),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(
        child: url.trim().isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    _AvatarFallback(initial: initial, color: color),
              )
            : _AvatarFallback(initial: initial, color: color),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String initial;
  final Color color;

  const _AvatarFallback({required this.initial, required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, AppTheme.gold]),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final VoidCallback onTap;

  const _NotificationBell({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton.filled(
          onPressed: onTap,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.09),
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        Positioned(
          right: 4,
          top: 3,
          child: Container(
            width: 17,
            height: 17,
            decoration: BoxDecoration(
              color: const Color(0xFFE53935),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.obsidian, width: 2),
            ),
            child: const Center(
              child: Text(
                '3',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _KidsNotificationsSheet extends StatelessWidget {
  const _KidsNotificationsSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Notificaciones',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            const _KidsNotificationItem(
              icon: Icons.auto_stories_rounded,
              title: 'Nuevo libro disponible',
              body: 'Heidi ya está en tu biblioteca.',
            ),
            const _KidsNotificationItem(
              icon: Icons.schedule_rounded,
              title: 'Próximamente',
              body: 'Peter Pan llegará en una nueva colección.',
            ),
            const _KidsNotificationItem(
              icon: Icons.collections_bookmark_rounded,
              title: 'Nueva colección',
              body: 'Cuentos clásicos para leer en familia.',
            ),
          ],
        ),
      ),
    );
  }
}

class _KidsNotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _KidsNotificationItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.gold, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KidsHeroBanner extends StatelessWidget {
  final Book book;
  final bool favorite;
  final VoidCallback onRead;
  final VoidCallback onFavorite;

  const _KidsHeroBanner({
    required this.book,
    required this.favorite,
    required this.onRead,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 252,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.42),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _KidsCoverImage(book: book),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.92),
                  Colors.black.withValues(alpha: 0.62),
                  Colors.black.withValues(alpha: 0.18),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const _GoldLabel(label: 'Destacado para ti'),
                      const SizedBox(height: 10),
                      Text(
                        'Libro destacado de la semana',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.62),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1.02,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.gold,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        book.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          height: 1.28,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          FilledButton.icon(
                            onPressed: onRead,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.gold,
                              foregroundColor: AppTheme.obsidian,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Leer ahora'),
                          ),
                          const SizedBox(width: 10),
                          _FavoriteCircleButton(
                            favorite: favorite,
                            onPressed: onFavorite,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                _HeroPoster(book: book),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPoster extends StatelessWidget {
  final Book book;

  const _HeroPoster({required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 152,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: _KidsCoverImage(book: book),
    );
  }
}

class _FavoriteCircleButton extends StatefulWidget {
  final bool favorite;
  final VoidCallback onPressed;
  final bool compact;

  const _FavoriteCircleButton({
    required this.favorite,
    required this.onPressed,
    this.compact = false,
  });

  @override
  State<_FavoriteCircleButton> createState() => _FavoriteCircleButtonState();
}

class _FavoriteCircleButtonState extends State<_FavoriteCircleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      lowerBound: 0.86,
      upperBound: 1.16,
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant _FavoriteCircleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.favorite != widget.favorite) {
      _bounce();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.compact ? 36.0 : 44.0;
    return ScaleTransition(
      scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _bounce();
            widget.onPressed();
          },
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.favorite
                  ? AppTheme.gold
                  : Colors.black.withValues(alpha: 0.58),
              border: Border.all(
                color: widget.favorite
                    ? AppTheme.gold
                    : Colors.white.withValues(alpha: 0.22),
              ),
              boxShadow: [
                BoxShadow(
                  color: (widget.favorite ? AppTheme.gold : Colors.black)
                      .withValues(alpha: widget.favorite ? 0.35 : 0.28),
                  blurRadius: widget.favorite ? 18 : 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              widget.favorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: widget.favorite ? AppTheme.obsidian : Colors.white,
              size: widget.compact ? 19 : 22,
            ),
          ),
        ),
      ),
    );
  }

  void _bounce() {
    _controller.forward(from: 0.86).then((_) {
      if (mounted) _controller.reverse();
    });
  }
}

class _GoldLabel extends StatelessWidget {
  final String label;

  const _GoldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.gold.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.34)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.gold,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _KidsSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _KidsSearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.065),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(
            Icons.search_rounded,
            color: Colors.white.withValues(alpha: 0.66),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar cuentos, autores o aventuras',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.46),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              onPressed: () {
                controller.clear();
                onChanged('');
              },
              color: Colors.white54,
              icon: const Icon(Icons.close_rounded),
            ),
        ],
      ),
    );
  }
}

class _KidsSearchView extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<Book> books;
  final Set<String> favoriteIds;
  final ValueChanged<String> onChanged;
  final ValueChanged<Book> onFavorite;
  final ValueChanged<Book> onTap;

  const _KidsSearchView({
    required this.controller,
    required this.focusNode,
    required this.books,
    required this.favoriteIds,
    required this.onChanged,
    required this.onFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final query = controller.text.trim().toLowerCase();
    final results = query.isEmpty
        ? books
        : books
              .where(
                (book) =>
                    book.title.toLowerCase().contains(query) ||
                    book.author.toLowerCase().contains(query) ||
                    book.description.toLowerCase().contains(query) ||
                    book.category.toLowerCase().contains(query),
              )
              .toList(growable: false);
    final authors = books
        .map((book) => book.author.trim())
        .where((author) => author.isNotEmpty)
        .toSet()
        .take(6)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _KidsPageTitle(title: 'Buscar'),
        const SizedBox(height: 16),
        _KidsSearchBar(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
        ),
        const SizedBox(height: 22),
        const _KidsMiniTitle('Búsquedas recientes'),
        const SizedBox(height: 10),
        const Wrap(
          spacing: 9,
          runSpacing: 9,
          children: [
            _RecentSearchChip(label: 'Cuentos clásicos'),
            _RecentSearchChip(label: 'Aventuras'),
            _RecentSearchChip(label: 'Fantasía'),
          ],
        ),
        const SizedBox(height: 24),
        _KidsBookGrid(
          title: query.isEmpty ? 'Libros populares' : 'Resultados',
          books: results,
          favoriteIds: favoriteIds,
          onFavorite: onFavorite,
          onTap: onTap,
        ),
        if (authors.isNotEmpty) ...[
          const SizedBox(height: 24),
          const _KidsMiniTitle('Autores destacados'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: authors
                .map((author) => _AuthorChip(name: author))
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _KidsLibraryView extends StatelessWidget {
  final List<Book> books;
  final Set<String> favoriteIds;
  final ValueChanged<Book> onFavorite;
  final ValueChanged<Book> onTap;

  const _KidsLibraryView({
    required this.books,
    required this.favoriteIds,
    required this.onFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _KidsBookGrid(
      title: 'Biblioteca',
      books: books,
      favoriteIds: favoriteIds,
      onFavorite: onFavorite,
      onTap: onTap,
    );
  }
}

class _KidsFavoritesView extends StatelessWidget {
  final bool loading;
  final List<Book> books;
  final Set<String> favoriteIds;
  final ValueChanged<Book> onFavorite;
  final ValueChanged<Book> onTap;

  const _KidsFavoritesView({
    required this.loading,
    required this.books,
    required this.favoriteIds,
    required this.onFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const _KidsLoadingStrip(message: 'Cargando favoritos...');
    }
    if (books.isEmpty) return const _KidsEmptyFavorites();
    return _KidsBookGrid(
      title: 'Mis favoritos',
      books: books,
      favoriteIds: favoriteIds,
      onFavorite: onFavorite,
      onTap: onTap,
    );
  }
}

class _KidsBookGrid extends StatelessWidget {
  final String title;
  final List<Book> books;
  final Set<String> favoriteIds;
  final ValueChanged<Book> onFavorite;
  final ValueChanged<Book> onTap;

  const _KidsBookGrid({
    required this.title,
    required this.books,
    required this.favoriteIds,
    required this.onFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _KidsPageTitle(title: title),
        const SizedBox(height: 16),
        if (books.isEmpty)
          const _KidsEmptyCatalog()
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 720 ? 4 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: books.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 18,
                  childAspectRatio: 0.58,
                ),
                itemBuilder: (context, index) {
                  final book = books[index];
                  return _KidsBookCard(
                    book: book,
                    favorite: favoriteIds.contains(book.id),
                    onFavorite: () => onFavorite(book),
                    onTap: () => onTap(book),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}

class _KidsPageTitle extends StatelessWidget {
  final String title;

  const _KidsPageTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.w900,
        height: 1,
      ),
    );
  }
}

class _KidsMiniTitle extends StatelessWidget {
  final String title;

  const _KidsMiniTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _RecentSearchChip extends StatelessWidget {
  final String label;

  const _RecentSearchChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      avatar: const Icon(Icons.history_rounded, size: 17),
      backgroundColor: Colors.white.withValues(alpha: 0.08),
      side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.16)),
      labelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _AuthorChip extends StatelessWidget {
  final String name;

  const _AuthorChip({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.14)),
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _KidsCategoryCarousel extends StatelessWidget {
  final String selected;
  final List<String> categories;
  final ValueChanged<String> onSelected;

  const _KidsCategoryCarousel({
    required this.selected,
    required this.categories,
    required this.onSelected,
  });

  static final Map<String, IconData> _icons = {
    'Todos': Icons.auto_awesome_rounded,
    'Aventuras': Icons.explore_rounded,
    'Fantasía': Icons.castle_rounded,
    'Clásicos': Icons.local_library_rounded,
    'Aprendizaje': Icons.psychology_rounded,
    'Animales': Icons.pets_rounded,
    'Princesas': Icons.diamond_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final active = category == selected;
          return InkWell(
            borderRadius: BorderRadius.circular(99),
            onTap: () => onSelected(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: active
                    ? AppTheme.gold.withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.075),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: active
                      ? AppTheme.gold
                      : Colors.white.withValues(alpha: 0.12),
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: AppTheme.gold.withValues(alpha: 0.28),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    _icons[category] ?? Icons.bookmark_rounded,
                    size: 18,
                    color: active ? AppTheme.obsidian : Colors.white70,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    category,
                    style: TextStyle(
                      color: active ? AppTheme.obsidian : Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _KidsBookSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Book> books;
  final Set<String> favoriteIds;
  final ValueChanged<Book> onFavorite;
  final ValueChanged<Book> onTap;

  const _KidsBookSection({
    required this.title,
    required this.icon,
    required this.books,
    required this.favoriteIds,
    required this.onFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.gold, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 254,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final book = books[index];
              return _KidsBookCard(
                book: book,
                favorite: favoriteIds.contains(book.id),
                onFavorite: () => onFavorite(book),
                onTap: () => onTap(book),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _KidsBookCard extends StatefulWidget {
  final Book book;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  const _KidsBookCard({
    required this.book,
    required this.favorite,
    required this.onFavorite,
    required this.onTap,
  });

  @override
  State<_KidsBookCard> createState() => _KidsBookCardState();
}

class _KidsBookCardState extends State<_KidsBookCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 220),
          scale: _hovered ? 1.05 : 1,
          child: SizedBox(
            width: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 140,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _hovered
                          ? AppTheme.gold.withValues(alpha: 0.72)
                          : AppTheme.gold.withValues(alpha: 0.14),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_hovered ? AppTheme.gold : Colors.black)
                            .withValues(alpha: _hovered ? 0.28 : 0.32),
                        blurRadius: _hovered ? 24 : 16,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _KidsCoverImage(book: widget.book),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _FavoriteCircleButton(
                          favorite: widget.favorite,
                          onPressed: widget.onFavorite,
                          compact: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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

class _KidsCoverImage extends StatelessWidget {
  final Book book;

  const _KidsCoverImage({required this.book});

  @override
  Widget build(BuildContext context) {
    if (book.coverUrl.trim().isNotEmpty) {
      return Image.network(
        book.coverUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _KidsCoverFallback(book: book),
      );
    }
    return _KidsCoverFallback(book: book);
  }
}

class _KidsCoverFallback extends StatelessWidget {
  final Book book;

  const _KidsCoverFallback({required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(book.accentColor),
            const Color(0xFF21180C),
            const Color(0xFF050505),
          ],
        ),
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
            height: 1.04,
          ),
        ),
      ),
    );
  }
}

class _KidsLoadingStrip extends StatelessWidget {
  final String message;

  const _KidsLoadingStrip({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KidsEmptyCatalog extends StatelessWidget {
  const _KidsEmptyCatalog();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.16)),
      ),
      child: const Text(
        'No encontramos aventuras con esa búsqueda. Prueba otro personaje o categoría.',
        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _KidsEmptyFavorites extends StatelessWidget {
  const _KidsEmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.14)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.gold.withValues(alpha: 0.13),
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              color: AppTheme.gold,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Aún no tienes favoritos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Marca cuentos con el corazón para guardarlos aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _KidsBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onHome;
  final VoidCallback onSearch;
  final VoidCallback onLibrary;
  final VoidCallback onFavorites;
  final VoidCallback onProfile;

  const _KidsBottomNavigation({
    required this.currentIndex,
    required this.onHome,
    required this.onSearch,
    required this.onLibrary,
    required this.onFavorites,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xF20A0A0A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.46),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _KidsNavItem(
            icon: Icons.home_rounded,
            label: 'Inicio',
            active: currentIndex == 0,
            onTap: onHome,
          ),
          _KidsNavItem(
            icon: Icons.search_rounded,
            label: 'Buscar',
            active: currentIndex == 1,
            onTap: onSearch,
          ),
          _KidsNavItem(
            icon: Icons.auto_stories_rounded,
            label: 'Biblioteca',
            active: currentIndex == 2,
            onTap: onLibrary,
          ),
          _KidsNavItem(
            icon: Icons.favorite_rounded,
            label: 'Favoritos',
            active: currentIndex == 3,
            onTap: onFavorites,
          ),
          _KidsNavItem(
            icon: Icons.person_rounded,
            label: 'Perfil',
            onTap: onProfile,
          ),
        ],
      ),
    );
  }
}

class _KidsNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _KidsNavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTheme.gold : Colors.white.withValues(alpha: 0.62);
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: active ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: active ? 18 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: AppTheme.gold,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KidsPremiumBackdrop extends StatelessWidget {
  const _KidsPremiumBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.2, -0.8),
          radius: 1.35,
          colors: [Color(0xFF34230D), Color(0xFF100F0C), Color(0xFF030303)],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

class _KidsSparkleLayer extends StatelessWidget {
  const _KidsSparkleLayer();

  @override
  Widget build(BuildContext context) {
    const particles = [
      (0.08, 0.13, 2.0),
      (0.72, 0.11, 2.7),
      (0.88, 0.32, 1.9),
      (0.16, 0.52, 2.3),
      (0.78, 0.76, 2.0),
      (0.34, 0.86, 1.7),
    ];

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              for (final particle in particles)
                Positioned(
                  left: constraints.maxWidth * particle.$1,
                  top: constraints.maxHeight * particle.$2,
                  child: Container(
                    width: particle.$3,
                    height: particle.$3,
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.34),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.gold.withValues(alpha: 0.28),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TeenBackdrop extends StatelessWidget {
  const _TeenBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 80,
            right: 20,
            child: Icon(
              Icons.headphones_rounded,
              color: Colors.white.withValues(alpha: 0.08),
              size: 110,
            ),
          ),
          Positioned(
            bottom: 100,
            left: 18,
            child: Icon(
              Icons.bolt_rounded,
              color: Colors.white.withValues(alpha: 0.07),
              size: 96,
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
              color: Colors.white.withValues(alpha: 0.06),
              size: 106,
            ),
          ),
          Positioned(
            bottom: 72,
            left: 26,
            child: Icon(
              Icons.bookmark_rounded,
              color: Colors.white.withValues(alpha: 0.06),
              size: 90,
            ),
          ),
        ],
      ),
    );
  }
}
