import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const int _maxImageBytes = 5 * 1024 * 1024;
  static const Set<String> _supportedImageTypes = {
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/webp',
  };

  final String cloudName;
  final String uploadPreset;
  final http.Client _client;

  CloudinaryService({
    required this.cloudName,
    required this.uploadPreset,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<String> uploadImageBytes({
    required List<int> bytes,
    required String folder,
    required String publicId,
    String contentType = 'image/jpeg',
  }) async {
    _validateConfig();
    _validateImage(bytes: bytes, contentType: contentType);

    final trimmedCloudName = cloudName.trim();
    final trimmedPreset = uploadPreset.trim();
    final normalizedContentType = contentType.toLowerCase().trim();
    final uri = Uri.https(
      'api.cloudinary.com',
      '/v1_1/$trimmedCloudName/image/upload',
    );

    if (kDebugMode) {
      debugPrint('Cloudinary upload iniciado...');
    }

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = trimmedPreset
      ..fields['folder'] = folder
      ..fields['public_id'] = publicId
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: '$publicId.${_extensionFor(normalizedContentType)}',
        ),
      );

    final response = await _client.send(request);
    final body = await response.stream.bytesToString();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Cloudinary upload fallo.');
    }

    final payload = jsonDecode(body) as Map<String, dynamic>;
    final secureUrl = payload['secure_url']?.toString();
    if (secureUrl == null || secureUrl.trim().isEmpty) {
      throw Exception('Cloudinary no devolvio una URL valida.');
    }

    if (kDebugMode) {
      debugPrint('Upload exitoso.');
      debugPrint('URL recibida.');
    }

    return secureUrl;
  }

  void _validateConfig() {
    if (cloudName.trim().isEmpty || uploadPreset.trim().isEmpty) {
      throw Exception('Cloudinary no esta configurado.');
    }
  }

  void _validateImage({
    required List<int> bytes,
    required String contentType,
  }) {
    if (bytes.isEmpty) {
      throw Exception('Imagen vacia.');
    }
    if (bytes.length > _maxImageBytes) {
      throw Exception('Imagen supera el limite permitido.');
    }
    if (!_supportedImageTypes.contains(contentType.toLowerCase().trim())) {
      throw Exception('Tipo de archivo no soportado.');
    }
  }

  String _extensionFor(String contentType) {
    if (contentType.contains('png')) return 'png';
    if (contentType.contains('webp')) return 'webp';
    return 'jpg';
  }
}
