import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/suggestion.dart';
import '../models/user_input.dart';
import '../models/user_profile.dart';
import '../models/nutrition_summary.dart';

/// AI service using Groq API (Llama 3.3 70B).
/// Class name kept as GeminiService to avoid renaming everywhere.
class GeminiService {
  final String _apiKey;
  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';
  final List<DateTime> _callTimestamps = [];

  GeminiService({required String apiKey}) : _apiKey = apiKey;

  bool get isAvailable => _apiKey.isNotEmpty;

  // ── Rate limiter (30 RPM for Groq free) ──
  bool get _isRateLimited {
    _callTimestamps
        .removeWhere((t) => DateTime.now().difference(t).inSeconds > 60);
    return _callTimestamps.length >= 28;
  }

  Future<String?> _generate(String systemPrompt, String userPrompt,
      {int maxTokens = 500}) async {
    if (_isRateLimited) return null;
    _callTimestamps.add(DateTime.now());

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'max_tokens': maxTokens,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String?;
      }
      debugPrint('Groq API error: ${response.statusCode} ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Groq error: $e');
      return null;
    }
  }

  // ── Feature 1: Post-Check-In Insight ──
  Future<String?> generateInsight({
    required UserInput input,
    required double burnoutScore,
    required Map<String, double> causes,
    required List<double> recentScores,
    UserProfile? profile,
    required bool exercised,
  }) async {
    const system =
        'You are a wellness analyst. Write concise, empathetic burnout insights. No bullet points. Under 80 words.';

    final user = '''User check-in data:
- Burnout score: ${burnoutScore.round()}/100
- Top cause: ${_topCause(causes)} (${causes[_topCause(causes)]?.round()}%)
- All causes: ${causes.entries.map((e) => '${e.key}: ${e.value.round()}%').join(', ')}
- Sleep: ${input.sleepHours}h, Work: ${input.workHours}h, Mood: ${input.mood}/10, Screen: ${input.screenTime}h, Caffeine: ${input.caffeine} cups
- Exercised: $exercised
- 7-day scores: ${recentScores.map((s) => s.round()).join(', ')}
${profile != null ? '- User: ${profile.name}, ${profile.occupation ?? 'professional'}' : ''}

Write a personalized 2-3 sentence insight. Be specific to their numbers. Mention trend if relevant. End with one concrete suggestion.''';

    return _generate(system, user, maxTokens: 150);
  }

  // ── Feature 2: AI Recovery Plan ──
  Future<List<Suggestion>?> generateRecoveryPlan({
    required UserInput input,
    required double burnoutScore,
    required Map<String, double> causes,
    UserProfile? profile,
    required bool exercised,
  }) async {
    const system =
        'You are a wellness advisor. Return ONLY a JSON array. No markdown, no explanation.';

    final user = '''Generate recovery plan for burnout score ${burnoutScore.round()}/100.
Causes: ${causes.entries.map((e) => '${e.key}: ${e.value.round()}%').join(', ')}
Sleep: ${input.sleepHours}h, Work: ${input.workHours}h, Mood: ${input.mood}/10, Screen: ${input.screenTime}h, Caffeine: ${input.caffeine}
Exercised: $exercised
${profile != null ? 'User: ${profile.name}, ${profile.occupation ?? 'professional'}' : ''}

Return ONLY a JSON array with 3-5 items:
[{"category":"sleep","text":"specific advice","expectedReduction":5,"priority":"high"}]
Categories: sleep, work, mood, screen_time, caffeine, exercise
Priorities: high, medium, low''';

    final response = await _generate(system, user, maxTokens: 400);
    if (response == null) return null;

    try {
      var cleaned = response.trim();
      // Strip markdown fences
      if (cleaned.startsWith('```')) {
        cleaned = cleaned.replaceFirst(RegExp(r'^```\w*\n?'), '');
        cleaned = cleaned.replaceFirst(RegExp(r'\n?```$'), '');
      }
      // Find the JSON array
      final start = cleaned.indexOf('[');
      final end = cleaned.lastIndexOf(']');
      if (start == -1 || end == -1) return null;
      cleaned = cleaned.substring(start, end + 1);

      final list = jsonDecode(cleaned) as List;
      return list.map((item) {
        final map = item as Map<String, dynamic>;
        return Suggestion(
          category: map['category'] as String? ?? 'mood',
          text: map['text'] as String? ?? '',
          expectedReduction:
              (map['expectedReduction'] as num?)?.toDouble() ?? 5,
          priority: map['priority'] as String? ?? 'medium',
        );
      }).toList();
    } catch (_) {
      return null;
    }
  }

  // ── Feature 3: Wellness Coach Chat ──
  // Returns a stateful chat function
  ChatSession startChat({
    required double burnoutScore,
    required String riskLevel,
    required UserInput? todayInput,
    required List<double> recentScores,
    UserProfile? profile,
  }) {
    final systemPrompt = StringBuffer()
      ..writeln('You are a wellness coach inside FocusGuard AI.')
      ..writeln('User data:')
      ..writeln('- Burnout score: ${burnoutScore.round()}/100 ($riskLevel)');

    if (todayInput != null) {
      systemPrompt
        ..writeln('- Sleep: ${todayInput.sleepHours}h, Work: ${todayInput.workHours}h, Mood: ${todayInput.mood}/10')
        ..writeln('- Screen: ${todayInput.screenTime}h, Caffeine: ${todayInput.caffeine} cups');
    }
    if (recentScores.isNotEmpty) {
      systemPrompt.writeln('- 7-day trend: ${recentScores.map((s) => s.round()).join(', ')}');
    }
    if (profile != null) {
      systemPrompt.writeln('- Name: ${profile.name}, Occupation: ${profile.occupation ?? "professional"}');
    }
    systemPrompt
      ..writeln('')
      ..writeln('Rules: Be empathetic, concise (under 150 words), actionable. Reference their data. Never diagnose medical conditions.');

    return ChatSession(
      apiKey: _apiKey,
      systemPrompt: systemPrompt.toString(),
    );
  }

  // ── Feature 4: Natural Language Check-In ──
  Future<Map<String, dynamic>?> extractCheckinFromText(String text) async {
    const system =
        'Extract check-in data from text. Return ONLY a JSON object. No explanation.';

    final user = '''Text: "$text"

Return ONLY:
{"sleepHours":<double or null>,"workHours":<double or null>,"mood":<int 1-10 or null>,"screenTime":<double or null>,"caffeine":<int or null>}

Infer: "barely slept"=3h, "long day"=10h work, "terrible"=2 mood, "good"=7 mood. Use null if not mentioned.''';

    final response = await _generate(system, user, maxTokens: 100);
    if (response == null) return null;

    try {
      var cleaned = response.trim();
      if (cleaned.startsWith('```')) {
        cleaned = cleaned.replaceFirst(RegExp(r'^```\w*\n?'), '');
        cleaned = cleaned.replaceFirst(RegExp(r'\n?```$'), '');
      }
      final start = cleaned.indexOf('{');
      final end = cleaned.lastIndexOf('}');
      if (start == -1 || end == -1) return null;
      cleaned = cleaned.substring(start, end + 1);
      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ── Feature 5: Smart Food Recommendations ──
  Future<String?> generateFoodAdvice({
    required NutritionSummary summary,
    required String mealTime,
    UserProfile? profile,
  }) async {
    const system = 'You are a nutrition advisor. Be concise and practical.';

    final user = '''Suggest 3-5 meals for $mealTime based on gaps:
- Protein: ${summary.totalProtein.round()}g / ${summary.proteinGoal.round()}g
- Calories: ${summary.totalCalories.round()} / ${summary.calorieGoal.round()} kcal
- Carbs: ${summary.totalCarbs.round()}g / ${summary.carbGoal.round()}g
- Fat: ${summary.totalFat.round()}g / ${summary.fatGoal.round()}g

Include Indian cuisine options. Keep under 100 words. Use bullet points.''';

    return _generate(system, user, maxTokens: 200);
  }

  // ── Feature 6: Voice Food Parsing ──
  Future<List<Map<String, dynamic>>?> parseFoodFromVoice(
    String text, {
    required List<String> knownFoodNames,
  }) async {
    const system =
        'Extract food items from spoken text. Return ONLY a JSON array. No explanation.';

    final names = knownFoodNames.join(', ');
    final user = '''Text: "$text"

Return ONLY a JSON array of food items mentioned:
[{"name":"food name","quantity":1.0}]

Examples:
"2 eggs and rice" → [{"name":"Boiled Egg","quantity":2},{"name":"White Rice","quantity":1}]
"had some dal and chapati" → [{"name":"Dal (Lentils)","quantity":1},{"name":"Chapati / Roti","quantity":1}]

The "name" MUST be copied verbatim from this list (exact casing and punctuation): $names
If a spoken item does not clearly map to one of those names, omit it. quantity is a count of servings (use 1 if unspecified).''';

    final response = await _generate(system, user, maxTokens: 200);
    if (response == null) return null;

    try {
      var cleaned = response.trim();
      if (cleaned.startsWith('```')) {
        cleaned = cleaned.replaceFirst(RegExp(r'^```\w*\n?'), '');
        cleaned = cleaned.replaceFirst(RegExp(r'\n?```$'), '');
      }
      final start = cleaned.indexOf('[');
      final end = cleaned.lastIndexOf(']');
      if (start == -1 || end == -1) return null;
      cleaned = cleaned.substring(start, end + 1);
      final list = jsonDecode(cleaned) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  String _topCause(Map<String, double> causes) =>
      causes.entries.reduce((a, b) => a.value > b.value ? a : b).key;
}

/// Simple chat session using Groq API with message history.
class ChatSession {
  final String _apiKey;
  final String _systemPrompt;
  final List<Map<String, String>> _history = [];

  ChatSession({required String apiKey, required String systemPrompt})
      : _apiKey = apiKey,
        _systemPrompt = systemPrompt;

  Future<String> sendMessage(String text) async {
    _history.add({'role': 'user', 'content': text});

    final messages = [
      {'role': 'system', 'content': _systemPrompt},
      ..._history,
    ];

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': messages,
          'max_tokens': 300,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;
        _history.add({'role': 'assistant', 'content': reply});
        return reply;
      }
      return 'Sorry, I couldn\'t connect. Please try again.';
    } catch (_) {
      return 'Sorry, I couldn\'t connect. Please try again.';
    }
  }
}
