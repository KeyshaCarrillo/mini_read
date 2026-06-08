import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsPlaybackState { stopped, playing, paused }

enum TtsEngineProvider { device, elevenLabs, googleCloud }

class TtsService extends ChangeNotifier {
  final FlutterTts _flutterTts;
  final TtsEngineProvider provider;

  TtsPlaybackState _state = TtsPlaybackState.stopped;
  String _currentText = '';
  bool _configured = false;

  TtsService({FlutterTts? flutterTts, this.provider = TtsEngineProvider.device})
    : _flutterTts = flutterTts ?? FlutterTts() {
    _bindHandlers();
  }

  TtsPlaybackState get state => _state;
  bool get isPlaying => _state == TtsPlaybackState.playing;
  bool get isPaused => _state == TtsPlaybackState.paused;
  bool get isStopped => _state == TtsPlaybackState.stopped;
  bool get hasText => _currentText.trim().isNotEmpty;

  Future<void> configureSpanish() async {
    await _flutterTts.setLanguage('es-ES');
    await _flutterTts.setSpeechRate(0.46);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.awaitSpeakCompletion(false);
    _configured = true;
  }

  Future<void> play(String text) async {
    final normalized = _normalize(text);
    if (normalized.isEmpty) {
      throw const TtsException('No hay contenido textual para escuchar.');
    }

    if (!_configured) await configureSpanish();
    _currentText = normalized;
    _setState(TtsPlaybackState.playing);
    await _flutterTts.speak(normalized);
  }

  Future<void> resume() async {
    if (_currentText.trim().isEmpty) return;
    await play(_currentText);
  }

  Future<void> pause() async {
    await _flutterTts.pause();
    _setState(TtsPlaybackState.paused);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _setState(TtsPlaybackState.stopped);
  }

  void _bindHandlers() {
    _flutterTts.setStartHandler(() => _setState(TtsPlaybackState.playing));
    _flutterTts.setPauseHandler(() => _setState(TtsPlaybackState.paused));
    _flutterTts.setContinueHandler(() => _setState(TtsPlaybackState.playing));
    _flutterTts.setCompletionHandler(() => _setState(TtsPlaybackState.stopped));
    _flutterTts.setCancelHandler(() => _setState(TtsPlaybackState.stopped));
    _flutterTts.setErrorHandler((message) {
      debugPrint('TTS error: $message');
      _setState(TtsPlaybackState.stopped);
    });
  }

  void _setState(TtsPlaybackState nextState) {
    if (_state == nextState) return;
    _state = nextState;
    notifyListeners();
  }

  String _normalize(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}

class TtsException implements Exception {
  final String message;

  const TtsException(this.message);

  @override
  String toString() => message;
}
