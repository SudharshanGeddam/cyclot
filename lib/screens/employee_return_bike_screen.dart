// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:cyclot_v1/models/allocation_model.dart';
import 'package:cyclot_v1/repositories/allocation_repository.dart';
import 'package:cyclot_v1/services/allocation_service.dart';
import 'package:cyclot_v1/services/auth_service.dart';
import 'package:cyclot_v1/widgets/active_allocation_card.dart';
import 'package:cyclot_v1/core/helpers/error_helper.dart';

class EmployeeReturnBikeScreen extends StatefulWidget {
  const EmployeeReturnBikeScreen({super.key});

  @override
  State<EmployeeReturnBikeScreen> createState() =>
      _EmployeeReturnBikeScreenState();
}

class _EmployeeReturnBikeScreenState extends State<EmployeeReturnBikeScreen> {
  final AuthService _authService = AuthService();
  final AllocationService _allocationService = AllocationService();
  final AllocationRepository _allocationRepository = AllocationRepository();
  bool _isReturning = false;
  late String _currentUserUid;

  @override
  void initState() {
    super.initState();
    _currentUserUid = _authService.currentUserId ?? '';
  }

  Future<Allocation?> _getActiveAllocation() async {
    try {
      return await _allocationRepository.getActiveAllocationForEmployee(
        _currentUserUid,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _returnBike(String allocationId, String bikeId) async {
    setState(() => _isReturning = true);

    try {
      await _allocationService.returnBike(
        allocationId: allocationId,
        bikeId: bikeId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Bike returned successfully! Pending security review.',
            ),
            duration: Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error returning bike: ${ErrorHelper.cleanError(e)}'),
          ),
        );
      }
    } finally {
      setState(() => _isReturning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Return Bike'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<Allocation?>(
        future: _getActiveAllocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allocation = snapshot.data;

          if (allocation == null) {
            return const Center(
              child: Text('You do not have an active bike allocation.'),
            );
          }

          final allocationId = allocation.id;
          final bikeId = allocation.bikeId;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ActiveAllocationCard(allocation: allocation),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isReturning
                        ? null
                        : () => _returnBike(allocationId, bikeId),
                    icon: _isReturning
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle),
                    label: const Text('Return Bike'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.purpleAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Confirm your bike return. This action cannot be undone.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
