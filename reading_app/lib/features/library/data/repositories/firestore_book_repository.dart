import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../models/book_model.dart';

class FirestoreBookRepository implements BookRepository {
  final FirebaseFirestore firestore;

  const FirestoreBookRepository({required this.firestore});

  @override
  Future<List<Book>> getBooks() async {
    final snapshot = await firestore.collection('books').get();
    final books = _mapBooks(snapshot);
    final activeBooks = books
        .where((book) => book.active)
        .toList(growable: false);
    _logBooks(activeBooks);
    return activeBooks;
  }

  @override
  Future<List<Book>> getFeaturedBooks() async {
    final books = await getBooks();
    return books.where((book) => book.featured).toList(growable: false);
  }

  @override
  Future<List<Book>> getBooksByAudience(String audience) async {
    final audienceValue = _audienceQueryValue(audience);
    final snapshot = await firestore
        .collection('books')
        .where('audience', isEqualTo: audienceValue)
        .get();
    final books = _mapBooks(
      snapshot,
    ).where((book) => book.active).toList(growable: false);

    _logBooks(books);

    return books;
  }

  @override
  Future<List<Book>> getBooksByCategory(String category) async {
    final fallbackSnapshot = await firestore.collection('books').get();
    final normalizedCategory = _normalize(category);
    return fallbackSnapshot.docs
        .map((doc) => BookModel.fromJson({'id': doc.id, ...doc.data()}))
        .where((book) => book.active)
        .where((book) => _normalize(book.category) == normalizedCategory)
        .toList(growable: false);
  }

  @override
  Future<List<Book>> getInfantilBooks() {
    return getBooksByCategory('Infantil');
  }

  @override
  Future<List<Book>> searchBooks(String query) async {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) return getBooks();

    final books = await getBooks();
    return books
        .where((book) {
          final haystack = _normalize(
            [
              book.title,
              book.author,
              book.category,
              book.description,
              book.summary,
              ...book.keywords,
            ].join(' '),
          );
          return haystack.contains(normalizedQuery);
        })
        .toList(growable: false);
  }

  @override
  Future<void> ensureInfantilBooks() async {}

  List<Book> _mapBooks(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs
        .map((doc) {
          final rawPdfUrl = (doc.data()['pdfUrl'] ?? '').toString();
          print('FIRESTORE RAW PDF URL [${doc.id}]: $rawPdfUrl');
          return BookModel.fromJson({'id': doc.id, ...doc.data()});
        })
        .toList(growable: false);
  }

  void _logBooks(List<Book> books) {
    for (final book in books) {
      debugPrint('Book ID: ${book.id}');
      debugPrint('Title: ${book.title}');
      debugPrint('PDF URL: ${book.pdfUrl}');
      debugPrint('Audience: ${book.audience}');
      print('PDF URL: ${book.pdfUrl}');
    }
  }

  String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll('Ã¡', 'a')
        .replaceAll('Ã©', 'e')
        .replaceAll('Ã­', 'i')
        .replaceAll('Ã³', 'o')
        .replaceAll('Ãº', 'u')
        .replaceAll('Ã±', 'n')
        .replaceAll('ÃƒÂ¡', 'a')
        .replaceAll('ÃƒÂ©', 'e')
        .replaceAll('ÃƒÂ­', 'i')
        .replaceAll('ÃƒÂ³', 'o')
        .replaceAll('ÃƒÂº', 'u')
        .replaceAll('ÃƒÂ±', 'n');
  }

  String _audienceQueryValue(String value) {
    final normalized = _normalize(value);
    if (const {
      'kids',
      'child',
      'children',
      'infantil',
      'ninos',
    }.contains(normalized)) {
      return 'kids';
    }
    if (const {'adult', 'adults', 'adulto', 'adultos'}.contains(normalized)) {
      return 'adult';
    }
    return value.trim();
  }
}
