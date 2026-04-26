import 'dart:ui';

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color _background = Color(0xFF0B1326);
  static const Color _surface = Color(0xFF171F33);
  static const Color _primary = Color(0xFFD2BBFF);
  static const Color _primaryContainer = Color(0xFF7C3AED);
  static const Color _tertiary = Color(0xFFFFAFD3);
  static const Color _onSurfaceVariant = Color(0xFFCCC3D8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        children: [
          const _BackgroundGlow(),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: _primary, width: 1.8),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x337C3AED),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Lumina',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontFamily: 'Newsreader',
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.search_rounded, color: _primary),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WELCOME BACK,',
                                style: TextStyle(
                                  color: _primary,
                                  fontSize: 11,
                                  letterSpacing: 1.3,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Julio Cortázar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontFamily: 'Newsreader',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _GlassPill(
                          child: Row(
                            children: const [
                              Icon(Icons.auto_awesome_rounded,
                                  color: _tertiary, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Adult Mode Active',
                                style: TextStyle(
                                  color: _onSurfaceVariant,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _HeroCard(),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.9,
                    ),
                    delegate: SliverChildListDelegate(
                      const [
                        _CategoryCard(
                          title: 'Novelas',
                          subtitle: '142 Stories',
                          image:
                              'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=1200',
                          overlay: Color(0x7A62259B),
                        ),
                        _CategoryCard(
                          title: 'Cuentos',
                          subtitle: '85 Stories',
                          image:
                              'https://images.unsplash.com/photo-1455885666463-9befe0f7e9f8?w=1200',
                          overlay: Color(0x9A2D145A),
                        ),
                        _CategoryCard(
                          title: 'Poemas',
                          subtitle: '210 Verses',
                          image:
                              'https://images.unsplash.com/photo-1513001900722-370f803f498d?w=1200',
                          overlay: Color(0x66AE397B),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 22),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0x4D2E1065),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Colors.white12),
          boxShadow: const [
            BoxShadow(color: Color(0x667C3AED), blurRadius: 24),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _NavItem(icon: Icons.home_rounded, label: 'Home', active: true),
            _NavItem(icon: Icons.menu_book_rounded, label: 'Library'),
            _NavItem(icon: Icons.auto_stories_rounded, label: 'Discover'),
            _NavItem(icon: Icons.person_rounded, label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0B1326), Color(0xFF141C33), Color(0xFF0B1326)],
            ),
          ),
        ),
        Positioned(
          top: -120,
          left: -80,
          child: Container(
            width: 290,
            height: 290,
            decoration: BoxDecoration(
              color: const Color(0x557C3AED),
              borderRadius: BorderRadius.circular(180),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        height: 460,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?w=1400',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC0B1326), Color(0xFF0B1326)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0x337C3AED),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: const Color(0x66D2BBFF)),
                    ),
                    child: const Text(
                      'STAFF PICK',
                      style: TextStyle(
                        color: Color(0xFFD2BBFF),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'The Whispering Library\nof Alexandria',
                    style: TextStyle(
                      color: Colors.white,
                      height: 1.05,
                      fontSize: 42,
                      fontFamily: 'Newsreader',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Discover the secrets buried beneath the sands of time. '
                    'An immersive journey through lost corridors of wisdom.',
                    style: TextStyle(
                      color: Color(0xFFCCC3D8),
                      fontFamily: 'Inter',
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFFE11DFF)],
                          ),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: const [
                            BoxShadow(color: Color(0x667C3AED), blurRadius: 18),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Read Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.menu_book_rounded, color: Colors.white),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _GlassPill(
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.bookmark_rounded, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final Color overlay;

  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(image, fit: BoxFit.cover),
          Container(color: overlay),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xCC0B1326)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontFamily: 'Newsreader',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFCCC3D8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
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

class _GlassPill extends StatelessWidget {
  final Widget child;

  const _GlassPill({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0x66222A3D),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white12),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({required this.icon, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    if (active) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient:
              const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFE11DFF)]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(color: Color(0x997C3AED), blurRadius: 14),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 19),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: .8,
              ),
            ),
          ],
        ),
      );
    }

    return Opacity(
      opacity: .7,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFA9AFC6), size: 22),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFFB2B8CC),
              fontWeight: FontWeight.w700,
              letterSpacing: .8,
            ),
          ),
        ],
      ),
    );
  }
}
