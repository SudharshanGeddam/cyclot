import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cyclot_v1/screens/admin_dashboard_screen.dart';
import 'package:cyclot_v1/screens/employee_home_screen.dart';
import 'package:cyclot_v1/screens/security_home_screen.dart';
import 'package:flutter/material.dart';

class RoleRouterScreen extends StatefulWidget {
  final String uid;

  const RoleRouterScreen({required this.uid, super.key});

  @override
  State<RoleRouterScreen> createState() => _RoleRouterScreenState();
}

class _RoleRouterScreenState extends State<RoleRouterScreen> {
  late Future<Widget> _routeFuture;

  @override
  void initState() {
    super.initState();
    _routeFuture = _fetchRoleAndRoute();
  }

  Future<Widget> _fetchRoleAndRoute() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      if (!doc.exists) {
        throw Exception('User document not found in Firestore');
      }

      final role = doc.data()?['role'] as String?;
      if (role == null) {
        throw Exception('Role field missing in user document');
      }

      return switch (role) {
        'employee' => EmployeeHomeScreen(uid: widget.uid),
        'security' => SecurityHomeScreen(uid: widget.uid),
        'admin' => AdminDashboardScreen(uid: widget.uid),
        _ => _UnknownRoleScreen(uid: widget.uid, role: role),
      };
    } on FirebaseException catch (e) {
      return _ErrorScreen(
        error: 'Firebase Error: ${e.message}',
        uid: widget.uid,
      );
    } catch (e) {
      return _ErrorScreen(error: 'Error: $e', uid: widget.uid);
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
