import 'package:cloud_firestore/cloud_firestore.dart';

class NutritionLog {
  final String? id;
  final DateTime date;
  final String foodItemId;
  final double quantity;
  final DateTime createdAt;

  NutritionLog({
    this.id,
    required this.date,
    required this.foodItemId,
    required this.quantity,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String().substring(0, 10),
        'food_item_id': foodItemId,
        'quantity': quantity,
        'created_at': Timestamp.fromDate(createdAt),
      };

  factory NutritionLog.fromMap(Map<String, dynamic> map, {String? id}) =>
      NutritionLog(
        id: id,
        date: DateTime.parse(map['date'] as String),
        foodItemId: map['food_item_id'] as String,
        quantity: (map['quantity'] as num).toDouble(),
        createdAt: map['created_at'] is Timestamp
            ? (map['created_at'] as Timestamp).toDate()
            : DateTime.parse(map['created_at'] as String),
      );

  factory NutritionLog.fromSnapshot(DocumentSnapshot doc) =>
      NutritionLog.fromMap(doc.data() as Map<String, dynamic>, id: doc.id);

  String get dateKey => date.toIso8601String().substring(0, 10);
}
