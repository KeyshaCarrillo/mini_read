import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../app/app_theme.dart';
import '../../data/services/user_book_service.dart';
import '../../domain/entities/book.dart';
import 'pdf_platform_viewer.dart';

class PdfReaderPage extends StatefulWidget {
  final Book book;
  final UserBookService? userBookService;

  const PdfReaderPage({super.key, required this.book, this.userBookService});

  @override
  State<PdfReaderPage> createState() => _PdfReaderPageState();
}

class _PdfReaderPageState extends State<PdfReaderPage> {
  late final String _pdfUrl;
  late final Future<_PdfValidationResult> _validation;
  String? _viewerError;
  int _initialPage = 1;

  @override
  void initState() {
    super.initState();
    _pdfUrl = widget.book.pdfUrl.trim();
    debugPrint('PDF URL: $_pdfUrl');
    print('PDF URL: $_pdfUrl');
    print('PDF URL USED BY VIEWER: $_pdfUrl');
    _validation = _validatePdfUrl(_pdfUrl);
    _restoreProgress();
  }

  Future<void> _restoreProgress() async {
    final progress = await widget.userBookService?.getProgress(widget.book.id);
    if (!mounted || progress == null) return;
    setState(() => _initialPage = progress.currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      appBar: AppBar(
        backgroundColor: AppTheme.obsidian,
        foregroundColor: Colors.white,
        title: Text(
          widget.book.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: FutureBuilder<_PdfValidationResult>(
        future: _validation,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final validation = snapshot.data;
          if (validation == null || !validation.ok) {
            return _PdfErrorState(
              message:
                  validation?.message ?? 'No se pudo validar la URL del PDF.',
              url: _pdfUrl,
            );
          }

          if (_viewerError != null) {
            return _PdfErrorState(message: _viewerError!, url: _pdfUrl);
          }

          return buildPdfPlatformViewer(
            url: _pdfUrl,
            initialPage: _initialPage,
            onError: (message) {
              debugPrint(message);
              if (mounted) setState(() => _viewerError = message);
            },
            onReaderStateChanged: (state) {
              widget.userBookService?.saveProgress(
                bookId: widget.book.id,
                currentPage: state.currentPage,
                totalPages: state.totalPages,
              );
            },
          );
        },
      ),
    );
  }

  Future<_PdfValidationResult> _validatePdfUrl(String url) async {
    if (url.isEmpty) {
      return const _PdfValidationResult(
        ok: false,
        message: 'Este libro aún no tiene PDF disponible.',
      );
    }

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return _PdfValidationResult(
        ok: false,
        message: 'La URL del PDF no es valida: $url',
      );
    }

    if (uri.scheme != 'https') {
      return _PdfValidationResult(
        ok: false,
        message:
            'La URL del PDF debe usar HTTPS desde Firebase Storage. Valor recibido: $url',
      );
    }

    if (kIsWeb) {
      debugPrint('PDF HTTP validation on web (diagnostic mode).');
      try {
        final response = await http
            .get(uri)
            .timeout(const Duration(seconds: 15));
        print('HTTP STATUS: ${response.statusCode}');
        print('HTTP BODY: ${response.body}');
      } catch (error) {
        print('HTTP STATUS: -1');
        print('HTTP BODY: $error');
      }
      return const _PdfValidationResult(ok: true);
    }

    try {
      final response = await http
          .head(uri)
          .timeout(const Duration(seconds: 15));
      debugPrint(
        'PDF HEAD status: ${response.statusCode}, '
        'content-type: ${response.headers['content-type']}',
      );
      print('HTTP STATUS: ${response.statusCode}');

      try {
        final getResponse = await http
            .get(uri)
            .timeout(const Duration(seconds: 15));
        print('HTTP STATUS: ${getResponse.statusCode}');
        print('HTTP BODY: ${getResponse.body}');
      } catch (error) {
        print('HTTP STATUS: -1');
        print('HTTP BODY: $error');
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _PdfValidationResult(
          ok: false,
          message:
              'Firebase Storage respondio HTTP ${response.statusCode}. '
              'Verifica permisos del archivo o la URL guardada en Firestore.',
        );
      }

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.toLowerCase().contains('pdf')) {
        return _PdfValidationResult(
          ok: false,
          message:
              'La URL responde HTTP 200, pero no parece un PDF. '
              'Content-Type: $contentType',
        );
      }

      return const _PdfValidationResult(ok: true);
    } catch (error) {
      return _PdfValidationResult(
        ok: false,
        message: 'No se pudo conectar con la URL del PDF: $error',
      );
    }
  }
}

class _PdfValidationResult {
  final bool ok;
  final String message;

  const _PdfValidationResult({required this.ok, this.message = ''});
}

class _PdfErrorState extends StatelessWidget {
  final String message;
  final String url;

  const _PdfErrorState({required this.message, required this.url});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.picture_as_pdf_rounded,
              color: AppTheme.gold,
              size: 54,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 14),
            SelectableText(
              url,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.44),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
