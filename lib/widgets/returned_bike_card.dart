// Flutter imports:
import 'package:flutter/material.dart';

/// Reusable returned bike card for security screen
class ReturnedBikeCard extends StatelessWidget {
  final String bikeId;
  final String userName;
  final bool isPending;
  final bool isProcessing;
  final VoidCallback? onMarkDamaged;
  final VoidCallback? onMarkUndamaged;

  const ReturnedBikeCard({
    required this.bikeId,
    required this.userName,
    required this.isPending,
    required this.isProcessing,
    this.onMarkDamaged,
    this.onMarkUndamaged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
                  child: const Icon(Icons.pedal_bike, color: Colors.blue),
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
                        'Returned by: $userName',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                // Status chip
                Chip(
                  label: const Text('Pending Review'),
                  backgroundColor: Colors.orange.shade100,
                  labelStyle: const TextStyle(color: Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: isProcessing ? null : onMarkUndamaged,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Undamaged'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: isProcessing ? null : onMarkDamaged,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Damaged'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable confirmation dialog for bike review actions
class BikeReviewConfirmationDialog extends StatelessWidget {
  final String bikeId;
  final bool isDamaged;
  final VoidCallback onConfirm;

  const BikeReviewConfirmationDialog({
    required this.bikeId,
    required this.isDamaged,
    required this.onConfirm,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Bike Review'),
      content: Text(
        isDamaged
            ? 'This will mark bike $bikeId as damaged and notify the employee.'
            : 'This will mark bike $bikeId as undamaged and notify the employee.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: Text(isDamaged ? 'Mark Damaged' : 'Mark Undamaged'),
        ),
      ],
    );
  }
}
