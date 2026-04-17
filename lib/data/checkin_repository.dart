import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
    debugPrint('[CheckInRepo] save uid=$uid date=${input.dateKey} score=$burnoutScore');
    await _firestore.checkIns(uid).doc(input.dateKey).set(data);
    debugPrint('[CheckInRepo] save COMPLETE date=${input.dateKey}');
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
  /// [forceServer] tries the Firestore server first so a just-written check-in
  /// actually appears; if the server is unreachable we transparently fall back
  /// to the offline cache instead of erroring the whole screen.
  Future<List<Map<String, dynamic>>> getAll(String uid,
      {bool forceServer = false}) async {
    final query =
        _firestore.checkIns(uid).orderBy('date', descending: true);

    QuerySnapshot snapshot;
    String sourceUsed;
    if (forceServer) {
      try {
        snapshot = await query.get(const GetOptions(source: Source.server));
        sourceUsed = 'server';
      } on FirebaseException catch (e) {
        debugPrint('[CheckInRepo] getAll server fetch failed (${e.code}) — falling back to cache');
        snapshot = await query.get(const GetOptions(source: Source.cache));
        sourceUsed = 'cache(fallback)';
      }
    } else {
      snapshot = await query.get();
      sourceUsed = 'default';
    }

    final results = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
    debugPrint('[CheckInRepo] getAll uid=$uid forceServer=$forceServer source=$sourceUsed docs=${results.length} fromCache=${snapshot.metadata.isFromCache} pendingWrites=${snapshot.metadata.hasPendingWrites}');
    for (final r in results) {
      debugPrint('[CheckInRepo]   - id=${r['id']} date=${r['date']} score=${r['burnout_score']}');
    }
    return results;
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
