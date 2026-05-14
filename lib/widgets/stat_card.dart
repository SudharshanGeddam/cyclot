// Flutter imports:
import 'package:flutter/material.dart';

/// Reusable stat card for displaying key metrics
class StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color? backgroundColor;
  final Color? textColor;

  const StatCard({
    required this.label,
    required this.value,
    this.backgroundColor,
    this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor ?? Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
