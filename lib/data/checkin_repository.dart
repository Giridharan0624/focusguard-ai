import '../models/user_input.dart';
import 'firestore_service.dart';

class CheckInRepository {
  final FirestoreService _firestore;

  CheckInRepository(this._firestore);

  /// Save or overwrite today's check-in (upsert by date key).
  Future<void> save(String uid, UserInput input, double burnoutScore) async {
    final data = {
      ...input.toMap(),
      'burnout_score': burnoutScore,
    };
    await _firestore.checkIns(uid).doc(input.dateKey).set(data);
  }

  /// Get the most recent [count] burnout scores (oldest first).
  Future<List<double>> getRecentScores(String uid, int count) async {
    final snapshot = await _firestore
        .checkIns(uid)
        .orderBy('date', descending: true)
        .limit(count)
        .get();

    return snapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return (data['burnout_score'] as num).toDouble();
        })
        .toList()
        .reversed
        .toList();
  }

  /// Get today's check-in if it exists.
  Future<UserInput?> getToday(String uid) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final doc = await _firestore.checkIns(uid).doc(today).get();
    if (!doc.exists) return null;
    return UserInput.fromSnapshot(doc);
  }

  /// Get today's burnout score if a check-in exists.
  Future<double?> getTodayScore(String uid) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final doc = await _firestore.checkIns(uid).doc(today).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    return (data['burnout_score'] as num).toDouble();
  }

  /// Get all check-ins (newest first) for history screen.
  Future<List<Map<String, dynamic>>> getAll(String uid) async {
    final snapshot = await _firestore
        .checkIns(uid)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Delete all check-in data for a user.
  Future<void> clearAll(String uid) async {
    final snapshot = await _firestore.checkIns(uid).get();
    final batch = _firestore.db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
