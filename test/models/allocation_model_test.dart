// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:cyclot_v1/models/allocation_model.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Allocation Model', () {
    group('fromFirestore', () {
      test('parses allocation data correctly', () async {
        final now = DateTime.now();
        final mockDoc = await createMockDoc({
          'employeeId': 'emp-123',
          'userName': 'John Doe',
          'bikeId': 'BIKE-001',
          'allocatedAt': Timestamp.fromDate(now),
          'status': 'active',
          'conditionReviewed': false,
        }, 'alloc-123');

        final allocation = Allocation.fromFirestore(mockDoc);

        expect(allocation.id, equals('alloc-123'));
        expect(allocation.employeeId, equals('emp-123'));
        expect(allocation.userName, equals('John Doe'));
        expect(allocation.bikeId, equals('BIKE-001'));
        expect(allocation.status, equals('active'));
        expect(allocation.conditionReviewed, isFalse);
        expect(allocation.condition, isNull);
        expect(allocation.reviewedAt, isNull);
      });

      test('parses returned allocation with condition review', () async {
        final allocatedAt = DateTime(2024, 5, 10);
        final reviewedAt = DateTime(2024, 5, 14);
        final mockDoc = await createMockDoc({
          'employeeId': 'emp-456',
          'userName': 'Jane Smith',
          'bikeId': 'BIKE-002',
          'allocatedAt': Timestamp.fromDate(allocatedAt),
          'status': 'returned',
          'conditionReviewed': true,
          'condition': 'damaged',
          'reviewedAt': Timestamp.fromDate(reviewedAt),
        }, 'alloc-456');

        final allocation = Allocation.fromFirestore(mockDoc);

        expect(allocation.status, equals('returned'));
        expect(allocation.conditionReviewed, isTrue);
        expect(allocation.condition, equals('damaged'));
        expect(allocation.reviewedAt, isNotNull);
      });

      test('defaults to active status when missing', () async {
        final mockDoc = await createMockDoc({
          'employeeId': 'emp-789',
          'userName': 'Test User',
          'bikeId': 'BIKE-003',
          'allocatedAt': Timestamp.fromDate(DateTime.now()),
        }, 'alloc-789');

        final allocation = Allocation.fromFirestore(mockDoc);

        expect(allocation.status, equals('active'));
        expect(allocation.conditionReviewed, isFalse);
      });

      test('defaults empty strings when fields are missing', () async {
        final mockDoc = await createMockDoc({
          'allocatedAt': Timestamp.fromDate(DateTime.now()),
        }, 'alloc-999');

        final allocation = Allocation.fromFirestore(mockDoc);

        expect(allocation.employeeId, equals(''));
        expect(allocation.userName, equals(''));
        expect(allocation.bikeId, equals(''));
      });
    });

    group('toFirestore', () {
      test('serializes active allocation correctly', () {
        final now = DateTime.now();
        final allocation = Allocation(
          id: 'alloc-123',
          employeeId: 'emp-123',
          userName: 'John Doe',
          bikeId: 'BIKE-001',
          allocatedAt: now,
          status: 'active',
          conditionReviewed: false,
        );

        final data = allocation.toFirestore();

        expect(data['employeeId'], equals('emp-123'));
        expect(data['userName'], equals('John Doe'));
        expect(data['bikeId'], equals('BIKE-001'));
        expect(data['status'], equals('active'));
        expect(data['conditionReviewed'], isFalse);
        expect(data['allocatedAt'], isA<Timestamp>());
      });

      test('serializes returned allocation with condition', () {
        final allocatedAt = DateTime(2024, 5, 10);
        final reviewedAt = DateTime(2024, 5, 14);
        final allocation = Allocation(
          id: 'alloc-456',
          employeeId: 'emp-456',
          userName: 'Jane Smith',
          bikeId: 'BIKE-002',
          allocatedAt: allocatedAt,
          status: 'returned',
          conditionReviewed: true,
          condition: 'undamaged',
          reviewedAt: reviewedAt,
        );

        final data = allocation.toFirestore();

        expect(data['condition'], equals('undamaged'));
        expect(data['reviewedAt'], isA<Timestamp>());
      });

      test('omits optional fields when null', () {
        final allocation = Allocation(
          id: 'alloc-789',
          employeeId: 'emp-789',
          userName: 'Test User',
          bikeId: 'BIKE-003',
          allocatedAt: DateTime.now(),
          status: 'active',
          conditionReviewed: false,
        );

        final data = allocation.toFirestore();

        expect(data.containsKey('condition'), isFalse);
        expect(data.containsKey('reviewedAt'), isFalse);
      });

      test('does not include id in toFirestore output', () {
        final allocation = Allocation(
          id: 'alloc-123',
          employeeId: 'emp-123',
          userName: 'Test',
          bikeId: 'BIKE-001',
          allocatedAt: DateTime.now(),
          status: 'active',
          conditionReviewed: false,
        );

        final data = allocation.toFirestore();

        expect(data.containsKey('id'), isFalse);
      });
    });

    group('copyWith', () {
      test('creates new instance with updated fields', () {
        final original = Allocation(
          id: 'alloc-123',
          employeeId: 'emp-123',
          userName: 'John Doe',
          bikeId: 'BIKE-001',
          allocatedAt: DateTime(2024, 5, 10),
          status: 'active',
          conditionReviewed: false,
        );

        final updated = original.copyWith(
          status: 'returned',
          conditionReviewed: true,
          condition: 'undamaged',
          reviewedAt: DateTime(2024, 5, 14),
        );

        expect(updated.id, equals(original.id));
        expect(updated.employeeId, equals(original.employeeId));
        expect(updated.status, equals('returned'));
        expect(updated.conditionReviewed, isTrue);
        expect(updated.condition, equals('undamaged'));
      });

      test('preserves fields when not specified', () {
        final allocatedAt = DateTime(2024, 5, 10);
        final reviewedAt = DateTime(2024, 5, 14);
        final original = Allocation(
          id: 'alloc-456',
          employeeId: 'emp-456',
          userName: 'Jane Smith',
          bikeId: 'BIKE-002',
          allocatedAt: allocatedAt,
          status: 'returned',
          conditionReviewed: true,
          condition: 'damaged',
          reviewedAt: reviewedAt,
        );

        final updated = original.copyWith(condition: 'undamaged');

        expect(updated.bikeId, equals(original.bikeId));
        expect(updated.status, equals(original.status));
        expect(updated.conditionReviewed, equals(original.conditionReviewed));
        expect(updated.reviewedAt, equals(original.reviewedAt));
      });
    });

    group('Round-trip serialization', () {
      test('fromFirestore and toFirestore are consistent', () async {
        final allocatedAt = DateTime(2024, 5, 10);
        final reviewedAt = DateTime(2024, 5, 14);
        final originalAllocation = Allocation(
          id: 'alloc-123',
          employeeId: 'emp-123',
          userName: 'John Doe',
          bikeId: 'BIKE-001',
          allocatedAt: allocatedAt,
          status: 'returned',
          conditionReviewed: true,
          condition: 'damaged',
          reviewedAt: reviewedAt,
        );

        final firestoreData = originalAllocation.toFirestore();
        final mockDoc = await createMockDoc(
          firestoreData,
          originalAllocation.id,
        );
        final deserializedAllocation = Allocation.fromFirestore(mockDoc);

        expect(
          deserializedAllocation.employeeId,
          equals(originalAllocation.employeeId),
        );
        expect(
          deserializedAllocation.userName,
          equals(originalAllocation.userName),
        );
        expect(
          deserializedAllocation.bikeId,
          equals(originalAllocation.bikeId),
        );
        expect(
          deserializedAllocation.status,
          equals(originalAllocation.status),
        );
        expect(
          deserializedAllocation.condition,
          equals(originalAllocation.condition),
        );
      });
    });
  });
}
