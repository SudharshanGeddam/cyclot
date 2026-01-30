import 'package:cyclot_v1/models/user_model.dart';
import 'package:cyclot_v1/screens/security_add_bikes_screen.dart';
import 'package:cyclot_v1/screens/security_returned_bikes_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SecurityHomeScreen extends StatefulWidget {
  final String uid;
  const SecurityHomeScreen({required this.uid, super.key});

  @override
  State<SecurityHomeScreen> createState() => _SecurityHomeScreenState();
}

class _SecurityHomeScreenState extends State<SecurityHomeScreen> {
  String _selectedChip = 'available';
  int _availableCount = 0;
  int _allocatedCount = 0;
  List<DocumentSnapshot> _availableBikes = [];
  List<Map<String, dynamic>> _allocations = [];
  DocumentSnapshot? _lastAvailableDoc;
  bool _hasMoreAvailable = true;
  bool _isLoading = false;
  late Future<AppUser> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get()
        .then((doc) => AppUser.fromFirestore(doc));
    _loadCounts();
    _loadAvailableBikes();
  }

  Future<void> _loadCounts() async {
    final bikesSnapshot = await FirebaseFirestore.instance
        .collection('bikes')
        .get();
    int available = 0;
    int allocated = 0;
    for (var doc in bikesSnapshot.docs) {
      final data = doc.data();
      if (data['isAllocated'] == true) {
        allocated++;
      } else {
        available++;
      }
    }
    setState(() {
      _availableCount = available;
      _allocatedCount = allocated;
    });
  }

  Future<void> _loadAvailableBikes({bool refresh = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection('bikes')
        .where('isAllocated', isEqualTo: false)
        .limit(10);

    if (!refresh && _lastAvailableDoc != null) {
      query = query.startAfterDocument(_lastAvailableDoc!);
    }

    final snapshot = await query.get();
    setState(() {
      if (refresh) {
        _availableBikes = snapshot.docs;
      } else {
        _availableBikes = snapshot.docs;
      }
      if (snapshot.docs.isNotEmpty) {
        _lastAvailableDoc = snapshot.docs.last;
      }
      _hasMoreAvailable = snapshot.docs.length == 10;
      _isLoading = false;
    });
  }

  Future<void> _loadAllocations() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final allocationsSnapshot = await FirebaseFirestore.instance
        .collection('allocations')
        .get();

    List<Map<String, dynamic>> allocations = [];
    for (var doc in allocationsSnapshot.docs) {
      final data = doc.data();
      allocations.add({
        'id': doc.id,
        'bikeNumber': data['bikeNumber'] ?? 'Unknown',
        'userName': data['userName'] ?? 'Unknown',
        'userEmail': data['userEmail'] ?? '',
        'allocatedAt': data['allocatedAt'],
      });
    }

    setState(() {
      _allocations = allocations;
      _isLoading = false;
    });
  }

  Future<void> _onRefresh() async {
    if (_selectedChip == 'available') {
      _lastAvailableDoc = _availableBikes.isNotEmpty
          ? _availableBikes.last
          : null;
      await _loadAvailableBikes();
    } else {
      await _loadAllocations();
    }
    await _loadCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
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
            icon: Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => SecurityAddBikesScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder<AppUser>(
              future: userFuture,
              builder: (context, snapshot) {
                final userName = snapshot.data?.name ?? 'Security';
                return Row(
                  children: [
                    const Text('Welcome, '),
                    Text(
                      '$userName!',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildChipsWidget(),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: _buildContentList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            const SecurityReturnedBikesScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.assignment_return),
                  label: const Text('Review Returned Bikes'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildChipsWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ChoiceChip(
            label: Text('Available: $_availableCount'),
            selected: _selectedChip == 'available',
            selectedColor: Colors.green.shade200,
            backgroundColor: Colors.green.shade50,
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedChip = 'available');
                _loadAvailableBikes(refresh: true);
              }
            },
          ),
          const SizedBox(width: 16),
          ChoiceChip(
            label: Text('Allocated: $_allocatedCount'),
            selected: _selectedChip == 'allocated',
            selectedColor: Colors.red.shade200,
            backgroundColor: Colors.red.shade50,
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedChip = 'allocated');
                _loadAllocations();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContentList() {
    if (_isLoading &&
        (_selectedChip == 'available'
            ? _availableBikes.isEmpty
            : _allocations.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_selectedChip == 'available') {
      if (_availableBikes.isEmpty) {
        return ListView(
          children: const [
            SizedBox(height: 50),
            Center(child: Text('No available bikes')),
          ],
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _availableBikes.length + (_hasMoreAvailable ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _availableBikes.length) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Pull to refresh for next 10 bikes',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }
          final bike = _availableBikes[index].data() as Map<String, dynamic>;
          return Card(
            child: ListTile(
              leading: Icon(Icons.pedal_bike, color: Colors.green),
              title: Text(bike['bikeNumber'] ?? 'Unknown'),
              subtitle: Text('Status: Available'),
            ),
          );
        },
      );
    } else {
      if (_allocations.isEmpty) {
        return ListView(
          children: const [
            SizedBox(height: 50),
            Center(child: Text('No allocated bikes')),
          ],
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _allocations.length,
        itemBuilder: (context, index) {
          final allocation = _allocations[index];
          return Card(
            child: ListTile(
              leading: Icon(Icons.pedal_bike, color: Colors.red),
              title: Text('Bike: ${allocation['bikeNumber']}'),
              subtitle: Text('Allocated to: ${allocation['userName']}'),
              trailing:
                  allocation['userEmail'] != null &&
                      allocation['userEmail'].isNotEmpty
                  ? Text(
                      allocation['userEmail'],
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    )
                  : null,
            ),
          );
        },
      );
    }
  }
}
