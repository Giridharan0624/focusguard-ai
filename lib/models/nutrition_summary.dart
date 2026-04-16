class NutritionSummary {
  final double totalProtein;
  final double totalCalories;
  final double totalCarbs;
  final double totalFat;
  final double proteinGoal;
  final double calorieGoal;
  final double carbGoal;
  final double fatGoal;
  final Map<String, double> deficits;
  final Map<String, double> deficitPercents;
  final double burnoutPenalty;

  const NutritionSummary({
    required this.totalProtein,
    required this.totalCalories,
    required this.totalCarbs,
    required this.totalFat,
    required this.proteinGoal,
    required this.calorieGoal,
    required this.carbGoal,
    required this.fatGoal,
    required this.deficits,
    required this.deficitPercents,
    required this.burnoutPenalty,
  });

  double progressPercent(String nutrient) {
    switch (nutrient) {
      case 'protein':
        return (totalProtein / proteinGoal * 100).clamp(0, 100);
      case 'calories':
        return (totalCalories / calorieGoal * 100).clamp(0, 100);
      case 'carbs':
        return (totalCarbs / carbGoal * 100).clamp(0, 100);
      case 'fat':
        return (totalFat / fatGoal * 100).clamp(0, 100);
      default:
        return 0;
    }
  }
}
