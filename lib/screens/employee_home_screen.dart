// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:lottie/lottie.dart';

// Project imports:
import 'package:cyclot_v1/core/extensions/context_extensions.dart';
import 'package:cyclot_v1/core/helpers/error_helper.dart';
import 'package:cyclot_v1/models/user_model.dart';
import 'package:cyclot_v1/repositories/notification_repository.dart';
import 'package:cyclot_v1/repositories/user_repository.dart';
import 'package:cyclot_v1/screens/employee_available_bikes_screen.dart';
import 'package:cyclot_v1/screens/employee_notifications_screen.dart';
import 'package:cyclot_v1/screens/employee_return_bike_screen.dart';
import 'package:cyclot_v1/services/auth_service.dart';

class EmployeeHomeScreen extends StatefulWidget {
  final String uid;
  final UserRepository? userRepository;
  final NotificationRepository? notificationRepository;
  final AuthService? authService;

  const EmployeeHomeScreen({
    required this.uid,
    this.userRepository,
    this.notificationRepository,
    this.authService,
    super.key,
  });

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  late Future<AppUser?> userFuture;
  late final UserRepository _userRepository;
  late final NotificationRepository _notificationRepository;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _userRepository = widget.userRepository ?? UserRepository();
    _notificationRepository = widget.notificationRepository ?? NotificationRepository();
    _authService = widget.authService ?? AuthService();
    userFuture = _userRepository.getUser(widget.uid);
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
      backgroundColor: context.scaffoldBackground,
      appBar: AppBar(
        title: Text('Home', style: context.appBarTheme.titleTextStyle),
        backgroundColor: context.appBarTheme.backgroundColor,
        centerTitle: true,
        actions: [
          FutureBuilder<int>(
            future: _notificationRepository.getUnreadCount(widget.uid),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              return IconButton(
                icon: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text('$unreadCount'),
                  child: const Icon(Icons.notifications, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const EmployeeNotificationsScreen(),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: FutureBuilder<AppUser?>(
        future: userFuture,
        builder: (context, snapshot) {
          final userName = snapshot.data?.name ?? 'Employee';
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Welcome, '),
                      Text('$userName!', style: context.textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Lottie.asset(
                    'assets/lotties/employee_home_animation.json',
                    width: double.infinity,
                    height: 500,
                    fit: BoxFit.fitWidth,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      side: BorderSide(color: Colors.purpleAccent),
                    ),
                    child: Text('View Available Bikes'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const EmployeeAvailableBikesScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      side: BorderSide(color: Colors.purpleAccent),
                    ),
                    child: Text('Return Bike'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const EmployeeReturnBikeScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
