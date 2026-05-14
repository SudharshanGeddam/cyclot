import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cyclot_v1/repositories/allocation_repository.dart';
import 'package:cyclot_v1/core/constants.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late AllocationRepository allocationRepository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    allocationRepository = AllocationRepository(firestore: fakeFirestore);
  });

  group('AllocationRepository', () {
    test('getActiveAllocationForEmployee returns active allocation', () async {
      await fakeFirestore.collection(FirestoreCollections.allocations).add({
        FirestoreFields.employeeId: 'EMP_1',
        'status': 'returned',
      });
      await fakeFirestore.collection(FirestoreCollections.allocations).add({
        FirestoreFields.employeeId: 'EMP_1',
        'status': 'active',
      });

      final alloc = await allocationRepository.getActiveAllocationForEmployee('EMP_1');
      expect(alloc, isNotNull);
      expect(alloc!.status, 'active');
    });

    test('getAllocationStats returns correct counts', () async {
      await fakeFirestore.collection(FirestoreCollections.allocations).add({
        FirestoreFields.employeeId: 'EMP_1',
        'status': 'returned',
      });
      await fakeFirestore.collection(FirestoreCollections.allocations).add({
        FirestoreFields.employeeId: 'EMP_2',
        'status': 'active',
      });
      await fakeFirestore.collection(FirestoreCollections.allocations).add({
        FirestoreFields.employeeId: 'EMP_3',
        'status': 'active',
      });

      final stats = await allocationRepository.getAllocationStats();
      expect(stats['total'], 3);
      expect(stats['active'], 2);
      expect(stats['returned'], 1);
    });
  });
}
