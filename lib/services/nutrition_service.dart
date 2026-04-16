import 'dart:math';
import '../models/food_item.dart';
import '../models/nutrition_log.dart';
import '../models/nutrition_summary.dart';
import '../utils/constants.dart';

class NutritionService {
  NutritionSummary summarize(List<NutritionLog> logs, List<FoodItem> foods) {
    double totalProtein = 0;
    double totalCalories = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    final foodMap = {for (final f in foods) f.id.toString(): f};

    for (final log in logs) {
      final food = foodMap[log.foodItemId];
      if (food == null) continue;
      // For nos: quantity is count (1 egg = 1 serving)
      // For grams/ml: quantity is actual amount, divide by servingSize
      final multiplier = food.unit == 'nos'
          ? log.quantity
          : log.quantity / food.servingSize;
      totalProtein += food.protein * multiplier;
      totalCalories += food.calories * multiplier;
      totalCarbs += food.carbs * multiplier;
      totalFat += food.fat * multiplier;
    }

    final deficits = {
      'protein': max(0.0, kDefaultProteinGoal - totalProtein),
      'calories': max(0.0, kDefaultCalorieGoal - totalCalories),
      'carbs': max(0.0, kDefaultCarbGoal - totalCarbs),
      'fat': max(0.0, kDefaultFatGoal - totalFat),
    };

    final deficitPercents = {
      'protein': (deficits['protein']! / kDefaultProteinGoal) * 100,
      'calories': (deficits['calories']! / kDefaultCalorieGoal) * 100,
      'carbs': (deficits['carbs']! / kDefaultCarbGoal) * 100,
      'fat': (deficits['fat']! / kDefaultFatGoal) * 100,
    };

    double penalty = 0;
    if (deficitPercents['protein']! > kProteinDeficitThreshold) {
      penalty += kProteinPenalty;
    }
    if (deficitPercents['calories']! > kCalorieDeficitThreshold) {
      penalty += kCaloriePenalty;
    }

    return NutritionSummary(
      totalProtein: totalProtein,
      totalCalories: totalCalories,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      proteinGoal: kDefaultProteinGoal,
      calorieGoal: kDefaultCalorieGoal,
      carbGoal: kDefaultCarbGoal,
      fatGoal: kDefaultFatGoal,
      deficits: deficits,
      deficitPercents: deficitPercents,
      burnoutPenalty: penalty,
    );
  }
}
