import 'package:flutter/material.dart';
import 'package:cyclot_v1/models/allocation_model.dart';
import 'package:intl/intl.dart';

class ActiveAllocationCard extends StatelessWidget {
  final Allocation allocation;

  const ActiveAllocationCard({super.key, required this.allocation});

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
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
            _buildInfoRow(context, 'Bike ID', allocation.bikeId),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              'Allocated At',
              _formatDateTime(allocation.allocatedAt),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(context, 'Status', 'Active'),
          ],
        ),
      ),
    );
  }
}
