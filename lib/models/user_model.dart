import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String name;
  final String email;

  AppUser({
    required this.name,
    required this.email,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppUser(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
    );
  }
}