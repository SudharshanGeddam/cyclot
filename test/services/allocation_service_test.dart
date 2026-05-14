import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cyclot_v1/services/allocation_service.dart';
import 'package:cyclot_v1/repositories/bike_repository.dart';
import 'package:cyclot_v1/repositories/allocation_repository.dart';
import 'package:cyclot_v1/core/constants.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late AllocationService allocationService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    allocationService = AllocationService(
      firestore: fakeFirestore,
      bikeRepository: BikeRepository(firestore: fakeFirestore),
      allocationRepository: AllocationRepository(firestore: fakeFirestore),
    );
  });

  group('AllocationService', () {
    test('allocateBike successfully allocates an available bike', () async {
      final bikeRef = await fakeFirestore
          .collection(FirestoreCollections.bikes)
          .add({
        FirestoreFields.bikeId: 'BIKE_1',
        FirestoreFields.isAllocated: false,
        FirestoreFields.isDamaged: false,
      });

      final allocationId = await allocationService.allocateBike(
        employeeId: 'EMP_1',
        employeeName: 'John Doe',
        bikeId: 'BIKE_1',
      );

      final bikeDoc = await fakeFirestore
          .collection(FirestoreCollections.bikes)
          .doc(bikeRef.id)
          .get();
      expect(bikeDoc.data()?[FirestoreFields.isAllocated], isTrue);
      expect(bikeDoc.data()?['allocatedTo'], 'EMP_1');

      final allocationDoc = await fakeFirestore
          .collection(FirestoreCollections.allocations)
          .doc(allocationId)
          .get();
      expect(allocationDoc.exists, isTrue);
      expect(allocationDoc.data()?[FirestoreFields.employeeId], 'EMP_1');
      expect(allocationDoc.data()?['status'], 'active');

      final notifQuery = await fakeFirestore
          .collection(FirestoreCollections.notifications)
          .get();
      expect(notifQuery.docs.length, 1);
      expect(
          notifQuery.docs.first.data()[FirestoreFields.employeeId], 'EMP_1');
    });

    test('allocateBike throws Exception if bike is already allocated', () async {
      await fakeFirestore.collection(FirestoreCollections.bikes).add({
        FirestoreFields.bikeId: 'BIKE_2',
        FirestoreFields.isAllocated: true,
        FirestoreFields.isDamaged: false,
      });

      expect(
        () => allocationService.allocateBike(
          employeeId: 'EMP_2',
          employeeName: 'Jane Doe',
          bikeId: 'BIKE_2',
        ),
        throwsException,
      );
    });

    test('reviewReturnedBike updates condition and sets bike to not allocated',
        () async {
      final bikeRef = await fakeFirestore
          .collection(FirestoreCollections.bikes)
          .add({
        FirestoreFields.bikeId: 'BIKE_3',
        FirestoreFields.isAllocated: true,
        FirestoreFields.isDamaged: false,
      });

      final allocRef = await fakeFirestore
          .collection(FirestoreCollections.allocations)
          .add({
        FirestoreFields.employeeId: 'EMP_3',
        FirestoreFields.bikeId: 'BIKE_3',
        'status': 'returned',
        'conditionReviewed': false,
      });

      await allocationService.reviewReturnedBike(
        allocationId: allocRef.id,
        bikeId: 'BIKE_3',
        employeeId: 'EMP_3',
        isDamaged: true,
      );

      final bikeDoc = await fakeFirestore
          .collection(FirestoreCollections.bikes)
          .doc(bikeRef.id)
          .get();
      expect(bikeDoc.data()?[FirestoreFields.isAllocated], isFalse);
      expect(bikeDoc.data()?[FirestoreFields.isDamaged], isTrue);

      final allocDoc = await allocRef.get();
      expect(allocDoc.data()?['conditionReviewed'], isTrue);
      expect(allocDoc.data()?['condition'], 'damaged');
    });
  });
}
