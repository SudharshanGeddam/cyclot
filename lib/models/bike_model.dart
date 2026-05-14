import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';

class Bike {
  final String id;
  final String bikeId;
  final bool isAllocated;
  final bool isDamaged;
  final DateTime? createdAt;
  final String? allocatedTo;

  Bike({
    required this.id,
    required this.bikeId,
    required this.isAllocated,
    required this.isDamaged,
    this.createdAt,
    this.allocatedTo,
  });

  factory Bike.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Bike(
      id: doc.id,
      bikeId: data[FirestoreFields.bikeId] ?? '',
      isAllocated: data[FirestoreFields.isAllocated] ?? false,
      isDamaged: data[FirestoreFields.isDamaged] ?? false,
      createdAt: (data[FirestoreFields.createdAt] as Timestamp?)?.toDate(),
      allocatedTo: data['allocatedTo'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FirestoreFields.bikeId: bikeId,
      FirestoreFields.isAllocated: isAllocated,
      FirestoreFields.isDamaged: isDamaged,
      FirestoreFields.createdAt: createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      if (allocatedTo != null) 'allocatedTo': allocatedTo,
    };
  }

  Bike copyWith({
    String? id,
    String? bikeId,
    bool? isAllocated,
    bool? isDamaged,
    DateTime? createdAt,
    String? allocatedTo,
  }) {
    return Bike(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      isAllocated: isAllocated ?? this.isAllocated,
      isDamaged: isDamaged ?? this.isDamaged,
      createdAt: createdAt ?? this.createdAt,
      allocatedTo: allocatedTo ?? this.allocatedTo,
    );
  }
}
