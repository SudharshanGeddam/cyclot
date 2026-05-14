// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:cyclot_v1/core/constants.dart';
import 'package:cyclot_v1/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get user by UID
  Future<AppUser?> getUser(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .get();

      if (!doc.exists) return null;

      return AppUser.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }

  /// Get user role
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .get();

      if (!doc.exists) return null;

      final data = doc.data() ?? {};
      return data[FirestoreFields.role] as String?;
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateUser(String uid, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .update(updates);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user profile
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(FirestoreCollections.users).doc(uid).delete();
    } catch (e) {
      rethrow;
    }
  }
}
