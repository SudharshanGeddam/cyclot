import 'package:cyclot_v1/firebase_options.dart';
import 'package:cyclot_v1/screens/login_screen.dart';
import 'package:cyclot_v1/screens/register_screen.dart';
import 'package:cyclot_v1/screens/role_router_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cyclot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthCheckScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        
      },
    );
  }
}

/// AuthCheckScreen: Checks if user is logged in and routes accordingly.
/// - If logged in: Routes to RoleRouterScreen with user's UID
/// - If not logged in: Routes to LoginScreen
class AuthCheckScreen extends StatelessWidget {
  const AuthCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is logged in
        if (snapshot.hasData && snapshot.data != null) {
          final uid = snapshot.data!.uid;
          return RoleRouterScreen(uid: uid);
        }

        // User is not logged in
        return const LoginScreen();
      },
    );
  }
}
