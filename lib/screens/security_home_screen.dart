// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:cyclot_v1/core/helpers/error_helper.dart';
import 'package:cyclot_v1/models/user_model.dart';
import 'package:cyclot_v1/repositories/bike_repository.dart';
import 'package:cyclot_v1/repositories/user_repository.dart';
import 'package:cyclot_v1/screens/security_add_bikes_screen.dart';
import 'package:cyclot_v1/screens/security_returned_bikes_screen.dart';
import 'package:cyclot_v1/services/auth_service.dart';

class SecurityHomeScreen extends StatefulWidget {
  final String uid;
  final UserRepository? userRepository;
  final BikeRepository? bikeRepository;

  const SecurityHomeScreen({
    required this.uid,
    this.userRepository,
    this.bikeRepository,
    super.key,
  });

  @override
  State<SecurityHomeScreen> createState() => _SecurityHomeScreenState();
}

class _SecurityHomeScreenState extends State<SecurityHomeScreen> {
  late final UserRepository _userRepository;
  late final BikeRepository _bikeRepository;
  int _availableCount = 0;
  int _allocatedCount = 0;
  late Future<AppUser?> userFuture;

  @override
  void initState() {
    super.initState();
    _userRepository = widget.userRepository ?? UserRepository();
    _bikeRepository = widget.bikeRepository ?? BikeRepository();
    userFuture = _userRepository.getUser(widget.uid);
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    try {
      final bikeStats = await _bikeRepository.getBikesStats();
      setState(() {
        _availableCount = bikeStats['available'] ?? 0;
        _allocatedCount = bikeStats['allocated'] ?? 0;
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              final authService = AuthService();
              try {
                await authService.logout();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Logout error: ${ErrorHelper.cleanError(e)}',
                      ),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SecurityAddBikesScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<AppUser?>(
              future: userFuture,
              builder: (context, snapshot) {
                final userName = snapshot.data?.name ?? 'Security';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome,'),
                    Text(
                      '$userName!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Bike Stats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_availableCount',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Allocated',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_allocatedCount',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SecurityReturnedBikesScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.assignment_return),
              label: const Text('Review Returned Bikes'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
