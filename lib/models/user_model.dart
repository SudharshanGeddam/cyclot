import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppUser(
      uid: doc.id,
      name: data[FirestoreFields.name] ?? '',
      email: data[FirestoreFields.email] ?? '',
      role: data[FirestoreFields.role] ?? UserRoles.employee,
      createdAt:
          (data[FirestoreFields.createdAt] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FirestoreFields.name: name,
      FirestoreFields.email: email,
      FirestoreFields.role: role,
      FirestoreFields.createdAt: Timestamp.fromDate(createdAt),
    };
  }
}
