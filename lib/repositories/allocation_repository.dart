// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:cyclot_v1/core/constants.dart';
import 'package:cyclot_v1/models/allocation_model.dart';

class AllocationRepository {
  final FirebaseFirestore _firestore;

  AllocationRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Create new allocation
  Future<String> createAllocation(Allocation allocation) async {
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.allocations)
          .add(allocation.toFirestore());

      return doc.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Get allocation by ID
  Future<Allocation?> getAllocation(String allocationId) async {
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.allocations)
          .doc(allocationId)
          .get();

      if (!doc.exists) return null;

      return Allocation.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }

  /// Get allocations for employee
  Future<List<Allocation>> getEmployeeAllocations(String employeeId) async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.allocations)
          .where(FirestoreFields.employeeId, isEqualTo: employeeId)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) => Allocation.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get active allocation for employee
  Future<Allocation?> getActiveAllocationForEmployee(String employeeId) async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.allocations)
          .where(FirestoreFields.employeeId, isEqualTo: employeeId)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return Allocation.fromFirestore(snapshot.docs.first);
    } catch (e) {
      rethrow;
    }
  }

  /// Get returned bikes pending review
  Stream<List<Allocation>> getReturnedBikesStream() {
    return _firestore
        .collection(FirestoreCollections.allocations)
        .where('status', isEqualTo: BikeStatus.returned)
        .where('conditionReviewed', isEqualTo: false)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Allocation.fromFirestore(doc))
              .toList(),
        );
  }

  /// Update allocation
  Future<void> updateAllocation(
    String allocationId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore
          .collection(FirestoreCollections.allocations)
          .doc(allocationId)
          .update(updates);
    } catch (e) {
      rethrow;
    }
  }

  /// Get allocation stats with optimized queries
  /// Avoid loading entire collection by using targeted queries
  Future<Map<String, int>> getAllocationStats() async {
    try {
      // Get total count
      final totalSnapshot = await _firestore
          .collection(FirestoreCollections.allocations)
          .count()
          .get();
      final total = totalSnapshot.count ?? 0;

      // Get active count
      final activeSnapshot = await _firestore
          .collection(FirestoreCollections.allocations)
          .where('status', isEqualTo: 'active')
          .count()
          .get();
      final active = activeSnapshot.count ?? 0;

      return {'total': total, 'active': active, 'returned': total - active};
    } catch (e) {
      rethrow;
    }
  }
}
