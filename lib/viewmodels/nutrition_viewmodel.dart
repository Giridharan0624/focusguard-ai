import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../data/firestore_service.dart';
import '../data/nutrition_repository.dart';
import '../models/food_item.dart';
import '../models/nutrition_log.dart';
import '../models/nutrition_summary.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/food_recommendation_service.dart';
import '../services/gemini_service.dart';
import '../services/nutrition_service.dart';

class NutritionViewModel extends ChangeNotifier {
  List<FoodItem> foodItems = [];
  List<NutritionLog> todayLogs = [];
  NutritionSummary? summary;
  List<FoodItem> recommendations = [];
  bool isLoading = false;
  String? errorMessage;

  // ── AI Food Advice ──
  String? aiFoodAdvice;
  bool isAiFoodLoading = false;
  UserProfile? userProfile;

  final AuthService _authService;
  final NutritionService _nutritionService;
  final FoodRecommendationService _foodRecommendationService;
  final NutritionRepository _repository;
  final GeminiService? _geminiService;
  final FirestoreService _firestoreService;

  NutritionViewModel({
    required AuthService authService,
    required NutritionService nutritionService,
    required FoodRecommendationService foodRecommendationService,
    required NutritionRepository repository,
    required FirestoreService firestoreService,
    GeminiService? geminiService,
  })  : _authService = authService,
        _nutritionService = nutritionService,
        _foodRecommendationService = foodRecommendationService,
        _repository = repository,
        _firestoreService = firestoreService,
        _geminiService = geminiService;

  /// Load food items and today's logs.
  Future<void> loadToday() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Re-seed food items if outdated (user is now authenticated)
      await _firestoreService.seedFoodItemsIfNeeded();

      final uid = _authService.uid;
      foodItems = await _repository.getAllFoodItems();
      todayLogs = await _repository.getTodayLogs(uid);
      _recalculate();
    } catch (e) {
      errorMessage = 'Failed to load nutrition data.';
    }

    isLoading = false;
    notifyListeners();
  }

  /// Add a food entry for today.
  Future<void> addFood(String foodItemId, double quantity) async {
    try {
      final uid = _authService.uid;
      final log = NutritionLog(
        date: DateTime.now(),
        foodItemId: foodItemId,
        quantity: quantity,
      );
      await _repository.saveLog(uid, log);
      todayLogs = await _repository.getTodayLogs(uid);
      _recalculate();
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to save food entry.';
      notifyListeners();
    }
  }

  /// Parse a spoken phrase via Groq and add matched foods to today's log.
  /// Returns (added, skipped, errorReason). errorReason is non-null only on hard failure.
  Future<({int added, int skipped, String? errorReason})> addFoodsByVoice(
      String text) async {
    final gemini = _geminiService;
    if (gemini == null || !gemini.isAvailable) {
      return (added: 0, skipped: 0, errorReason: 'ai_unavailable');
    }
    if (foodItems.isEmpty) {
      return (added: 0, skipped: 0, errorReason: 'no_foods_loaded');
    }

    final parsed = await gemini.parseFoodFromVoice(
      text,
      knownFoodNames: foodItems.map((f) => f.name).toList(),
    );
    if (parsed == null) {
      return (added: 0, skipped: 0, errorReason: 'parse_failed');
    }

    int added = 0;
    int skipped = 0;
    for (final item in parsed) {
      final rawName = (item['name'] as String? ?? '').trim().toLowerCase();
      if (rawName.isEmpty) {
        skipped++;
        continue;
      }
      final qty = (item['quantity'] as num?)?.toDouble() ?? 1.0;

      FoodItem? match;
      for (final f in foodItems) {
        if (f.name.toLowerCase() == rawName) { match = f; break; }
      }
      match ??= foodItems.cast<FoodItem?>().firstWhere(
        (f) =>
            f!.name.toLowerCase().contains(rawName) ||
            rawName.contains(f.name.toLowerCase()),
        orElse: () => null,
      );
      if (match == null) {
        skipped++;
        continue;
      }

      // qty from Groq is a count of servings. For 'nos' that's the count of
      // pieces; for 'grams'/'ml' it must be multiplied by servingSize so the
      // stored quantity is the actual amount (grams/ml), which is what the
      // nutrition multiplier (qty / servingSize) expects.
      final storeQty =
          match.unit == 'nos' ? qty : qty * match.servingSize;
      await addFood(match.id.toString(), storeQty);
      added++;
    }
    return (added: added, skipped: skipped, errorReason: null);
  }

  /// Remove a logged food entry.
  Future<void> removeLog(String logId) async {
    try {
      final uid = _authService.uid;
      await _repository.deleteLog(uid, logId);
      todayLogs = await _repository.getTodayLogs(uid);
      _recalculate();
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to remove entry.';
      notifyListeners();
    }
  }

  // ── Water tracking ──
  int _waterGlasses = 0;
  int get waterGlasses => _waterGlasses;

  void addWater() {
    _waterGlasses++;
    notifyListeners();
  }

  void removeWater() {
    if (_waterGlasses > 0) _waterGlasses--;
    notifyListeners();
  }

  /// Get the burnout penalty from current nutrition state.
  double get burnoutPenalty => summary?.burnoutPenalty ?? 0;

  /// Nutrition grade A-F based on how close to goals.
  String get grade {
    if (summary == null) return '-';
    final avg = (summary!.progressPercent('protein') +
            summary!.progressPercent('calories') +
            summary!.progressPercent('carbs') +
            summary!.progressPercent('fat')) /
        4;
    if (avg >= 85) return 'A';
    if (avg >= 70) return 'B';
    if (avg >= 50) return 'C';
    if (avg >= 30) return 'D';
    return 'F';
  }

  Color get gradeColor {
    switch (grade) {
      case 'A': return const Color(0xFF4CAF50);
      case 'B': return const Color(0xFF8BC34A);
      case 'C': return const Color(0xFFFFC107);
      case 'D': return const Color(0xFFFF9800);
      case 'F': return const Color(0xFFF44336);
      default: return const Color(0xFF757575);
    }
  }

  /// Time-based meal suggestion category.
  String get mealTimeSuggestion {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Breakfast';
    if (hour < 15) return 'Lunch';
    if (hour < 18) return 'Snack';
    return 'Dinner';
  }

  /// Get recommended foods filtered by time of day.
  List<FoodItem> get timeBasedRecommendations {
    if (foodItems.isEmpty) return [];
    final hour = DateTime.now().hour;
    String category;
    if (hour < 11) {
      category = 'energy'; // breakfast: oats, banana, poha
    } else if (hour < 15) {
      category = 'balanced'; // lunch: rice, curry, dal
    } else if (hour < 18) {
      category = 'light'; // snack: fruits, salad
    } else {
      category = 'protein-rich'; // dinner: chicken, fish, paneer
    }
    return foodItems.where((f) => f.category == category).toList();
  }

  void _recalculate() {
    summary = _nutritionService.summarize(todayLogs, foodItems);
    if (foodItems.isNotEmpty && summary != null) {
      recommendations =
          _foodRecommendationService.recommend(summary!, foodItems);
    }
    // Fetch AI food advice async (non-blocking)
    _fetchAiFoodAdvice();
  }

  Future<void> _fetchAiFoodAdvice() async {
    if (_geminiService == null || !_geminiService.isAvailable) return;
    if (summary == null) return;

    isAiFoodLoading = true;
    notifyListeners();

    try {
      aiFoodAdvice = await _geminiService.generateFoodAdvice(
        summary: summary!,
        mealTime: mealTimeSuggestion,
        profile: userProfile,
      );
    } catch (_) {
      aiFoodAdvice = null; // fallback to rule-based
    }

    isAiFoodLoading = false;
    notifyListeners();
  }
}
