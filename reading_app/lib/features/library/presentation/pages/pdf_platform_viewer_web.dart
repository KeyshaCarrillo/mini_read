// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

final Set<String> _registeredViewTypes = <String>{};

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
  final viewType = 'mini-read-pdf-${url.hashCode}';

  if (_registeredViewTypes.add(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      return html.IFrameElement()
        ..src = url
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true;
    });
  }

  return HtmlElementView(viewType: viewType);
}
