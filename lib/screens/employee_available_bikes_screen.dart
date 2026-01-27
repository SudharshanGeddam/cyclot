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

  @override
  void initState() {
    super.initState();
    _currentUserUid = _auth.currentUser?.uid ?? '';
  }

  /// Check if the current user has an active allocation
  Future<bool> _hasActiveAllocation() async {
    try {
      final query = await _firestore
          .collection('allocations')
          .where('employeeId', isEqualTo: _currentUserUid)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking allocation: $e')),
        );
      }
      return false;
    }
  }

  /// Request a bike for the current user
  Future<void> _requestBike(String bikeId) async {
    setState(() => _requestingBikes[bikeId] = true);

    try {
      // Check if an active allocation already exists
      final hasActive = await _hasActiveAllocation();

      if (hasActive) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'You already have an active bike allocation. '
                'Please return it before requesting another.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
        setState(() => _requestingBikes[bikeId] = false);
        return;
      }

      // Create allocation document
      await _firestore.collection('allocations').add({
        'bikeId': bikeId,
        'employeeId': _currentUserUid,
        'status': 'active',
        'requestedAt': FieldValue.serverTimestamp(),
      });

      // Update bike as allocated
      await _firestore.collection('bikes').doc(bikeId).update({
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
      setState(() => _requestingBikes[bikeId] = false);
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
              final bikeId = bike.id;
              final isRequesting = _requestingBikes[bikeId] ?? false;

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
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isRequesting
                              ? null
                              : () => _requestBike(bikeId),
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
