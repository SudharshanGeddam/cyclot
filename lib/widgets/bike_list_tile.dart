// Flutter imports:
import 'package:flutter/material.dart';

/// Reusable bike list tile for displaying bike information
class BikeListTile extends StatelessWidget {
  final String bikeId;
  final String color;
  final bool isDamaged;
  final bool isAllocated;
  final VoidCallback? onTap;
  final Widget? trailing;

  const BikeListTile({
    required this.bikeId,
    required this.color,
    required this.isDamaged,
    required this.isAllocated,
    this.onTap,
    this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.pedal_bike,
          color: isDamaged ? Colors.red : Colors.blue,
        ),
        title: Text('Bike ID: $bikeId'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Color: $color'),
            Text(
              'Status: ${isDamaged
                  ? 'Damaged'
                  : isAllocated
                  ? 'Allocated'
                  : 'Available'}',
              style: TextStyle(
                color: isDamaged
                    ? Colors.red
                    : isAllocated
                    ? Colors.orange
                    : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
