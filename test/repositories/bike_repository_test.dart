import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cyclot_v1/repositories/bike_repository.dart';
import 'package:cyclot_v1/core/constants.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late BikeRepository bikeRepository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    bikeRepository = BikeRepository(firestore: fakeFirestore);
  });

  group('BikeRepository', () {
    test('getAllBikes returns all bikes', () async {
      await fakeFirestore.collection(FirestoreCollections.bikes).add({
        FirestoreFields.bikeId: '1',
        FirestoreFields.isAllocated: false,
        FirestoreFields.isDamaged: false,
      });
      await fakeFirestore.collection(FirestoreCollections.bikes).add({
        FirestoreFields.bikeId: '2',
        FirestoreFields.isAllocated: true,
        FirestoreFields.isDamaged: false,
      });

      final bikes = await bikeRepository.getAllBikes();
      expect(bikes.length, 2);
    });

    test('getAvailableBikes returns only unallocated bikes', () async {
      await fakeFirestore.collection(FirestoreCollections.bikes).add({
        FirestoreFields.bikeId: '1',
        FirestoreFields.isAllocated: false,
        FirestoreFields.isDamaged: false,
      });
      await fakeFirestore.collection(FirestoreCollections.bikes).add({
        FirestoreFields.bikeId: '2',
        FirestoreFields.isAllocated: true,
        FirestoreFields.isDamaged: false,
      });

      final bikes = await bikeRepository.getAvailableBikes();
      expect(bikes.length, 1);
      expect(bikes.first.bikeId, '1');
    });
  });
}
