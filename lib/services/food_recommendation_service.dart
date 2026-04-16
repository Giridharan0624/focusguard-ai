import '../models/food_item.dart';
import '../models/nutrition_summary.dart';

class FoodRecommendationService {
  List<FoodItem> recommend(NutritionSummary summary, List<FoodItem> allFoods) {
    // Find the nutrient with the largest deficit percentage
    final worstNutrient = summary.deficitPercents.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Map nutrient → food category
    final targetCategory = const {
      'protein': 'protein-rich',
      'calories': 'energy',
      'carbs': 'energy',
      'fat': 'balanced',
    }[worstNutrient] ?? 'balanced';

    final filtered =
        allFoods.where((f) => f.category == targetCategory).toList();

    filtered.sort((a, b) {
      final ad = _nutrientDensity(a, worstNutrient);
      final bd = _nutrientDensity(b, worstNutrient);
      return bd.compareTo(ad);
    });

    return filtered.take(5).toList();
  }

  double _nutrientDensity(FoodItem food, String nutrient) {
    if (food.servingSize == 0) return 0;
    switch (nutrient) {
      case 'protein':
        return food.protein / food.servingSize * 100;
      case 'calories':
        return food.calories / food.servingSize * 100;
      case 'carbs':
        return food.carbs / food.servingSize * 100;
      case 'fat':
        return food.fat / food.servingSize * 100;
      default:
        return 0;
    }
  }
}
