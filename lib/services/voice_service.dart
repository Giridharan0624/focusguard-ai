import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class VoiceService extends ChangeNotifier {
  final SpeechToText _speech = SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;
  String _lastResult = '';
  String _partialResult = '';

  bool get isAvailable => _isAvailable;
  bool get isListening => _isListening;
  String get lastResult => _lastResult;
  String get partialResult => _partialResult;

  /// Initialize speech recognition. Call once at app startup.
  Future<void> initialize() async {
    _isAvailable = await _speech.initialize(
      onError: (error) {
        debugPrint('Speech error: ${error.errorMsg}');
        _isListening = false;
        notifyListeners();
      },
      onStatus: (status) {
        if (status == 'notListening' || status == 'done') {
          _isListening = false;
          notifyListeners();
        }
      },
    );
    notifyListeners();
  }

  /// Start listening. Returns the final result via [onResult] callback.
  Future<void> startListening({
    required void Function(String finalText) onResult,
    String localeId = 'en_IN',
  }) async {
    if (!_isAvailable || _isListening) return;

    _lastResult = '';
    _partialResult = '';
    _isListening = true;
    notifyListeners();

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        if (result.finalResult) {
          _lastResult = result.recognizedWords;
          _partialResult = '';
          _isListening = false;
          notifyListeners();
          onResult(_lastResult);
        } else {
          _partialResult = result.recognizedWords;
          notifyListeners();
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: localeId,
      listenOptions: SpeechListenOptions(
        cancelOnError: true,
        listenMode: ListenMode.dictation,
      ),
    );
  }

  /// Stop listening manually.
  Future<void> stopListening() async {
    if (!_isListening) return;
    await _speech.stop();
    _isListening = false;
    notifyListeners();
  }

  /// Cancel listening without returning result.
  Future<void> cancel() async {
    await _speech.cancel();
    _isListening = false;
    _partialResult = '';
    notifyListeners();
  }
}
