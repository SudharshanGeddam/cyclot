import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SecurityReturnedBikesScreen extends StatefulWidget {
  const SecurityReturnedBikesScreen({super.key});

  @override
  State<SecurityReturnedBikesScreen> createState() =>
      _SecurityReturnedBikesScreenState();
}

class _SecurityReturnedBikesScreenState
    extends State<SecurityReturnedBikesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, bool> _processingAllocations = {};

  Future<void> _reviewBike({
    required String allocationId,
    required String bikeId,
    required String employeeId,
    required bool isDamaged,
  }) async {
    setState(() => _processingAllocations[allocationId] = true);

    try {
      final bikeQuery = await _firestore
          .collection('bikes')
          .where('bikeId', isEqualTo: bikeId)
          .limit(1)
          .get();

      if (bikeQuery.docs.isEmpty) {
        throw Exception('Bike not found in database');
      }

      final bikeDocId = bikeQuery.docs.first.id;
      final condition = isDamaged ? 'damaged' : 'undamaged';

      final batch = _firestore.batch();

      batch.update(_firestore.collection('bikes').doc(bikeDocId), {
        'isDamaged': isDamaged,
        'isAllocated': false,
      });

      batch.update(_firestore.collection('allocations').doc(allocationId), {
        'conditionReviewed': true,
        'condition': condition,
        'reviewedAt': DateTime.now(),
      });

      await batch.commit();

      try {
        await _firestore.collection('notifications').add({
          'employeeId': employeeId,
          'bikeId': bikeId,
          'message': isDamaged
              ? 'Your returned bike ($bikeId) was marked as damaged. Please contact administration.'
              : 'Your returned bike ($bikeId) has been reviewed and accepted. Thank you!',
          'createdAt': DateTime.now(),
          'read': false,
        });
      } catch (e) {
        debugPrint('Failed to create notification: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isDamaged
                  ? 'Bike marked as damaged. Employee notified.'
                  : 'Bike marked as undamaged and available.',
            ),
            backgroundColor: isDamaged ? Colors.orange : Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        String errorMessage = 'Error processing bike';
        if (e.code == 'permission-denied') {
          errorMessage = 'Permission denied. Contact administrator.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _processingAllocations[allocationId] = false);
    }
  }

  Future<void> _showConfirmationDialog({
    required String allocationId,
    required String bikeId,
    required String employeeId,
    required bool isDamaged,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isDamaged ? 'Mark as Damaged?' : 'Mark as Undamaged?'),
        content: Text(
          isDamaged
              ? 'This will mark bike $bikeId as damaged and notify the employee.'
              : 'This will mark bike $bikeId as undamaged and make it available for allocation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: isDamaged ? Colors.red : Colors.green,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _reviewBike(
        allocationId: allocationId,
        bikeId: bikeId,
        employeeId: employeeId,
        isDamaged: isDamaged,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Returned Bikes Review'),
        elevation: 0,
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.white,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('allocations')
            .where('status', isEqualTo: 'returned')
            .where('conditionReviewed', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final allocations = snapshot.data?.docs ?? [];

          if (allocations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No returned bikes pending review',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allocations.length,
            itemBuilder: (context, index) {
              final allocation = allocations[index];
              final allocationId = allocation.id;
              final bikeId = allocation['bikeId'] as String? ?? 'Unknown';
              final employeeId =
                  allocation['employeeId'] as String? ?? 'Unknown';
              final employeeName =
                  allocation['employeeName'] as String? ?? 'Unknown';
              final isProcessing =
                  _processingAllocations[allocationId] ?? false;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with bike icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.pedal_bike,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bikeId,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Returned by: $employeeName',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          // Status chip
                          Chip(
                            label: const Text('Pending Review'),
                            backgroundColor: Colors.orange.shade100,
                            labelStyle: TextStyle(
                              color: Colors.orange.shade800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      // Info rows
                      _buildInfoRow(
                        context,
                        'Employee ID',
                        employeeId,
                        Icons.person,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        context,
                        'Bike ID',
                        bikeId,
                        Icons.confirmation_number,
                      ),
                      const SizedBox(height: 16),
                      // Action buttons
                      if (isProcessing)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showConfirmationDialog(
                                  allocationId: allocationId,
                                  bikeId: bikeId,
                                  employeeId: employeeId,
                                  isDamaged: true,
                                ),
                                icon: const Icon(
                                  Icons.warning,
                                  color: Colors.red,
                                ),
                                label: const Text('Mark Damaged'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => _showConfirmationDialog(
                                  allocationId: allocationId,
                                  bikeId: bikeId,
                                  employeeId: employeeId,
                                  isDamaged: false,
                                ),
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Mark Undamaged'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
