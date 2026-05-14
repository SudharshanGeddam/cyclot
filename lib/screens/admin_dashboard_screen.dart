// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:cyclot_v1/core/helpers/error_helper.dart';
import 'package:cyclot_v1/models/dashboard_stats.dart';
import 'package:cyclot_v1/repositories/allocation_repository.dart';
import 'package:cyclot_v1/repositories/bike_repository.dart';
import 'package:cyclot_v1/services/auth_service.dart';
import 'package:cyclot_v1/widgets/chart_widgets.dart';
import 'package:cyclot_v1/widgets/empty_state.dart';
import 'package:cyclot_v1/widgets/stat_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String uid;
  final AuthService? authService;
  final BikeRepository? bikeRepository;
  final AllocationRepository? allocationRepository;

  const AdminDashboardScreen({
    super.key,
    required this.uid,
    this.authService,
    this.bikeRepository,
    this.allocationRepository,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final AuthService _authService;
  late final BikeRepository _bikeRepository;
  late final AllocationRepository _allocationRepository;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    _bikeRepository = widget.bikeRepository ?? BikeRepository();
    _allocationRepository = widget.allocationRepository ?? AllocationRepository();
  }

  Future<DashboardStats> _fetchDashboardStats() async {
    try {
      final bikeStats = await _bikeRepository.getBikesStats();
      final allocationStats = await _allocationRepository.getAllocationStats();

      return DashboardStats(
        totalBikes: bikeStats['total'] ?? 0,
        allocatedBikes: bikeStats['allocated'] ?? 0,
        availableBikes: bikeStats['available'] ?? 0,
        damagedBikes: bikeStats['damaged'] ?? 0,
        undamagedBikes: bikeStats['undamaged'] ?? 0,
        activeAllocations: allocationStats['active'] ?? 0,
        returnedAllocations: allocationStats['returned'] ?? 0,
      );
    } catch (e) {
      rethrow;
    }
  }

  void _handleLogout() async {
    try {
      await _authService.logout();
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout error: ${ErrorHelper.cleanError(e)}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _handleLogout,
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
            return EmptyState(
              message: 'No bikes added yet',
              icon: Icons.pedal_bike,
              actionLabel: 'Add Bikes',
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
                  AllocationStatusChart(
                    allocatedBikes: stats.allocatedBikes,
                    availableBikes: stats.availableBikes,
                  ),
                  const SizedBox(height: 16),
                  BikeConditionChart(
                    damagedBikes: stats.damagedBikes,
                    undamagedBikes: stats.undamagedBikes,
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
            StatCard(
              label: 'Total Bikes',
              value: stats.totalBikes,
              textColor: Colors.blue,
            ),
            StatCard(
              label: 'Allocated',
              value: stats.allocatedBikes,
              textColor: Colors.orange,
            ),
            StatCard(
              label: 'Available',
              value: stats.availableBikes,
              textColor: Colors.green,
            ),
            StatCard(
              label: 'Damaged',
              value: stats.damagedBikes,
              textColor: Colors.red,
            ),
          ],
        ),
      ],
    );
  }
}
