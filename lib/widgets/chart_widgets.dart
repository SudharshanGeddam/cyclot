// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fl_chart/fl_chart.dart';

/// Reusable allocation status pie chart widget
class AllocationStatusChart extends StatelessWidget {
  final int allocatedBikes;
  final int availableBikes;

  const AllocationStatusChart({
    required this.allocatedBikes,
    required this.availableBikes,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final total = allocatedBikes + availableBikes;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Allocation Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (total == 0)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No bikes available'),
                ),
              )
            else
              SizedBox(
                height: 150,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: allocatedBikes.toDouble(),
                        color: Colors.orange,
                        title: 'Allocated\n$allocatedBikes',
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        value: availableBikes.toDouble(),
                        color: Colors.green,
                        title: 'Available\n$availableBikes',
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Legend(
                  color: Colors.orange,
                  label: 'Allocated ($allocatedBikes)',
                ),
                _Legend(
                  color: Colors.green,
                  label: 'Available ($availableBikes)',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable bike condition pie chart widget
class BikeConditionChart extends StatelessWidget {
  final int damagedBikes;
  final int undamagedBikes;

  const BikeConditionChart({
    required this.damagedBikes,
    required this.undamagedBikes,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final total = damagedBikes + undamagedBikes;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bike Condition',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (total == 0)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No bikes available'),
                ),
              )
            else
              SizedBox(
                height: 150,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: undamagedBikes.toDouble(),
                        color: Colors.green,
                        title: 'Undamaged\n$undamagedBikes',
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        value: damagedBikes.toDouble(),
                        color: Colors.red,
                        title: 'Damaged\n$damagedBikes',
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Legend(
                  color: Colors.green,
                  label: 'Undamaged ($undamagedBikes)',
                ),
                _Legend(color: Colors.red, label: 'Damaged ($damagedBikes)'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper widget for chart legends
class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
