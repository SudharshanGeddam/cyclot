// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:cyclot_v1/core/constants.dart';
import 'package:cyclot_v1/repositories/allocation_repository.dart';
import 'package:cyclot_v1/repositories/bike_repository.dart';

class AllocationService {
  final FirebaseFirestore _firestore;
  final BikeRepository bikeRepo;
  final AllocationRepository allocationRepo;

  AllocationService({
    FirebaseFirestore? firestore,
    BikeRepository? bikeRepository,
    AllocationRepository? allocationRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       bikeRepo = bikeRepository ?? BikeRepository(firestore: firestore),
       allocationRepo =
           allocationRepository ?? AllocationRepository(firestore: firestore);

  /// Complete bike return review (mark as damaged or undamaged)
  Future<void> reviewReturnedBike({
    required String allocationId,
    required String bikeId,
    required String employeeId,
    required bool isDamaged,
  }) async {
    try {
      final bike = await bikeRepo.getBikeByBikeId(bikeId);
      if (bike == null) throw Exception('Bike not found');

      final condition = isDamaged
          ? ReviewStatus.damaged
          : ReviewStatus.undamaged;
      final batch = _firestore.batch();

      // Update bike document
      batch.update(
        _firestore.collection(FirestoreCollections.bikes).doc(bike.id),
        {
          FirestoreFields.isDamaged: isDamaged,
          FirestoreFields.isAllocated: false,
        },
      );

      // Update allocation document
      batch.update(
        _firestore
            .collection(FirestoreCollections.allocations)
            .doc(allocationId),
        {
          'conditionReviewed': true,
          'condition': condition,
          FirestoreFields.reviewedAt: FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();

      // Create notification for employee with server timestamp
      await _firestore.collection(FirestoreCollections.notifications).add({
        FirestoreFields.employeeId: employeeId,
        FirestoreFields.bikeId: bikeId,
        FirestoreFields.message: isDamaged
            ? 'Your returned bike ($bikeId) was marked as damaged. Please contact administration.'
            : 'Your returned bike ($bikeId) has been reviewed and accepted. Thank you!',
        FirestoreFields.createdAtField: FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Allocate bike to employee
  Future<String> allocateBike({
    required String employeeId,
    required String employeeName,
    required String bikeId,
  }) async {
    try {
      final bikesQuery = await _firestore
          .collection(FirestoreCollections.bikes)
          .where(FirestoreFields.bikeId, isEqualTo: bikeId)
          .limit(1)
          .get();
      if (bikesQuery.docs.isEmpty) throw Exception('Bike not found');
      final bikeRef = bikesQuery.docs.first.reference;

      return await _firestore.runTransaction((transaction) async {
        final bikeSnapshot = await transaction.get(bikeRef);
        if (!bikeSnapshot.exists) throw Exception('Bike not found');

        final isAllocated =
            bikeSnapshot.data()?[FirestoreFields.isAllocated] ?? false;
        if (isAllocated) throw Exception('Bike is already allocated');

        // Mark bike as allocated
        transaction.update(bikeRef, {
          FirestoreFields.isAllocated: true,
          'allocatedTo': employeeId,
        });

        // Create allocation record
        final allocationRef = _firestore
            .collection(FirestoreCollections.allocations)
            .doc();

        transaction.set(allocationRef, {
          FirestoreFields.employeeId: employeeId,
          FirestoreFields.userName: employeeName,
          FirestoreFields.bikeId: bikeId,
          FirestoreFields.allocatedAt: FieldValue.serverTimestamp(),
          'status': 'active',
          'conditionReviewed': false,
        });

        // Create notification with server timestamp
        final notificationRef = _firestore
            .collection(FirestoreCollections.notifications)
            .doc();

        transaction.set(notificationRef, {
          FirestoreFields.employeeId: employeeId,
          FirestoreFields.bikeId: bikeId,
          FirestoreFields.message:
              'You have been allocated bike $bikeId. Please use it responsibly.',
          FirestoreFields.createdAtField: FieldValue.serverTimestamp(),
          'read': false,
        });

        return allocationRef.id;
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Return bike (mark allocation as returned)
  Future<void> returnBike({
    required String allocationId,
    required String bikeId,
  }) async {
    try {
      final batch = _firestore.batch();

      // Update allocation status to returned
      batch.update(
        _firestore
            .collection(FirestoreCollections.allocations)
            .doc(allocationId),
        {
          'status': BikeStatus.returned,
          'returnedAt': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }
}
