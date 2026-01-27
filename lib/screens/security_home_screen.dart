import 'package:cyclot_v1/screens/security_add_bikes_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Welcome, Security!')),
          const SizedBox(height: 16),
          _buildChipsWidget(),
        ],
      ),
    );
  }
}

Widget _buildChipsWidget() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Chip(
            label: Text('Available Bikes'),
            backgroundColor: Colors.green.shade100,
          ),
          const SizedBox(width: 8),
          Chip(
            label: Text('Allocated Bikes'),
            backgroundColor: Colors.red.shade100,
          ),
          const SizedBox(width: 8),
          Chip(
            label: Text('Returned Bikes'),
            backgroundColor: Colors.blue.shade100,
          ),
          const SizedBox(width: 8),
          Chip(
            label: Text('Damaged Bikes'),
            backgroundColor: Colors.yellow.shade100,
          ),
        ],
      ),
    ),
  );
}
