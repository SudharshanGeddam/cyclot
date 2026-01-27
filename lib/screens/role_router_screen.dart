import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cyclot_v1/screens/security_add_bikes_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Placeholder home screens for each role
class EmployeeHomeScreen extends StatelessWidget {
  final String uid;
  const EmployeeHomeScreen({required this.uid, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome, Employee!'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecurityHomeScreen extends StatelessWidget {
  final String uid;
  const SecurityHomeScreen({required this.uid, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Security Home'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () async {
            await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              }
          }, icon: Icon(Icons.logout))
        ],),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          // Navigate to add bikes screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SecurityAddBikesScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('Welcome, Security!'),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class AdminHomeScreen extends StatelessWidget {
  final String uid;
  const AdminHomeScreen({required this.uid, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome, Admin!'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

/// RoleRouterScreen: Fetches user role from Firestore and routes accordingly.
/// This widget ensures role-based navigation happens after auth and Firestore validation.
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

  /// Fetches role from Firestore users/{uid} document
  /// Throws FirebaseException if document doesn't exist (permission error, no user data, etc.)
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

      // Route based on role
      return switch (role) {
        'employee' => EmployeeHomeScreen(uid: widget.uid),
        'security' => SecurityHomeScreen(uid: widget.uid),
        'admin' => AdminHomeScreen(uid: widget.uid),
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

/// Fallback screen for unknown roles
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

/// Error screen for Firestore access issues
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
                // Retry by popping and returning to login
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
