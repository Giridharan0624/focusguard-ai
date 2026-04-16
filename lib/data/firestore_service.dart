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

  // ── AI cache ──
  CollectionReference aiCache(String uid) =>
      userDoc(uid).collection('ai_cache');

  // ── Shared top-level collection ──
  CollectionReference get foodItems => _db.collection('food_items');

  /// Seed preset food items. Re-seeds if data is outdated (missing unit field).
  Future<void> seedFoodItemsIfNeeded() async {
    final snapshot = await foodItems.limit(1).get();

    // Check if re-seed needed (old data missing 'unit' field)
    bool needsReseed = snapshot.docs.isEmpty;
    if (!needsReseed && snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data() as Map<String, dynamic>?;
      if (data != null && !data.containsKey('unit')) {
        needsReseed = true;
      }
    }

    if (!needsReseed) return;

    // Delete old food items
    if (snapshot.docs.isNotEmpty) {
      final allDocs = await foodItems.get();
      final deleteBatch = _db.batch();
      for (final doc in allDocs.docs) {
        deleteBatch.delete(doc.reference);
      }
      await deleteBatch.commit();
    }

    // Seed fresh
    final batch = _db.batch();
    for (final food in kPresetFoods) {
      final docRef = foodItems.doc(food.id.toString());
      batch.set(docRef, food.toMap());
    }
    await batch.commit();
  }
}
