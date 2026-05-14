import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cyclot_v1/services/bike_service.dart';
import 'package:cyclot_v1/core/constants.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late BikeService bikeService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    bikeService = BikeService(firestore: fakeFirestore);
  });

  group('BikeService', () {
    test('bulkAddBikesToFirestore creates the exact number of bikes', () async {
      await bikeService.bulkAddBikesToFirestore(5);

      final snapshot = await fakeFirestore
          .collection(FirestoreCollections.bikes)
          .get();
      expect(snapshot.docs.length, 5);

      for (var doc in snapshot.docs) {
        final data = doc.data();
        expect(data[FirestoreFields.isAllocated], isFalse);
        expect(data[FirestoreFields.isDamaged], isFalse);
        expect(data[FirestoreFields.bikeId], doc.id);
      }
    });
  });
}
