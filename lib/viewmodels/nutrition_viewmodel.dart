import 'package:flutter/foundation.dart';
import '../data/nutrition_repository.dart';
import '../models/food_item.dart';
import '../models/nutrition_log.dart';
import '../models/nutrition_summary.dart';
import '../services/auth_service.dart';
import '../services/food_recommendation_service.dart';
import '../services/nutrition_service.dart';

class NutritionViewModel extends ChangeNotifier {
  List<FoodItem> foodItems = [];
  List<NutritionLog> todayLogs = [];
  NutritionSummary? summary;
  List<FoodItem> recommendations = [];
  bool isLoading = false;
  String? errorMessage;

  final AuthService _authService;
  final NutritionService _nutritionService;
  final FoodRecommendationService _foodRecommendationService;
  final NutritionRepository _repository;

  NutritionViewModel({
    required AuthService authService,
    required NutritionService nutritionService,
    required FoodRecommendationService foodRecommendationService,
    required NutritionRepository repository,
  })  : _authService = authService,
        _nutritionService = nutritionService,
        _foodRecommendationService = foodRecommendationService,
        _repository = repository;

  /// Load food items and today's logs.
  Future<void> loadToday() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
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

  /// Get the burnout penalty from current nutrition state.
  double get burnoutPenalty => summary?.burnoutPenalty ?? 0;

  void _recalculate() {
    summary = _nutritionService.summarize(todayLogs, foodItems);
    if (foodItems.isNotEmpty && summary != null) {
      recommendations =
          _foodRecommendationService.recommend(summary!, foodItems);
    }
  }
}
