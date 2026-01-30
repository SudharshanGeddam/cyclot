import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SecurityAddBikesScreen extends StatefulWidget {
  const SecurityAddBikesScreen({super.key});

  @override
  State<SecurityAddBikesScreen> createState() => _SecurityAddBikesScreenState();
}

class _SecurityAddBikesScreenState extends State<SecurityAddBikesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberOfBikesController = TextEditingController();

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
      await _bulkAddBikesToFirestore(numberOfBikes);
      setState(() {
        _successMessage = 'Successfully added $numberOfBikes bikes!';
        _numberOfBikesController.clear();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error adding bikes: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _bulkAddBikesToFirestore(int numberOfBikes) async {
    final bikesCollection = FirebaseFirestore.instance.collection('bikes');

    final snapshot = await bikesCollection.count().get();
    final currentCount = snapshot.count;
    final startingId = currentCount! + 1;

    final batch = FirebaseFirestore.instance.batch();
    final bikeColors = ['Red', 'Blue', 'Green', 'Yellow'];
    for (int i = 0; i < numberOfBikes; i++) {
      final bikeId = 'BIKE_${(startingId + i).toString().padLeft(3, '0')}';

      final docRef = bikesCollection.doc();

      final bikeData = {
        'bikeId': bikeId,
        'color': bikeColors[i % bikeColors.length],
        'isAllocated': false,
        'isDamaged': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      batch.set(docRef, bikeData);
    }

    await batch.commit();
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
                  _buildMessageCard(
                    message: _successMessage!,
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                if (_errorMessage != null)
                  _buildMessageCard(
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

  Widget _buildMessageCard({
    required String message,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
