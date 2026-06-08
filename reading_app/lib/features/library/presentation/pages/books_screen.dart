import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../data/services/user_book_service.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';

class BooksScreen extends StatefulWidget {
  final BookRepository repository;
  final UserBookService userBookService;
  final String initialCategory;

  const BooksScreen({
    super.key,
    required this.repository,
    required this.userBookService,
    this.initialCategory = 'Todos',
  });

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  late Future<List<Book>> _booksFuture;
  final TextEditingController _searchController = TextEditingController();
  String _category = 'Todos';
  String _query = '';
  Set<String> _favorites = <String>{};

  @override
  void initState() {
    super.initState();
    _category = _normalizedCategory(widget.initialCategory);
    _booksFuture = _category == 'Todos'
        ? widget.repository.getBooks()
        : widget.repository.getBooksByAudience(_category);
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final favorites = await widget.userBookService.getFavoriteIds();
    if (mounted) setState(() => _favorites = favorites);
  }

  List<Book> _filtered(List<Book> books) {
    final query = _query.trim().toLowerCase();
    return books
        .where((book) {
          final categoryOk =
              _category == 'Todos' ||
              book.audience.toLowerCase() == _category.toLowerCase();
          final queryOk =
              query.isEmpty ||
              book.title.toLowerCase().contains(query) ||
              book.author.toLowerCase().contains(query) ||
              book.category.toLowerCase().contains(query);
          return categoryOk && queryOk;
        })
        .toList(growable: false);
  }

  String _normalizedCategory(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'adultos' || normalized == 'adult') return 'adult';
    if (normalized == 'infantil' || normalized == 'kids') return 'kids';
    return 'Todos';
  }

  Future<void> _changeCategory(String value) async {
    final next = _normalizedCategory(value);
    setState(() {
      _category = next;
      _booksFuture = next == 'Todos'
          ? widget.repository.getBooks()
          : widget.repository.getBooksByAudience(next);
    });
  }

  Future<void> _toggleFavorite(Book book) async {
    final favorite = _favorites.contains(book.id);
    setState(() {
      favorite ? _favorites.remove(book.id) : _favorites.add(book.id);
    });
    try {
      if (favorite) {
        await widget.userBookService.removeFavorite(book.id);
      } else {
        await widget.userBookService.addFavorite(book);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        favorite ? _favorites.add(book.id) : _favorites.remove(book.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar favoritos: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      appBar: AppBar(
        backgroundColor: AppTheme.obsidian,
        foregroundColor: Colors.white,
        title: const Text('Biblioteca'),
      ),
      body: FutureBuilder<List<Book>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const _BooksSkeletonGrid();
          }
          if (snapshot.hasError) {
            return _CatalogError(message: snapshot.error.toString());
          }

          final books = _filtered(snapshot.data ?? const []);
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Explora libros',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _CatalogSearchField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _query = value),
                      ),
                      const SizedBox(height: 14),
                      _CategoryFilters(
                        selected: _category,
                        onSelected: _changeCategory,
                      ),
                    ],
                  ),
                ),
              ),
              if (books.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: _EmptyCatalogMessage()),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 110),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.crossAxisExtent;
                      final columns = width >= 900
                          ? 5
                          : width >= 640
                          ? 4
                          : 2;
                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 18,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.58,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final book = books[index];
                          return _CatalogBookCard(
                            book: book,
                            favorite: _favorites.contains(book.id),
                            onFavorite: () => _toggleFavorite(book),
                            onTap: () {
                              if (book.pdfUrl.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    content: Text(
                                      'Este libro aún no tiene PDF disponible.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              Navigator.pushNamed(
                                context,
                                '/book',
                                arguments: book,
                              );
                            },
                          );
                        }, childCount: books.length),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CatalogBookCard extends StatelessWidget {
  final Book book;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  const _CatalogBookCard({
    required this.book,
    required this.favorite,
    required this.onFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: book.coverUrl.isEmpty
                        ? _CoverFallback(book: book)
                        : Image.network(
                            book.coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                _CoverFallback(book: book),
                          ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: IconButton.filled(
                    onPressed: onFavorite,
                    style: IconButton.styleFrom(
                      backgroundColor: favorite
                          ? AppTheme.gold
                          : Colors.black.withValues(alpha: 0.56),
                      foregroundColor: favorite
                          ? AppTheme.obsidian
                          : Colors.white,
                    ),
                    icon: Icon(
                      favorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${book.author} · ${book.category}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.58),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppTheme.gold, size: 16),
              const SizedBox(width: 3),
              Text(
                book.rating == 0 ? 'Nuevo' : book.rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppTheme.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CatalogSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _CatalogSearchField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.gold),
        hintText: 'Buscar por título, autor o categoría',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.48)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.gold.withValues(alpha: 0.14)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.gold.withValues(alpha: 0.14)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.gold),
        ),
      ),
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _CategoryFilters({required this.selected, required this.onSelected});

  static const categories = ['Todos', 'adult', 'kids'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final active = category == selected;
          return ChoiceChip(
            selected: active,
            label: Text(switch (category) {
              'adult' => 'ADULTOS',
              'kids' => 'INFANTIL',
              _ => 'Todos',
            }),
            onSelected: (_) => onSelected(category),
            selectedColor: AppTheme.gold,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            labelStyle: TextStyle(
              color: active ? AppTheme.obsidian : Colors.white,
              fontWeight: FontWeight.w900,
            ),
            side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.18)),
          );
        },
      ),
    );
  }
}

class _CoverFallback extends StatelessWidget {
  final Book book;

  const _CoverFallback({required this.book});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF34230D), Color(0xFF090806)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
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
              height: 1.05,
            ),
          ),
        ),
      ),
    );
  }
}

class _BooksSkeletonGrid extends StatelessWidget {
  const _BooksSkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(18),
      itemCount: 8,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 18,
        crossAxisSpacing: 14,
        childAspectRatio: 0.58,
      ),
      itemBuilder: (_, _) => Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}

class _CatalogError extends StatelessWidget {
  final String message;

  const _CatalogError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}

class _EmptyCatalogMessage extends StatelessWidget {
  const _EmptyCatalogMessage();

  @override
  Widget build(BuildContext context) {
    return Text(
      'No encontramos libros con esos filtros.',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.68),
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
