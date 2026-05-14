import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';

class AppNotification {
  final String id;
  final String employeeId;
  final String bikeId;
  final String message;
  final DateTime? createdAt;
  final bool read;

  AppNotification({
    required this.id,
    required this.employeeId,
    required this.bikeId,
    required this.message,
    this.createdAt,
    required this.read,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppNotification(
      id: doc.id,
      employeeId: data[FirestoreFields.employeeId] ?? '',
      bikeId: data[FirestoreFields.bikeId] ?? '',
      message: data[FirestoreFields.message] ?? '',
      createdAt: (data[FirestoreFields.createdAtField] as Timestamp?)?.toDate(),
      read: data['read'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FirestoreFields.employeeId: employeeId,
      FirestoreFields.bikeId: bikeId,
      FirestoreFields.message: message,
      FirestoreFields.createdAtField: createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'read': read,
    };
  }

  AppNotification copyWith({
    String? id,
    String? employeeId,
    String? bikeId,
    String? message,
    DateTime? createdAt,
    bool? read,
  }) {
    return AppNotification(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      bikeId: bikeId ?? this.bikeId,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
    );
  }
}
