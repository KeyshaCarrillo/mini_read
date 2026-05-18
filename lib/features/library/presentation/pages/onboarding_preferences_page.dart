import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../controllers/library_controller.dart';

class OnboardingPreferencesPage extends StatefulWidget {
  final LibraryController controller;

  const OnboardingPreferencesPage({super.key, required this.controller});

  @override
  State<OnboardingPreferencesPage> createState() =>
      _OnboardingPreferencesPageState();
}

class _OnboardingPreferencesPageState extends State<OnboardingPreferencesPage> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _step = 0;
  String _ageGroup = 'Adultos';
  String _readingMood = 'Quiero descubrir buenos libros';
  final Set<String> _selectedCategories = {'Aventura', 'Drama'};

  static const List<_AgeOption> _ageOptions = [
    _AgeOption(
      label: 'Ninos',
      range: '5 - 12',
      mood: 'Historias visuales, cortas y acompanadas',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFFFF8FB3),
    ),
    _AgeOption(
      label: 'Adolescentes',
      range: '13 - 17',
      mood: 'Aventura, misterio y emociones faciles de seguir',
      icon: Icons.explore_rounded,
      color: Color(0xFF6FA8C8),
    ),
    _AgeOption(
      label: 'Adultos',
      range: '18+',
      mood: 'Clasicos, drama y lecturas con mas profundidad',
      icon: Icons.local_library_rounded,
      color: Color(0xFF5B7C62),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  List<String> get _categoryOptions {
    final options = widget.controller.availableCategories;
    if (options.isEmpty) {
      return const ['Romance', 'Drama', 'Aventura', 'Suspenso', 'Ninos'];
    }
    return options;
  }

  Future<void> _next() async {
    if (_step < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    final profile = await widget.controller.createProfile(
      OnboardingProfileDraft(
        name: _nameController.text,
        ageGroup: _ageGroup,
        readingMood: _readingMood,
        favoriteCategories: _selectedCategories.toList(),
      ),
    );
    await widget.controller.selectProfile(profile);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  void _back() {
    if (_step == 0) {
      Navigator.maybePop(context);
      return;
    }
    _pageController.previousPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isChild = _ageGroup == 'Ninos';

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isChild
                ? const [
                    Color(0xFFFFF0A8),
                    Color(0xFFFFC0D9),
                    Color(0xFFB8F3E6),
                  ]
                : const [
                    Color(0xFFFFFCF4),
                    Color(0xFFEAF3F0),
                    Color(0xFFF6E8DD),
                  ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const _CelebrationBackdrop(),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Volver',
                          onPressed: _back,
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: (_step + 1) / 3,
                              minHeight: 8,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.58,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (value) => setState(() => _step = value),
                      children: [
                        _StepCard(
                          eyebrow: 'Bienvenida',
                          title: 'Vamos a crear tu primer perfil',
                          subtitle:
                              'Asi Mini Read puede mostrar libros adecuados desde el inicio y guardar el perfil en Firebase.',
                          child: TextField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Nombre del perfil',
                              hintText: 'Ej. Katherine',
                              prefixIcon: Icon(Icons.badge_rounded),
                            ),
                          ),
                        ),
                        _StepCard(
                          eyebrow: 'Edad',
                          title: 'Que rango describe mejor a este lector?',
                          subtitle:
                              'Esto cambia recomendaciones, lenguaje y apariencia del perfil.',
                          child: Column(
                            children: [
                              for (final option in _ageOptions) ...[
                                _AgeTile(
                                  option: option,
                                  selected: _ageGroup == option.label,
                                  onTap: () {
                                    setState(() {
                                      _ageGroup = option.label;
                                      _readingMood = option.mood;
                                      if (option.label == 'Ninos') {
                                        _selectedCategories.add('Ninos');
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                              ],
                            ],
                          ),
                        ),
                        _StepCard(
                          eyebrow: 'Gustos',
                          title: 'Que quieres ver primero?',
                          subtitle:
                              'Elige varias categorias. La biblioteca se ordenara pensando en este perfil.',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final category in _categoryOptions)
                                FilterChip(
                                  selected: _selectedCategories.contains(
                                    category,
                                  ),
                                  label: Text(category),
                                  avatar: Icon(_iconFor(category), size: 18),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedCategories.add(category);
                                      } else if (_selectedCategories.length >
                                          1) {
                                        _selectedCategories.remove(category);
                                      }
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _next,
                        icon: Icon(
                          _step == 2
                              ? Icons.check_circle_rounded
                              : Icons.arrow_forward_rounded,
                        ),
                        label: Text(_step == 2 ? 'Crear perfil' : 'Continuar'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String category) {
    switch (category) {
      case 'Romance':
        return Icons.favorite_rounded;
      case 'Drama':
        return Icons.theater_comedy_rounded;
      case 'Suspenso':
        return Icons.nights_stay_rounded;
      case 'Aventura':
        return Icons.explore_rounded;
      case 'Ninos':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }
}

class _StepCard extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget child;

  const _StepCard({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 460),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 32,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: TextStyle(
                  color: AppTheme.moss.withValues(alpha: 0.84),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.ink,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1.04,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppTheme.ink.withValues(alpha: 0.66),
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 22),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _AgeTile extends StatelessWidget {
  final _AgeOption option;
  final bool selected;
  final VoidCallback onTap;

  const _AgeTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? option.color.withValues(alpha: 0.18) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? option.color
                : Colors.black.withValues(alpha: 0.08),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: option.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(option.icon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    option.range,
                    style: TextStyle(
                      color: AppTheme.ink.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: selected
                  ? Icon(
                      Icons.check_circle_rounded,
                      key: const ValueKey('selected'),
                      color: option.color,
                    )
                  : const SizedBox(
                      key: ValueKey('empty'),
                      width: 24,
                      height: 24,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CelebrationBackdrop extends StatelessWidget {
  const _CelebrationBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 88,
            right: 28,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppTheme.coral.withValues(alpha: 0.32),
              size: 54,
            ),
          ),
          Positioned(
            bottom: 120,
            left: 24,
            child: Icon(
              Icons.star_rounded,
              color: AppTheme.sky.withValues(alpha: 0.34),
              size: 62,
            ),
          ),
          Positioned(
            bottom: 44,
            right: 46,
            child: Icon(
              Icons.menu_book_rounded,
              color: AppTheme.moss.withValues(alpha: 0.22),
              size: 78,
            ),
          ),
        ],
      ),
    );
  }
}

class _AgeOption {
  final String label;
  final String range;
  final String mood;
  final IconData icon;
  final Color color;

  const _AgeOption({
    required this.label,
    required this.range,
    required this.mood,
    required this.icon,
    required this.color,
  });
}
