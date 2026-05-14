// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:cyclot_v1/core/constants.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthService({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get current user UID
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  /// Login with email and password
  Future<String> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Verify user exists in Firestore
      final doc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .get();

      if (!doc.exists) {
        throw Exception('User profile not found in Firestore');
      }

      return uid;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e.code);
    }
  }

  /// Register with email, password, and user data
  /// Always registers as employee - admin/security roles must be assigned server-side
  Future<String> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Create user profile in Firestore with employee role
      await _firestore.collection(FirestoreCollections.users).doc(uid).set({
        FirestoreFields.name: name,
        FirestoreFields.email: email,
        FirestoreFields.role: UserRoles.employee, // Always employee
        'createdAt': FieldValue.serverTimestamp(),
      });

      return uid;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e.code);
    }
  }

  /// Logout
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  /// Handle Firebase Auth errors
  String _handleAuthError(String code) {
    return switch (code) {
      'user-not-found' => 'No account found with this email',
      'wrong-password' => 'Incorrect password',
      'invalid-email' => 'Invalid email address',
      'user-disabled' => 'This account has been disabled',
      'too-many-requests' => 'Too many login attempts. Please try again later',
      'email-already-in-use' => 'Email is already registered',
      'weak-password' => 'Password is too weak',
      _ => 'Authentication failed: $code',
    };
  }
}
