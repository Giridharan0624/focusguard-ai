import 'package:flutter/foundation.dart';
import '../data/checkin_repository.dart';
import '../models/chat_message.dart';
import '../models/user_input.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/gemini_service.dart';
import '../utils/constants.dart';

class ChatViewModel extends ChangeNotifier {
  final GeminiService _geminiService;
  final AuthService _authService;
  final CheckInRepository _repository;

  List<ChatMessage> messages = [];
  bool isTyping = false;
  String? errorMessage;
  ChatSession? _session;
  bool _initialized = false;

  UserProfile? userProfile;

  ChatViewModel({
    required GeminiService geminiService,
    required AuthService authService,
    required CheckInRepository repository,
  })  : _geminiService = geminiService,
        _authService = authService,
        _repository = repository;

  Future<void> initialize({
    double? currentScore,
    String? riskLevel,
    UserInput? todayInput,
  }) async {
    if (_initialized) return;

    try {
      final uid = _authService.uid;
      final history = await _repository.getRecentScores(uid, kHistoryLookback);

      _session = _geminiService.startChat(
        burnoutScore: currentScore ?? 0,
        riskLevel: riskLevel ?? 'unknown',
        todayInput: todayInput,
        recentScores: history,
        profile: userProfile,
      );
      _initialized = true;
    } catch (_) {
      errorMessage = 'Could not start chat session.';
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _session == null) return;

    messages.add(ChatMessage(text: text, isUser: true));
    isTyping = true;
    errorMessage = null;
    notifyListeners();

    try {
      final reply = await _session!.sendMessage(text);
      messages.add(ChatMessage(text: reply, isUser: false));
    } catch (_) {
      messages.add(ChatMessage(
        text: 'Sorry, I couldn\'t connect. Please try again.',
        isUser: false,
      ));
    }

    isTyping = false;
    notifyListeners();
  }
}
