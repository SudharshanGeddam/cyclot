// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:cyclot_v1/models/user_model.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('AppUser Model', () {
    group('fromFirestore', () {
      test('parses user data correctly', () async {
        final now = DateTime.now();
        final mockDoc = await createMockDoc({
          'name': 'John Doe',
          'email': 'john@example.com',
          'role': 'employee',
          'createdAt': Timestamp.fromDate(now),
        }, 'user-123');

        final user = AppUser.fromFirestore(mockDoc);

        expect(user.uid, equals('user-123'));
        expect(user.name, equals('John Doe'));
        expect(user.email, equals('john@example.com'));
        expect(user.role, equals('employee'));
        expect(user.createdAt.year, equals(now.year));
      });

      test('defaults role to employee when missing', () async {
        final mockDoc = await createMockDoc({
          'name': 'Jane Doe',
          'email': 'jane@example.com',
          // role is missing
          'createdAt': Timestamp.fromDate(DateTime.now()),
        }, 'user-456');

        final user = AppUser.fromFirestore(mockDoc);

        expect(user.role, equals('employee'));
      });

      test('defaults empty strings when fields are missing', () async {
        final mockDoc = await createMockDoc({}, 'user-789');

        final user = AppUser.fromFirestore(mockDoc);

        expect(user.name, equals(''));
        expect(user.email, equals(''));
        expect(user.role, equals('employee'));
      });

      test('handles null timestamp gracefully', () async {
        final mockDoc = await createMockDoc({
          'name': 'Test User',
          'email': 'test@example.com',
          'role': 'admin',
          // createdAt is missing
        }, 'user-999');

        final user = AppUser.fromFirestore(mockDoc);

        expect(user.createdAt, isA<DateTime>());
      });

      test('parses security and admin roles', () async {
        final securityDoc = await createMockDoc({
          'name': 'Security Officer',
          'email': 'security@example.com',
          'role': 'security',
          'createdAt': Timestamp.fromDate(DateTime.now()),
        }, 'sec-123');

        final adminDoc = await createMockDoc({
          'name': 'Admin User',
          'email': 'admin@example.com',
          'role': 'admin',
          'createdAt': Timestamp.fromDate(DateTime.now()),
        }, 'admin-456');

        expect(AppUser.fromFirestore(securityDoc).role, equals('security'));
        expect(AppUser.fromFirestore(adminDoc).role, equals('admin'));
      });
    });

    group('toFirestore', () {
      test('serializes user to Firestore format', () {
        final now = DateTime.now();
        final user = AppUser(
          uid: 'user-123',
          name: 'John Doe',
          email: 'john@example.com',
          role: 'employee',
          createdAt: now,
        );

        final data = user.toFirestore();

        expect(data['name'], equals('John Doe'));
        expect(data['email'], equals('john@example.com'));
        expect(data['role'], equals('employee'));
        expect(data['createdAt'], isA<Timestamp>());
      });

      test('does not include uid in toFirestore output', () {
        final user = AppUser(
          uid: 'user-123',
          name: 'Test User',
          email: 'test@example.com',
          role: 'employee',
          createdAt: DateTime.now(),
        );

        final data = user.toFirestore();

        expect(data.containsKey('uid'), isFalse);
      });

      test('converts DateTime to Timestamp', () {
        final specificDate = DateTime(2024, 5, 14, 10, 30, 0);
        final user = AppUser(
          uid: 'user-123',
          name: 'Test User',
          email: 'test@example.com',
          role: 'employee',
          createdAt: specificDate,
        );

        final data = user.toFirestore();
        final timestamp = data['createdAt'] as Timestamp;

        expect(timestamp.toDate().year, equals(2024));
        expect(timestamp.toDate().month, equals(5));
        expect(timestamp.toDate().day, equals(14));
      });
    });

    group('Round-trip serialization', () {
      test('fromFirestore and toFirestore are consistent', () async {
        final originalUser = AppUser(
          uid: 'user-123',
          name: 'John Doe',
          email: 'john@example.com',
          role: 'security',
          createdAt: DateTime(2024, 5, 14),
        );

        final firestoreData = originalUser.toFirestore();
        final mockDoc = await createMockDoc(
          firestoreData,
          originalUser.uid,
        );
        final deserializedUser = AppUser.fromFirestore(mockDoc);

        expect(deserializedUser.name, equals(originalUser.name));
        expect(deserializedUser.email, equals(originalUser.email));
        expect(deserializedUser.role, equals(originalUser.role));
        expect(deserializedUser.uid, equals(originalUser.uid));
      });
    });
  });
}
