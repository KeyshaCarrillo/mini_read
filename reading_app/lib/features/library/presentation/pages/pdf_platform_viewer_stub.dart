import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../app/app_theme.dart';

class PdfReaderState {
  final int currentPage;
  final int totalPages;

  const PdfReaderState({required this.currentPage, required this.totalPages});
}

Widget buildPdfPlatformViewer({
  required String url,
  required ValueChanged<String> onError,
  ValueChanged<PdfReaderState>? onReaderStateChanged,
  int initialPage = 1,
}) {
  return _NativeBookPdfViewer(
    url: url,
    onError: onError,
    onReaderStateChanged: onReaderStateChanged,
    initialPage: initialPage,
  );
}

class _NativeBookPdfViewer extends StatefulWidget {
  final String url;
  final ValueChanged<String> onError;
  final ValueChanged<PdfReaderState>? onReaderStateChanged;
  final int initialPage;

  const _NativeBookPdfViewer({
    required this.url,
    required this.onError,
    required this.onReaderStateChanged,
    required this.initialPage,
  });

  @override
  State<_NativeBookPdfViewer> createState() => _NativeBookPdfViewerState();
}

class _NativeBookPdfViewerState extends State<_NativeBookPdfViewer>
    with SingleTickerProviderStateMixin {
  late final PdfViewerController _controller;
  late final AnimationController _turnController;
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _controller = PdfViewerController();
    _turnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
  }

  @override
  void dispose() {
    _turnController.dispose();
    super.dispose();
  }

  void _publishState() {
    widget.onReaderStateChanged?.call(
      PdfReaderState(currentPage: _currentPage, totalPages: _totalPages),
    );
  }

  Future<void> _turnTo({required bool next}) async {
    if (_totalPages == 0) return;
    if (next && _currentPage >= _totalPages) return;
    if (!next && _currentPage <= 1) return;

    await _turnController.forward(from: 0);
    if (next) {
      _controller.nextPage();
    } else {
      _controller.previousPage();
    }
    if (mounted) _turnController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(12, 10, 12, 74),
          decoration: BoxDecoration(
            color: const Color(0xFF100D08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.gold.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.36),
                blurRadius: 26,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.18),
                    ),
                  ),
                  Container(
                    width: 1,
                    color: AppTheme.gold.withValues(alpha: 0.18),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
              SfPdfViewer.network(
                widget.url,
                controller: _controller,
                pageLayoutMode: PdfPageLayoutMode.single,
                canShowScrollHead: false,
                canShowScrollStatus: false,
                onDocumentLoaded: (details) {
                  setState(() {
                    _totalPages = details.document.pages.count;
                    _currentPage = _controller.pageNumber == 0
                        ? 1
                        : _controller.pageNumber;
                  });
                  final targetPage = widget.initialPage.clamp(1, _totalPages);
                  if (targetPage > 1) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _controller.jumpToPage(targetPage);
                    });
                  }
                  _publishState();
                },
                onPageChanged: (details) {
                  setState(() => _currentPage = details.newPageNumber);
                  _publishState();
                },
                onDocumentLoadFailed: (details) {
                  widget.onError(
                    'Syncfusion no pudo abrir el PDF. '
                    'Error: ${details.error}. '
                    'Descripcion: ${details.description}.',
                  );
                },
              ),
              AnimatedBuilder(
                animation: _turnController,
                builder: (context, _) {
                  final value = Curves.easeOutCubic.transform(
                    _turnController.value,
                  );
                  return IgnorePointer(
                    child: Opacity(
                      opacity: value == 0 ? 0 : 1 - value,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Transform(
                          alignment: Alignment.centerLeft,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(-value * 1.15),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.46,
                            margin: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7E8),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.22),
                                  blurRadius: 18,
                                  offset: const Offset(-8, 8),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          bottom: 14,
          child: _ReaderControls(
            currentPage: _currentPage,
            totalPages: _totalPages,
            onPrevious: () => _turnTo(next: false),
            onNext: () => _turnTo(next: true),
          ),
        ),
      ],
    );
  }
}

class _ReaderControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _ReaderControls({
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          IconButton.filled(
            onPressed: currentPage > 1 ? onPrevious : null,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.10),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white24,
            ),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Text(
              totalPages == 0
                  ? 'Cargando paginas...'
                  : 'Pagina $currentPage de $totalPages',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton.filled(
            onPressed: totalPages > 0 && currentPage < totalPages
                ? onNext
                : null,
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.gold,
              foregroundColor: AppTheme.obsidian,
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.10),
              disabledForegroundColor: Colors.white24,
            ),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}
