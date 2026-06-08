import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/app_theme.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../providers/book_provider.dart';
import '../widgets/book_card.dart';

class InfantilScreen extends StatelessWidget {
  final BookRepository repository;

  const InfantilScreen({super.key, required this.repository});

  void _openPdf(BuildContext context, Book book) {
    if (book.pdfUrl.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Este libro aún no tiene PDF disponible.'),
        ),
      );
      return;
    }
    Navigator.pushNamed(context, '/pdf-reader', arguments: book);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          BookController(repository: repository)..loadByAudience('kids'),
      child: Scaffold(
        backgroundColor: AppTheme.obsidian,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          title: const Text('Infantil'),
        ),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF050505), Color(0xFF17130B), Color(0xFF080808)],
            ),
          ),
          child: Consumer<BookController>(
            builder: (context, provider, _) {
              if (provider.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.error != null) {
                return _MessageState(
                  icon: Icons.cloud_off_rounded,
                  title: 'No pudimos cargar Infantil',
                  message: 'Revisa la conexión o los permisos de Firestore.',
                  action: FilledButton.icon(
                    onPressed: () => provider.loadByAudience('kids'),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reintentar'),
                  ),
                );
              }

              final books = provider.books;
              if (books.isEmpty) {
                return _MessageState(
                  icon: Icons.auto_stories_rounded,
                  title: 'Sin libros en Infantil',
                  message:
                      'Cuando existan libros con audience = kids aparecerán aquí.',
                  action: OutlinedButton.icon(
                    onPressed: () => provider.loadByAudience('kids'),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Actualizar'),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => provider.loadByAudience('kids'),
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.55,
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return BookCard(
                      book: book,
                      onTap: () => _openPdf(context, book),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget action;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.gold, size: 56),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.68)),
            ),
            const SizedBox(height: 18),
            action,
          ],
        ),
      ),
    );
  }
}
