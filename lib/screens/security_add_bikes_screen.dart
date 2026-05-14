// Flutter imports:
import 'package:flutter/material.dart';

import 'package:cyclot_v1/core/helpers/error_helper.dart';
import 'package:cyclot_v1/widgets/message_card.dart';
import 'package:cyclot_v1/services/bike_service.dart';

class SecurityAddBikesScreen extends StatefulWidget {
  const SecurityAddBikesScreen({super.key});

  @override
  State<SecurityAddBikesScreen> createState() => _SecurityAddBikesScreenState();
}

class _SecurityAddBikesScreenState extends State<SecurityAddBikesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberOfBikesController = TextEditingController();
  final BikeService _bikeService = BikeService();

  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;

  @override
  void dispose() {
    _numberOfBikesController.dispose();
    super.dispose();
  }

  Future<void> _handleAddBikes() async {
    setState(() {
      _successMessage = null;
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final numberOfBikes = int.tryParse(_numberOfBikesController.text);
    if (numberOfBikes == null || numberOfBikes <= 0) {
      setState(() {
        _errorMessage = 'Please enter a valid number of bikes.';
      });
      return;
    }

    if (numberOfBikes > 100) {
      setState(() {
        _errorMessage = 'Maximum 100 bikes can be added at once.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _bikeService.bulkAddBikesToFirestore(numberOfBikes);
      setState(() {
        _successMessage = 'Successfully added $numberOfBikes bikes!';
        _numberOfBikesController.clear();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error adding bikes: ${ErrorHelper.cleanError(e)}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Bikes in Bulk'),
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enter the number of bikes to add to the system.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _numberOfBikesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Number of Bikes',
                    hintText: 'Enter a number (max 100)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.two_wheeler),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a number';
                    }
                    final num = int.tryParse(value);
                    if (num == null) {
                      return 'Please enter a valid number';
                    }
                    if (num <= 0) {
                      return 'Number must be greater than 0';
                    }
                    if (num > 100) {
                      return 'Maximum 100 bikes allowed';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleAddBikes,
                  icon: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        )
                      : const Icon(Icons.add),
                  label: Text(
                    _isLoading ? 'Adding Bikes...' : 'Add Bikes in Bulk',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),
                if (_successMessage != null)
                  MessageCard(
                    message: _successMessage!,
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                if (_errorMessage != null)
                  MessageCard(
                    message: _errorMessage!,
                    color: Colors.red,
                    icon: Icons.error,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
