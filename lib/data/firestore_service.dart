import 'package:cloud_firestore/cloud_firestore.dart';
import 'food_data.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  FirebaseFirestore get db => _db;

  // ── User profile ──
  DocumentReference userDoc(String uid) => _db.collection('users').doc(uid);

  // ── Per-user subcollections ──
  CollectionReference checkIns(String uid) =>
      userDoc(uid).collection('check_ins');

  CollectionReference nutritionLogs(String uid) =>
      userDoc(uid).collection('nutrition_logs');

  // ── Shared top-level collection ──
  CollectionReference get foodItems => _db.collection('food_items');

  /// Seed preset food items if the collection is empty (first launch).
  Future<void> seedFoodItemsIfNeeded() async {
    final snapshot = await foodItems.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final batch = _db.batch();
    for (final food in kPresetFoods) {
      final docRef = foodItems.doc(food.id.toString());
      batch.set(docRef, food.toMap());
    }
    await batch.commit();
  }
}
