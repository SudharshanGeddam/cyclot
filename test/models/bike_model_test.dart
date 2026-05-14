// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:cyclot_v1/models/bike_model.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Bike Model', () {
    group('fromFirestore', () {
      test('parses bike data correctly', () async {
        final now = DateTime.now();
        final mockDoc = await createMockDoc({
          'bikeId': 'BIKE-001',
          'isAllocated': true,
          'isDamaged': false,
          'createdAt': Timestamp.fromDate(now),
          'allocatedTo': 'emp-123',
        }, 'bike-id-123');

        final bike = Bike.fromFirestore(mockDoc);

        expect(bike.id, equals('bike-id-123'));
        expect(bike.bikeId, equals('BIKE-001'));
        expect(bike.isAllocated, isTrue);
        expect(bike.isDamaged, isFalse);
        expect(bike.allocatedTo, equals('emp-123'));
      });

      test('defaults to available and undamaged when not specified', () async {
        final mockDoc = await createMockDoc({
          'bikeId': 'BIKE-002',
          'createdAt': Timestamp.fromDate(DateTime.now()),
        }, 'bike-id-456');

        final bike = Bike.fromFirestore(mockDoc);

        expect(bike.isAllocated, isFalse);
        expect(bike.isDamaged, isFalse);
        expect(bike.allocatedTo, isNull);
      });

      test('defaults empty string when bikeId is missing', () async {
        final mockDoc = await createMockDoc({
          'createdAt': Timestamp.fromDate(DateTime.now()),
        }, 'bike-id-789');

        final bike = Bike.fromFirestore(mockDoc);

        expect(bike.bikeId, equals(''));
      });

      test('handles null timestamp gracefully', () async {
        final mockDoc = await createMockDoc({
          'bikeId': 'BIKE-003',
        }, 'bike-id-999');

        final bike = Bike.fromFirestore(mockDoc);

        expect(bike.createdAt, isNull);
      });
    });

    group('toFirestore', () {
      test('serializes bike to Firestore format', () {
        final now = DateTime.now();
        final bike = Bike(
          id: 'bike-123',
          bikeId: 'BIKE-001',
          isAllocated: true,
          isDamaged: false,
          createdAt: now,
          allocatedTo: 'emp-123',
        );

        final data = bike.toFirestore();

        expect(data['bikeId'], equals('BIKE-001'));
        expect(data['isAllocated'], isTrue);
        expect(data['isDamaged'], isFalse);
        expect(data['allocatedTo'], equals('emp-123'));
        expect(data['createdAt'], isA<Timestamp>());
      });

      test('omits allocatedTo when null', () {
        final bike = Bike(
          id: 'bike-456',
          bikeId: 'BIKE-002',
          isAllocated: false,
          isDamaged: false,
          createdAt: DateTime.now(),
        );

        final data = bike.toFirestore();

        expect(data.containsKey('allocatedTo'), isFalse);
      });

      test('does not include id in toFirestore output', () {
        final bike = Bike(
          id: 'bike-123',
          bikeId: 'BIKE-001',
          isAllocated: false,
          isDamaged: false,
          createdAt: DateTime.now(),
        );

        final data = bike.toFirestore();

        expect(data.containsKey('id'), isFalse);
      });
    });

    group('copyWith', () {
      test('creates new instance with updated fields', () {
        final original = Bike(
          id: 'bike-123',
          bikeId: 'BIKE-001',
          isAllocated: false,
          isDamaged: false,
          createdAt: DateTime(2024, 5, 14),
          allocatedTo: null,
        );

        final updated = original.copyWith(
          isAllocated: true,
          allocatedTo: 'emp-123',
        );

        expect(updated.id, equals(original.id));
        expect(updated.bikeId, equals(original.bikeId));
        expect(updated.isAllocated, isTrue);
        expect(updated.allocatedTo, equals('emp-123'));
        expect(updated.createdAt, equals(original.createdAt));
      });

      test('preserves fields when not specified', () {
        final original = Bike(
          id: 'bike-456',
          bikeId: 'BIKE-002',
          isAllocated: true,
          isDamaged: true,
          createdAt: DateTime(2024, 5, 14),
          allocatedTo: 'emp-456',
        );

        final updated = original.copyWith(isDamaged: false);

        expect(updated.bikeId, equals(original.bikeId));
        expect(updated.isAllocated, equals(original.isAllocated));
        expect(updated.allocatedTo, equals(original.allocatedTo));
        expect(updated.isDamaged, isFalse);
      });
    });

    group('Round-trip serialization', () {
      test('fromFirestore and toFirestore are consistent', () async {
        final originalBike = Bike(
          id: 'bike-123',
          bikeId: 'BIKE-001',
          isAllocated: true,
          isDamaged: false,
          createdAt: DateTime(2024, 5, 14),
          allocatedTo: 'emp-123',
        );

        final firestoreData = originalBike.toFirestore();
        final mockDoc = await createMockDoc(
          firestoreData,
          originalBike.id,
        );
        final deserializedBike = Bike.fromFirestore(mockDoc);

        expect(deserializedBike.bikeId, equals(originalBike.bikeId));
        expect(deserializedBike.isAllocated, equals(originalBike.isAllocated));
        expect(deserializedBike.isDamaged, equals(originalBike.isDamaged));
        expect(deserializedBike.allocatedTo, equals(originalBike.allocatedTo));
      });
    });
  });
}
