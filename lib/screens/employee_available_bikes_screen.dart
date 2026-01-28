import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmployeeAvailableBikesScreen extends StatefulWidget {
  const EmployeeAvailableBikesScreen({super.key});

  @override
  State<EmployeeAvailableBikesScreen> createState() =>
      _EmployeeAvailableBikesScreenState();
}

class _EmployeeAvailableBikesScreenState
    extends State<EmployeeAvailableBikesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, bool> _requestingBikes = {};
  late String _currentUserUid;
  late String currentUserName;

  @override
  void initState() {
    super.initState();
    _currentUserUid = _auth.currentUser?.uid ?? '';
    getUserName();
  }

  /// Fetch the current user's name
  Future<void> getUserName() async {
    try {
      final userDoc = await _firestore
          .collection('employees')
          .doc(_currentUserUid)
          .get();
      setState(() {
        currentUserName = userDoc['name'] ?? 'Unknown';
      });
    } catch (e) {
      setState(() {
        currentUserName = 'Unknown';
      });
    }
  }

  /// Request a bike for the current user
  /// [docId] is the Firestore document ID, [bikeId] is the bike identifier field
  Future<void> _requestBike(String docId, String bikeId) async {
    setState(() => _requestingBikes[docId] = true);

    try {
      // Create allocation document directly
      // The Firestore rules and database constraints will prevent duplicates
      await _firestore.collection('allocations').add({
        'bikeId': bikeId,
        'bikeDocId': docId, // Store the actual Firestore document ID
        'employeeId': _currentUserUid,
        'status': 'active',
        'returned': false,
        'requestedAt': DateTime.now(),
        'employeeName': currentUserName,
      });

      // Update bike as allocated using the actual Firestore document ID
      await _firestore.collection('bikes').doc(docId).update({
        'isAllocated': true,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bike requested successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        String errorMessage = 'Error requesting bike';
        if (e.code == 'permission-denied') {
          errorMessage = 'Permission denied. Contact administrator.';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unexpected error: $e')));
      }
    } finally {
      setState(() => _requestingBikes[docId] = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Bikes'), elevation: 0),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('bikes')
            .where('isAllocated', isEqualTo: false)
            .where('isDamaged', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final bikes = snapshot.data?.docs ?? [];

          if (bikes.isEmpty) {
            return const Center(
              child: Text('No available bikes at the moment.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bikes.length,
            itemBuilder: (context, index) {
              final bike = bikes[index];
              final docId = bike.id; // Firestore document ID
              final bikeId =
                  bike['bikeId'] as String; // Field value for display
              final isRequesting = _requestingBikes[docId] ?? false;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bike ID: $bikeId',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Color: ${bike['color'] ?? 'Unknown'}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Status: ${bike['isDamaged'] ? 'Damaged' : 'Available'}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: isRequesting
                              ? null
                              : () => _requestBike(docId, bikeId),
                          child: isRequesting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Request Bike'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
