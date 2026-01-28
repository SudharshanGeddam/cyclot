import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EmployeeReturnBikeScreen extends StatefulWidget {
  const EmployeeReturnBikeScreen({super.key});

  @override
  State<EmployeeReturnBikeScreen> createState() =>
      _EmployeeReturnBikeScreenState();
}

class _EmployeeReturnBikeScreenState extends State<EmployeeReturnBikeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isReturning = false;
  late String _currentUserUid;

  @override
  void initState() {
    super.initState();
    _currentUserUid = _auth.currentUser?.uid ?? '';
  }

  /// Fetch the current active allocation for the employee
  Future<DocumentSnapshot?> _getActiveAllocation() async {
    try {
      final query = await _firestore
          .collection('allocations')
          .where('employeeId', isEqualTo: _currentUserUid)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      return query.docs.isNotEmpty ? query.docs.first : null;
    } catch (e) {
      // Silently return null on error
      return null;
    }
  }

  /// Return the bike
  /// [bikeId] is the bike identifier field stored in the allocation
  Future<void> _returnBike(String allocationId, String bikeId) async {
    setState(() => _isReturning = true);

    try {
      // Update allocation status to returned
      // Note: Only security can update the bike's isAllocated status per Firestore rules
      await _firestore.collection('allocations').doc(allocationId).update({
        'status': 'returned',
        'returned': true,
        'returnedAt': DateTime.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bike returned successfully!'),
            duration: Duration(seconds: 2),
          ),
        );

        // Optional: Navigate back after successful return
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        String errorMessage = 'Error returning bike';
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
      setState(() => _isReturning = false);
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final dateTime = timestamp.toDate();
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Return Bike'), elevation: 0),
      body: FutureBuilder<DocumentSnapshot?>(
        future: _getActiveAllocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allocation = snapshot.data;

          if (allocation == null || !allocation.exists) {
            return const Center(
              child: Text('You do not have an active bike allocation.'),
            );
          }

          final allocationId = allocation.id;
          final bikeId = allocation['bikeId'] as String? ?? '';
          final requestedAt = allocation['requestedAt'] as Timestamp?;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Allocation',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Bike ID', bikeId),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Requested At',
                          _formatTimestamp(requestedAt),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Status', 'Active'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isReturning
                        ? null
                        : () => _returnBike(allocationId, bikeId),
                    icon: _isReturning
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle),
                    label: const Text('Return Bike'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Confirm your bike return. This action cannot be undone.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
