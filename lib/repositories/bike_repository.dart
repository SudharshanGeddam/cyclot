// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:cyclot_v1/core/constants.dart';
import 'package:cyclot_v1/models/bike_model.dart';

class BikeRepository {
  final FirebaseFirestore _firestore;

  BikeRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get all bikes
  Future<List<Bike>> getAllBikes() async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.bikes)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) => Bike.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get available bikes (not allocated)
  Future<List<Bike>> getAvailableBikes() async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.bikes)
          .where(FirestoreFields.isAllocated, isEqualTo: false)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) => Bike.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get bikes stream for real-time updates
  Stream<List<Bike>> getBikesStream() {
    return _firestore
        .collection(FirestoreCollections.bikes)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Bike.fromFirestore(doc)).toList(),
        );
  }

  /// Get bike by ID
  Future<Bike?> getBikeByBikeId(String bikeId) async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.bikes)
          .where(FirestoreFields.bikeId, isEqualTo: bikeId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return Bike.fromFirestore(snapshot.docs.first);
    } catch (e) {
      rethrow;
    }
  }

  /// Add a new bike
  Future<String> addBike(Bike bike) async {
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.bikes)
          .add(bike.toFirestore());

      return doc.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Update bike
  Future<void> updateBike(String docId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection(FirestoreCollections.bikes)
          .doc(docId)
          .update(updates);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete bike
  Future<void> deleteBike(String docId) async {
    try {
      await _firestore
          .collection(FirestoreCollections.bikes)
          .doc(docId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Get bikes dashboard stats with optimized queries
  /// Avoid loading entire collection by using targeted queries
  Future<Map<String, int>> getBikesStats() async {
    try {
      // Get total count
      final totalSnapshot = await _firestore
          .collection(FirestoreCollections.bikes)
          .count()
          .get();
      final total = totalSnapshot.count ?? 0;

      // Get allocated count
      final allocatedSnapshot = await _firestore
          .collection(FirestoreCollections.bikes)
          .where(FirestoreFields.isAllocated, isEqualTo: true)
          .count()
          .get();
      final allocated = allocatedSnapshot.count ?? 0;

      // Get damaged count
      final damagedSnapshot = await _firestore
          .collection(FirestoreCollections.bikes)
          .where(FirestoreFields.isDamaged, isEqualTo: true)
          .count()
          .get();
      final damaged = damagedSnapshot.count ?? 0;

      return {
        'total': total,
        'allocated': allocated,
        'available': total - allocated,
        'damaged': damaged,
        'undamaged': total - damaged,
      };
    } catch (e) {
      rethrow;
    }
  }
}
