import 'package:cyclot_v1/core/extensions/context_extensions.dart';
import 'package:cyclot_v1/models/user_model.dart';
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
  final User _auth = FirebaseAuth.instance.currentUser!;
  final Map<String, bool> _requestingBikes = {};
  late Future<AppUser> user;
  late Stream<QuerySnapshot> _activeAllocationStream;

  @override
  void initState() {
    super.initState();
    user = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.uid)
        .get()
        .then((doc) => AppUser.fromFirestore(doc));

    _activeAllocationStream = _firestore
        .collection('allocations')
        .where('employeeId', isEqualTo: _auth.uid)
        .where('returned', isEqualTo: false)
        .snapshots();
  }

  Future<void> _requestBike(String docId, String bikeId) async {
    setState(() => _requestingBikes[docId] = true);

    try {
      final existingAllocation = await _firestore
          .collection('allocations')
          .where('employeeId', isEqualTo: _auth.uid)
          .where('returned', isEqualTo: false)
          .get();

      if (existingAllocation.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'You already have a bike allocated. Please return it first.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      await _firestore.collection('allocations').add({
        'bikeId': bikeId,
        'bikeDocId': docId,
        'employeeId': _auth.uid,
        'status': 'active',
        'returned': false,
        'requestedAt': DateTime.now(),
        'employeeName': (await user).name,
      });

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
      backgroundColor: context.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Available Bikes',
          style: context.appBarTheme.titleTextStyle,
        ),
        backgroundColor: context.appBarTheme.backgroundColor,
        centerTitle: true,
        elevation: 0,
        leading: BackButton(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _activeAllocationStream,
        builder: (context, allocationSnapshot) {
          final hasActiveAllocation =
              allocationSnapshot.data?.docs.isNotEmpty ?? false;

          return StreamBuilder<QuerySnapshot>(
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

              return Column(
                children: [
                  if (hasActiveAllocation)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      color: Colors.orange.shade100,
                      child: const Text(
                        'You already have a bike allocated. Please return it before requesting another.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: bikes.length,
                      itemBuilder: (context, index) {
                        final bike = bikes[index];
                        final docId = bike.id;
                        final bikeId = bike['bikeId'] as String;
                        final isRequesting = _requestingBikes[docId] ?? false;

                        return Card(
                          color: context.cardTheme.color,
                          elevation: context.cardTheme.elevation,
                          shape: context.cardTheme.shape,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Bike ID: $bikeId',
                                            style:
                                                context.textTheme.titleMedium,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Color: ${bike['color'] ?? 'Unknown'}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Status: ${bike['isDamaged'] ? 'Damaged' : 'Available'}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
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
                                    onPressed:
                                        (isRequesting || hasActiveAllocation)
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
                                        : Text(
                                            hasActiveAllocation
                                                ? 'Request Bike'
                                                : 'Request Bike',
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
