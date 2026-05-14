// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:cyclot_v1/core/constants.dart';
import 'package:cyclot_v1/core/helpers/error_helper.dart';
import 'package:cyclot_v1/repositories/user_repository.dart';
import 'package:cyclot_v1/repositories/bike_repository.dart';
import 'package:cyclot_v1/repositories/allocation_repository.dart';
import 'package:cyclot_v1/repositories/notification_repository.dart';
import 'package:cyclot_v1/services/auth_service.dart';
import 'package:cyclot_v1/screens/admin_dashboard_screen.dart';
import 'package:cyclot_v1/screens/employee_home_screen.dart';
import 'package:cyclot_v1/screens/security_home_screen.dart';

class RoleRouterScreen extends StatefulWidget {
  final String uid;
  final UserRepository? userRepository;
  final AuthService? authService;
  final BikeRepository? bikeRepository;
  final AllocationRepository? allocationRepository;
  final NotificationRepository? notificationRepository;

  const RoleRouterScreen({
    required this.uid,
    this.userRepository,
    this.authService,
    this.bikeRepository,
    this.allocationRepository,
    this.notificationRepository,
    super.key,
  });

  @override
  State<RoleRouterScreen> createState() => _RoleRouterScreenState();
}

class _RoleRouterScreenState extends State<RoleRouterScreen> {
  late Future<Widget> _routeFuture;
  late final UserRepository _userRepository;

  @override
  void initState() {
    super.initState();
    _userRepository = widget.userRepository ?? UserRepository();
    _routeFuture = _fetchRoleAndRoute();
  }

  Future<Widget> _fetchRoleAndRoute() async {
    try {
      final role = await _userRepository.getUserRole(widget.uid);

      if (role == null) {
        throw Exception('Role field missing in user document');
      }

      return switch (role) {
        UserRoles.employee => EmployeeHomeScreen(
            uid: widget.uid,
            userRepository: widget.userRepository,
            authService: widget.authService,
            notificationRepository: widget.notificationRepository,
          ),
        UserRoles.security => SecurityHomeScreen(
            uid: widget.uid,
            userRepository: widget.userRepository,
            bikeRepository: widget.bikeRepository,
          ),
        UserRoles.admin => AdminDashboardScreen(
            uid: widget.uid,
            authService: widget.authService,
            bikeRepository: widget.bikeRepository,
            allocationRepository: widget.allocationRepository,
          ),
        _ => _UnknownRoleScreen(uid: widget.uid, role: role),
      };
    } catch (e) {
      return _ErrorScreen(
        error: 'Error: ${ErrorHelper.cleanError(e)}',
        uid: widget.uid,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _routeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        return snapshot.data ??
            const Scaffold(body: Center(child: Text('Unknown error')));
      },
    );
  }
}

class _UnknownRoleScreen extends StatelessWidget {
  final String uid;
  final String role;

  const _UnknownRoleScreen({required this.uid, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unknown Role')),
      body: Center(child: Text('Unknown role: $role')),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String error;
  final String uid;

  const _ErrorScreen({required this.error, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error loading role:\n$error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Return to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
