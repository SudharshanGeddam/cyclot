import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cyclot_v1/screens/role_router_screen.dart';
import 'package:cyclot_v1/screens/employee_home_screen.dart';
import 'package:cyclot_v1/screens/security_home_screen.dart';
import 'package:cyclot_v1/screens/admin_dashboard_screen.dart';
import 'package:cyclot_v1/repositories/user_repository.dart';
import 'package:cyclot_v1/repositories/bike_repository.dart';
import 'package:cyclot_v1/repositories/allocation_repository.dart';
import 'package:cyclot_v1/repositories/notification_repository.dart';
import 'package:cyclot_v1/services/auth_service.dart';
import 'package:cyclot_v1/core/constants.dart';
import 'package:mockito/mockito.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late UserRepository userRepository;
  late BikeRepository bikeRepository;
  late AllocationRepository allocationRepository;
  late NotificationRepository notificationRepository;
  late MockAuthService mockAuthService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    userRepository = UserRepository(firestore: fakeFirestore);
    bikeRepository = BikeRepository(firestore: fakeFirestore);
    allocationRepository = AllocationRepository(firestore: fakeFirestore);
    notificationRepository = NotificationRepository(firestore: fakeFirestore);
    mockAuthService = MockAuthService();
  });

  Widget createWidgetUnderTest(String uid) {
    return MaterialApp(
      home: RoleRouterScreen(
        uid: uid,
        userRepository: userRepository,
        authService: mockAuthService,
        bikeRepository: bikeRepository,
        allocationRepository: allocationRepository,
        notificationRepository: notificationRepository,
      ),
    );
  }

  group('RoleRouterScreen', () {
    testWidgets('routes to EmployeeHomeScreen for employee role', (tester) async {
      await fakeFirestore.collection(FirestoreCollections.users).doc('uid_emp').set({
        FirestoreFields.role: UserRoles.employee,
      });

      await tester.pumpWidget(createWidgetUnderTest('uid_emp'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(EmployeeHomeScreen), findsOneWidget);
    });

    testWidgets('routes to SecurityHomeScreen for security role', (tester) async {
      await fakeFirestore.collection(FirestoreCollections.users).doc('uid_sec').set({
        FirestoreFields.role: UserRoles.security,
      });

      await tester.pumpWidget(createWidgetUnderTest('uid_sec'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SecurityHomeScreen), findsOneWidget);
    });

    testWidgets('routes to AdminDashboardScreen for admin role', (tester) async {
      await fakeFirestore.collection(FirestoreCollections.users).doc('uid_adm').set({
        FirestoreFields.role: UserRoles.admin,
      });

      await tester.pumpWidget(createWidgetUnderTest('uid_adm'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AdminDashboardScreen), findsOneWidget);
    });

    testWidgets('routes to UnknownRoleScreen for missing or invalid role', (tester) async {
      await fakeFirestore.collection(FirestoreCollections.users).doc('uid_unk').set({
        FirestoreFields.role: 'some_unknown_role',
      });

      await tester.pumpWidget(createWidgetUnderTest('uid_unk'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Unknown role: some_unknown_role'), findsOneWidget);
    });
  });
}
