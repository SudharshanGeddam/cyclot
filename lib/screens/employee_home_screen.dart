import 'package:cyclot_v1/screens/employee_available_bikes_screen.dart';
import 'package:cyclot_v1/screens/employee_return_bike_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmployeeHomeScreen extends StatelessWidget {
  final String uid;
  const EmployeeHomeScreen({required this.uid, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Home'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome, Employee!'),
            const SizedBox(height: 16),
            TextButton(
              child: Text('View Available Bikes'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EmployeeAvailableBikesScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              child: Text('Return Bike'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EmployeeReturnBikeScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
