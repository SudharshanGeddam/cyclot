import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cyclot_v1/core/constants.dart';

class BikeService {
  final FirebaseFirestore _firestore;

  BikeService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> bulkAddBikesToFirestore(int numberOfBikes) async {
    final bikesCollection = _firestore.collection(FirestoreCollections.bikes);

    final batch = _firestore.batch();
    final bikeColors = ['Red', 'Blue', 'Green', 'Yellow'];
    for (int i = 0; i < numberOfBikes; i++) {
      final docRef = bikesCollection.doc();
      final bikeId = docRef.id;

      final bikeData = {
        FirestoreFields.bikeId: bikeId,
        'color': bikeColors[i % bikeColors.length],
        FirestoreFields.isAllocated: false,
        FirestoreFields.isDamaged: false,
        FirestoreFields.createdAt: FieldValue.serverTimestamp(),
      };

      batch.set(docRef, bikeData);
    }

    await batch.commit();
  }
}
