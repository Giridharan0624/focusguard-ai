class FoodItem {
  final int id;
  final String name;
  final double servingSize;
  final double protein;
  final double calories;
  final double carbs;
  final double fat;
  final String category;
  final String icon;

  const FoodItem({
    required this.id,
    required this.name,
    required this.servingSize,
    required this.protein,
    required this.calories,
    required this.carbs,
    required this.fat,
    required this.category,
    required this.icon,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'serving_size': servingSize,
        'protein': protein,
        'calories': calories,
        'carbs': carbs,
        'fat': fat,
        'category': category,
        'icon': icon,
      };

  factory FoodItem.fromMap(Map<String, dynamic> map) => FoodItem(
        id: map['id'] as int,
        name: map['name'] as String,
        servingSize: (map['serving_size'] as num).toDouble(),
        protein: (map['protein'] as num).toDouble(),
        calories: (map['calories'] as num).toDouble(),
        carbs: (map['carbs'] as num).toDouble(),
        fat: (map['fat'] as num).toDouble(),
        category: map['category'] as String,
        icon: map['icon'] as String,
      );
}
