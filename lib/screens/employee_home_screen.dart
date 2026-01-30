import 'package:cyclot_v1/core/extensions/context_extensions.dart';
import 'package:cyclot_v1/models/user_model.dart';
import 'package:cyclot_v1/screens/employee_available_bikes_screen.dart';
import 'package:cyclot_v1/screens/employee_notifications_screen.dart';
import 'package:cyclot_v1/screens/employee_return_bike_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmployeeHomeScreen extends StatefulWidget {
  final String uid;
  const EmployeeHomeScreen({required this.uid, super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  late Future<AppUser> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get()
        .then((doc) => AppUser.fromFirestore(doc));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackground,
      appBar: AppBar(
        title: Text('Home', style: context.appBarTheme.titleTextStyle),
        backgroundColor: context.appBarTheme.backgroundColor,
        centerTitle: true,
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('employeeId', isEqualTo: widget.uid)
                .where('read', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data?.docs.length ?? 0;
              return IconButton(
                icon: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text('$unreadCount'),
                  child: const Icon(Icons.notifications, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const EmployeeNotificationsScreen(),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
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
      body: FutureBuilder<AppUser>(
        future: userFuture,
        builder: (context, snapshot) {
          final userName = snapshot.data?.name ?? 'Employee';
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Welcome, '),
                      Text('$userName!', style: context.textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Lottie.asset(
                    'assets/lotties/employee_home_animation.json',
                    width: double.infinity,
                    height: 500,
                    fit: BoxFit.fitWidth,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      side: BorderSide(color: Colors.purpleAccent),
                    ),
                    child: Text('View Available Bikes'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const EmployeeAvailableBikesScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      side: BorderSide(color: Colors.purpleAccent),
                    ),
                    child: Text('Return Bike'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const EmployeeReturnBikeScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
