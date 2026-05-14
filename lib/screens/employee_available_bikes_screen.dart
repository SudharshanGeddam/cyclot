// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:cyclot_v1/core/extensions/context_extensions.dart';
import 'package:cyclot_v1/core/helpers/error_helper.dart';
import 'package:cyclot_v1/models/bike_model.dart';
import 'package:cyclot_v1/models/user_model.dart';
import 'package:cyclot_v1/repositories/allocation_repository.dart';
import 'package:cyclot_v1/repositories/bike_repository.dart';
import 'package:cyclot_v1/repositories/user_repository.dart';
import 'package:cyclot_v1/services/allocation_service.dart';
import 'package:cyclot_v1/services/auth_service.dart';

class EmployeeAvailableBikesScreen extends StatefulWidget {
  const EmployeeAvailableBikesScreen({super.key});

  @override
  State<EmployeeAvailableBikesScreen> createState() =>
      _EmployeeAvailableBikesScreenState();
}

class _EmployeeAvailableBikesScreenState
    extends State<EmployeeAvailableBikesScreen> {
  final AuthService _authService = AuthService();
  final UserRepository _userRepository = UserRepository();
  final BikeRepository _bikeRepository = BikeRepository();
  final AllocationRepository _allocationRepository = AllocationRepository();
  final AllocationService _allocationService = AllocationService();
  final Map<String, bool> _requestingBikes = {};
  late Future<AppUser?> user;
  late Stream<List<Bike>> _availableBikesStream;
  late String _employeeId;
  String _employeeName = '';

  @override
  void initState() {
    super.initState();
    _employeeId = _authService.currentUserId!;

    user = _userRepository.getUser(_employeeId);
    user.then((appUser) {
      if (appUser != null) {
        setState(() => _employeeName = appUser.name);
      }
    });

    _availableBikesStream = _bikeRepository.getBikesStream().map((snapshot) {
      return snapshot
          .where((bike) => bike.isAllocated == false && bike.isDamaged == false)
          .toList();
    });
  }

  Future<void> _requestBike(String bikeId) async {
    setState(() => _requestingBikes[bikeId] = true);

    try {
      // Check if employee already has an active allocation
      final existingAllocation = await _allocationRepository
          .getActiveAllocationForEmployee(_employeeId);

      if (existingAllocation != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'You already have a bike allocated. Please return it first.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
        setState(() => _requestingBikes[bikeId] = false);
        return;
      }

      // Use AllocationService to allocate bike (handles batch operation)
      await _allocationService.allocateBike(
        employeeId: _employeeId,
        employeeName: _employeeName,
        bikeId: bikeId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bike allocated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error allocating bike: ${ErrorHelper.cleanError(e)}',
            ),
          ),
        );
      }
    } finally {
      setState(() => _requestingBikes[bikeId] = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Available Bikes',
          style: context.appBarTheme.titleTextStyle,
        ),
        backgroundColor: context.appBarTheme.backgroundColor,
        centerTitle: true,
        elevation: 0,
        leading: BackButton(color: Colors.white),
      ),
      body: FutureBuilder<dynamic>(
        future: _allocationRepository.getActiveAllocationForEmployee(
          _employeeId,
        ),
        builder: (context, activeAllocSnapshot) {
          final hasActiveAllocation = activeAllocSnapshot.data != null;

          return StreamBuilder<List<Bike>>(
            stream: _availableBikesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final bikes = snapshot.data ?? [];

              if (bikes.isEmpty) {
                return const Center(
                  child: Text('No available bikes at the moment.'),
                );
              }

              return Column(
                children: [
                  if (hasActiveAllocation)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      color: Colors.orange.shade100,
                      child: const Text(
                        'You already have a bike allocated. Please return it before requesting another.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: bikes.length,
                      itemBuilder: (context, index) {
                        final bike = bikes[index];
                        final bikeId = bike.bikeId;
                        final isRequesting = _requestingBikes[bikeId] ?? false;

                        return Card(
                          color: context.cardTheme.color,
                          elevation: context.cardTheme.elevation,
                          shape: context.cardTheme.shape,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Bike ID: $bikeId',
                                            style:
                                                context.textTheme.titleMedium,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Created: ${bike.createdAt.toString().split('.')[0]}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Status: ${bike.isDamaged ? 'Damaged' : 'Available'}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed:
                                        (isRequesting || hasActiveAllocation)
                                        ? null
                                        : () => _requestBike(bikeId),
                                    child: isRequesting
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            hasActiveAllocation
                                                ? 'Request Bike'
                                                : 'Request Bike',
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
