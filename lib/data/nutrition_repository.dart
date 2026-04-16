import '../models/food_item.dart';
import '../models/nutrition_log.dart';
import 'firestore_service.dart';

class NutritionRepository {
  final FirestoreService _firestore;

  NutritionRepository(this._firestore);

  /// Get all preset food items (shared collection).
  Future<List<FoodItem>> getAllFoodItems() async {
    final snapshot = await _firestore.foodItems.orderBy('id').get();
    return snapshot.docs
        .map((doc) => FoodItem.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Get today's nutrition logs for a user.
  Future<List<NutritionLog>> getTodayLogs(String uid) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final snapshot = await _firestore
        .nutritionLogs(uid)
        .where('date', isEqualTo: today)
        .orderBy('created_at')
        .get();

    return snapshot.docs
        .map((doc) => NutritionLog.fromSnapshot(doc))
        .toList();
  }

  /// Add a nutrition log entry for a user.
  Future<void> saveLog(String uid, NutritionLog log) async {
    await _firestore.nutritionLogs(uid).add(log.toMap());
  }

  /// Delete a nutrition log entry.
  Future<void> deleteLog(String uid, String logId) async {
    await _firestore.nutritionLogs(uid).doc(logId).delete();
  }

  /// Delete all nutrition logs for a user.
  Future<void> clearAll(String uid) async {
    final snapshot = await _firestore.nutritionLogs(uid).get();
    final batch = _firestore.db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
