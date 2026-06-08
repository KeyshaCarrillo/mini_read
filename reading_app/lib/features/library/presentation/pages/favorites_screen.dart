import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../data/services/user_book_service.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';

class FavoritesScreen extends StatefulWidget {
  final BookRepository repository;
  final UserBookService userBookService;

  const FavoritesScreen({
    super.key,
    required this.repository,
    required this.userBookService,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Book>> _favoritesFuture;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Book>> _loadFavorites() async {
    final ids = await widget.userBookService.getFavoriteBookIds();
    final books = await widget.repository.getBooks();
    final byId = {for (final book in books) book.id: book};
    return ids.map((id) => byId[id]).whereType<Book>().toList(growable: false);
  }

  List<Book> _filtered(List<Book> books) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return books;
    return books
        .where(
          (book) =>
              book.title.toLowerCase().contains(query) ||
              book.author.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  Future<void> _remove(Book book) async {
    await widget.userBookService.removeFavorite(book.id);
    if (!mounted) return;
    setState(() => _favoritesFuture = _loadFavorites());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      appBar: AppBar(
        backgroundColor: AppTheme.obsidian,
        foregroundColor: Colors.white,
        title: const Text('Mis favoritos'),
      ),
      body: FutureBuilder<List<Book>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = _filtered(snapshot.data ?? const []);
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppTheme.gold,
                      ),
                      hintText: 'Buscar favorito',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.50),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.07),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              if (books.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: _EmptyFavoritesState()),
                )
              else
                SliverList.separated(
                  itemCount: books.length,
                  separatorBuilder: (_, _) => Divider(
                    color: Colors.white.withValues(alpha: 0.08),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 48,
                          height: 68,
                          child: book.coverUrl.isEmpty
                              ? Container(
                                  color: AppTheme.gold.withValues(alpha: 0.16),
                                )
                              : Image.network(book.coverUrl, fit: BoxFit.cover),
                        ),
                      ),
                      title: Text(
                        book.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      subtitle: Text(
                        book.author,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.58),
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () => _remove(book),
                        icon: const Icon(
                          Icons.favorite_rounded,
                          color: AppTheme.gold,
                        ),
                      ),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/book',
                        arguments: book,
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyFavoritesState extends StatelessWidget {
  const _EmptyFavoritesState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.favorite_border_rounded,
            color: AppTheme.gold,
            size: 54,
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
          const SizedBox(height: 8),
          Text(
            'Marca libros con el corazón para encontrarlos aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.62)),
          ),
        ],
      ),
    );
  }
}
