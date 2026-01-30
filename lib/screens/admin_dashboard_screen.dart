import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardStats {
  final int totalBikes;
  final int allocatedBikes;
  final int availableBikes;
  final int damagedBikes;
  final int undamagedBikes;
  final int activeAllocations;
  final int returnedAllocations;

  DashboardStats({
    required this.totalBikes,
    required this.allocatedBikes,
    required this.availableBikes,
    required this.damagedBikes,
    required this.undamagedBikes,
    required this.activeAllocations,
    required this.returnedAllocations,
  });

  factory DashboardStats.empty() {
    return DashboardStats(
      totalBikes: 0,
      allocatedBikes: 0,
      availableBikes: 0,
      damagedBikes: 0,
      undamagedBikes: 0,
      activeAllocations: 0,
      returnedAllocations: 0,
    );
  }
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key, required String uid});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DashboardStats> _fetchDashboardStats() async {
    final bikesSnapshot = await _firestore.collection('bikes').get();
    final bikes = bikesSnapshot.docs;

    final totalBikes = bikes.length;
    final allocatedBikes = bikes.where((doc) {
      final data = doc.data();
      return data.containsKey('isAllocated') && data['isAllocated'] == true;
    }).length;
    final availableBikes = totalBikes - allocatedBikes;
    final damagedBikes = bikes.where((doc) {
      final data = doc.data();
      return data.containsKey('isDamaged') && data['isDamaged'] == true;
    }).length;
    final undamagedBikes = totalBikes - damagedBikes;

    final allocationsSnapshot = await _firestore
        .collection('allocations')
        .get();
    final allocations = allocationsSnapshot.docs;

    final activeAllocations = allocations.where((doc) {
      final data = doc.data();
      return data.containsKey('status') && data['status'] == 'active';
    }).length;
    final returnedAllocations = allocations.where((doc) {
      final data = doc.data();
      return data.containsKey('status') && data['status'] == 'returned';
    }).length;

    return DashboardStats(
      totalBikes: totalBikes,
      allocatedBikes: allocatedBikes,
      availableBikes: availableBikes,
      damagedBikes: damagedBikes,
      undamagedBikes: undamagedBikes,
      activeAllocations: activeAllocations,
      returnedAllocations: returnedAllocations,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: FutureBuilder<DashboardStats>(
        future: _fetchDashboardStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading dashboard...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final stats = snapshot.data ?? DashboardStats.empty();

          if (stats.totalBikes == 0) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No data available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add bikes to see dashboard statistics',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(stats),
                  const SizedBox(height: 24),

                  _buildChartCard(
                    title: 'Bike Allocation Status',
                    subtitle: 'Allocated vs Available',
                    child: _buildAllocationPieChart(stats),
                  ),
                  const SizedBox(height: 16),

                  _buildChartCard(
                    title: 'Bike Condition Status',
                    subtitle: 'Damaged vs Undamaged',
                    child: _buildDamagePieChart(stats),
                  ),
                  const SizedBox(height: 16),

                  // Allocations Overview Chart
                  _buildChartCard(
                    title: 'Allocations Overview',
                    subtitle: 'Active vs Returned',
                    child: _buildAllocationsBarChart(stats),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build summary cards row
  Widget _buildSummaryCards(DashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Total Bikes',
              stats.totalBikes.toString(),
              Icons.pedal_bike,
              Colors.blue,
            ),
            _buildStatCard(
              'Allocated',
              stats.allocatedBikes.toString(),
              Icons.person,
              Colors.orange,
            ),
            _buildStatCard(
              'Available',
              stats.availableBikes.toString(),
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatCard(
              'Damaged',
              stats.damagedBikes.toString(),
              Icons.warning,
              Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  /// Build individual stat card
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build chart card wrapper
  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  /// Build pie chart for Allocated vs Available bikes
  Widget _buildAllocationPieChart(DashboardStats stats) {
    final allocated = stats.allocatedBikes.toDouble();
    final available = stats.availableBikes.toDouble();
    final total = stats.totalBikes;

    if (total == 0) {
      return const SizedBox(height: 200, child: Center(child: Text('No data')));
    }

    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: allocated,
                    title: '${stats.allocatedBikes}',
                    color: Colors.orange,
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: available,
                    title: '${stats.availableBikes}',
                    color: Colors.green,
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem(
                  'Allocated',
                  Colors.orange,
                  stats.allocatedBikes,
                ),
                const SizedBox(height: 8),
                _buildLegendItem(
                  'Available',
                  Colors.green,
                  stats.availableBikes,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build pie chart for Damaged vs Undamaged bikes
  Widget _buildDamagePieChart(DashboardStats stats) {
    final damaged = stats.damagedBikes.toDouble();
    final undamaged = stats.undamagedBikes.toDouble();
    final total = stats.totalBikes;

    if (total == 0) {
      return const SizedBox(height: 200, child: Center(child: Text('No data')));
    }

    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: damaged > 0 ? damaged : 0.1,
                    title: damaged > 0 ? '${stats.damagedBikes}' : '',
                    color: Colors.red,
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: undamaged,
                    title: '${stats.undamagedBikes}',
                    color: Colors.teal,
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem('Damaged', Colors.red, stats.damagedBikes),
                const SizedBox(height: 8),
                _buildLegendItem(
                  'Undamaged',
                  Colors.teal,
                  stats.undamagedBikes,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build bar chart for Active vs Returned allocations
  Widget _buildAllocationsBarChart(DashboardStats stats) {
    final active = stats.activeAllocations.toDouble();
    final returned = stats.returnedAllocations.toDouble();
    final maxY = (active > returned ? active : returned) + 2;

    if (active == 0 && returned == 0) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No allocations yet')),
      );
    }

    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Active',
                                style: TextStyle(fontSize: 12),
                              ),
                            );
                          case 1:
                            return const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Returned',
                                style: TextStyle(fontSize: 12),
                              ),
                            );
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value == value.roundToDouble()) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: active,
                        color: Colors.blue,
                        width: 40,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                    showingTooltipIndicators: [0],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: returned,
                        color: Colors.purple,
                        width: 40,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                    showingTooltipIndicators: [0],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem(
                  'Active',
                  Colors.blue,
                  stats.activeAllocations,
                ),
                const SizedBox(height: 8),
                _buildLegendItem(
                  'Returned',
                  Colors.purple,
                  stats.returnedAllocations,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build legend item for charts
  Widget _buildLegendItem(String label, Color color, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            '$label ($value)',
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
