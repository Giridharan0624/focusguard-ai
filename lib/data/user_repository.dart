import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import 'firestore_service.dart';

class UserRepository {
  final FirestoreService _firestore;

  UserRepository(this._firestore);

  /// Get user profile by UID.
  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _firestore.userDoc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromSnapshot(doc);
  }

  /// Create or update user profile.
  Future<void> saveProfile(UserProfile profile) async {
    await _firestore.userDoc(profile.uid).set(
          profile.toMap(),
          SetOptions(merge: true),
        );
  }

  /// Check if a profile exists.
  Future<bool> profileExists(String uid) async {
    final doc = await _firestore.userDoc(uid).get();
    return doc.exists;
  }

  /// Delete user profile and all subcollection data.
  Future<void> deleteAccount(String uid) async {
    // Delete subcollections first
    final checkIns = await _firestore.checkIns(uid).get();
    final nutritionLogs = await _firestore.nutritionLogs(uid).get();

    final batch = _firestore.db.batch();
    for (final doc in checkIns.docs) {
      batch.delete(doc.reference);
    }
    for (final doc in nutritionLogs.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_firestore.userDoc(uid));
    await batch.commit();
  }
}
