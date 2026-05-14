import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';

class Allocation {
  final String id;
  final String employeeId;
  final String userName;
  final String bikeId;
  final DateTime? allocatedAt;
  final String status; // 'active' or 'returned'
  final bool conditionReviewed;
  final String? condition; // 'damaged' or 'undamaged'
  final DateTime? reviewedAt;

  Allocation({
    required this.id,
    required this.employeeId,
    required this.userName,
    required this.bikeId,
    this.allocatedAt,
    required this.status,
    required this.conditionReviewed,
    this.condition,
    this.reviewedAt,
  });

  factory Allocation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Allocation(
      id: doc.id,
      employeeId: data[FirestoreFields.employeeId] ?? '',
      userName: data[FirestoreFields.userName] ?? '',
      bikeId: data[FirestoreFields.bikeId] ?? '',
      allocatedAt: (data[FirestoreFields.allocatedAt] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'active',
      conditionReviewed: data['conditionReviewed'] ?? false,
      condition: data['condition'] as String?,
      reviewedAt: (data[FirestoreFields.reviewedAt] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FirestoreFields.employeeId: employeeId,
      FirestoreFields.userName: userName,
      FirestoreFields.bikeId: bikeId,
      FirestoreFields.allocatedAt: allocatedAt != null
          ? Timestamp.fromDate(allocatedAt!)
          : FieldValue.serverTimestamp(),
      'status': status,
      'conditionReviewed': conditionReviewed,
      if (condition != null) 'condition': condition,
      if (reviewedAt != null)
        FirestoreFields.reviewedAt: Timestamp.fromDate(reviewedAt!),
    };
  }

  Allocation copyWith({
    String? id,
    String? employeeId,
    String? userName,
    String? bikeId,
    DateTime? allocatedAt,
    String? status,
    bool? conditionReviewed,
    String? condition,
    DateTime? reviewedAt,
  }) {
    return Allocation(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      userName: userName ?? this.userName,
      bikeId: bikeId ?? this.bikeId,
      allocatedAt: allocatedAt ?? this.allocatedAt,
      status: status ?? this.status,
      conditionReviewed: conditionReviewed ?? this.conditionReviewed,
      condition: condition ?? this.condition,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}
