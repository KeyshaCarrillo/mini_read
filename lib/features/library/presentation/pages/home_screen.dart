import 'package:flutter/material.dart';
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
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/profiles'),
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
                  if (controller.loading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ListView(
                      padding: const EdgeInsets.fromLTRB(16, 76, 16, 30),
                      children: [
                        _WelcomePanel(
                          controller: controller,
                          palette: palette,
                          childMode: childMode,
                        ),
                        const SizedBox(height: 14),
                        // ── Barra de búsqueda ──
                        _SearchBar(
                          controller: _searchController,
                          palette: palette,
                          onChanged: (v) => setState(() => _query = v),
                        ),
                        const SizedBox(height: 12),
                        if (controller.isPremium)
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
                          const SizedBox(height: 12),
                          _PremiumUpsellPanel(
                            controller: controller,
                            palette: palette,
                            childMode: childMode,
                          ),
                        ],
                        if (controller.books.isEmpty) ...[
                          const SizedBox(height: 24),
                          _EmptyCatalogPanel(palette: palette),
                        ] else if (featuredBooks.isEmpty) ...[
                          const SizedBox(height: 24),
                          _FilteredEmptyPanel(
                            palette: palette,
                            isSearch: _query.isNotEmpty,
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

class _PremiumUpsellPanel extends StatelessWidget {
  final HomeController controller;
  final _Palette palette;
  final bool childMode;

  const _PremiumUpsellPanel({
    required this.controller,
    required this.palette,
    required this.childMode,
  });

  @override
  Widget build(BuildContext context) {
    return _ActionPanel(
      palette: palette,
      icon: Icons.workspace_premium_rounded,
      title: 'Obtener Premium',
      body: 'IA ilimitada, cero anuncios y una experiencia de lectura limpia.',
      action: FilledButton.icon(
        onPressed: () => _showPremiumModal(context, controller),
        icon: const Icon(Icons.bolt_rounded),
        label: const Text('Obtener Premium'),
      ),
    );
  }

  Future<void> _showPremiumModal(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mini Read Premium',
                style: TextStyle(
                  color: AppTheme.ink,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '\$4.99 / mes',
                style: TextStyle(
                  color: AppTheme.ink.withValues(alpha: 0.64),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              const _BenefitRow(
                icon: Icons.auto_awesome_rounded,
                label: 'Consultas ilimitadas con IA de lectura',
              ),
              const _BenefitRow(
                icon: Icons.block_rounded,
                label: 'Sin contador de monedas ni anuncios',
              ),
              const _BenefitRow(
                icon: Icons.ios_share_rounded,
                label: 'Tarjeta visual para compartir tu racha',
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: controller.actionLoading
                      ? null
                      : () async {
                          await controller.upgradeToPremium();
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Compra simulada exitosa.'),
                            ),
                          );
                        },
                  icon: const Icon(Icons.credit_card_rounded),
                  label: const Text('Pagar Ahora'),
                ),
              ),
            ],
          ),
        );
      },
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

  const _EmptyCatalogPanel({required this.palette});

  @override
  Widget build(BuildContext context) {
    return _InfoPanel(
      palette: palette,
      icon: Icons.cloud_off_rounded,
      iconColor: Theme.of(context).colorScheme.primary,
      text:
          'No se encontraron libros en la API. Revisa que el endpoint de Vercel tenga datos en el arreglo books.',
    );
  }
}

class _FilteredEmptyPanel extends StatelessWidget {
  final _Palette palette;
  final bool isSearch;

  const _FilteredEmptyPanel({required this.palette, this.isSearch = false});

  @override
  Widget build(BuildContext context) {
    return _InfoPanel(
      palette: palette,
      icon: isSearch ? Icons.search_off_rounded : Icons.tune_rounded,
      iconColor: AppTheme.coral,
      text: isSearch
          ? 'No se encontraron libros que coincidan con tu búsqueda. Prueba con otras palabras clave.'
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
class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BenefitRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.coral),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

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
