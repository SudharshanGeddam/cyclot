# Firebase Auth & Firestore Code Snippets

## Quick Reference

### 1. User Registration with Firestore

```dart
// Step 1: Create auth user
final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email,
  password: password,
);

// Step 2: Get UID and create Firestore document
final uid = userCredential.user!.uid;
await FirebaseFirestore.instance.collection('users').doc(uid).set({
  'name': name,
  'email': email,
  'role': role,
  'createdAt': FieldValue.serverTimestamp(),
});

// Step 3: Route to role-based screen
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => RoleRouterScreen(uid: uid)),
);
```

### 2. User Login with Role Validation

```dart
// Step 1: Authenticate
final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);

// Step 2: Validate Firestore document exists
final uid = userCredential.user!.uid;
final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

if (!doc.exists) {
  throw Exception('User profile not found');
}

// Step 3: Get role for routing
final role = doc.data()?['role'] as String?;
```

### 3. Role-Based Routing

```dart
// In RoleRouterScreen
switch (role) {
  'employee' => EmployeeHomeScreen(uid: uid),
  'security' => SecurityHomeScreen(uid: uid),
  'admin' => AdminHomeScreen(uid: uid),
  _ => _UnknownRoleScreen(uid: uid, role: role),
}
```

### 4. Auth State Listener (App Startup)

```dart
// In main.dart
StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const LoadingScreen();
    }

    if (snapshot.hasData) {
      // User is logged in
      return RoleRouterScreen(uid: snapshot.data!.uid);
    }

    // User is not logged in
    return const LoginScreen();
  },
)
```

### 5. User Logout

```dart
ElevatedButton(
  onPressed: () async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  },
  child: const Text('Logout'),
)
```

### 6. Handle Firebase Exceptions

```dart
try {
  // Firebase operation
} on FirebaseAuthException catch (e) {
  // Handle authentication errors
  String message = switch (e.code) {
    'user-not-found' => 'No account found',
    'wrong-password' => 'Incorrect password',
    'email-already-in-use' => 'Email already registered',
    'weak-password' => 'Password too weak',
    _ => 'Auth error: ${e.message}',
  };
  showError(message);
} on FirebaseException catch (e) {
  // Handle Firestore/general Firebase errors
  showError('Firebase error: ${e.message}');
} catch (e) {
  // Handle unexpected errors
  showError('Unexpected error: $e');
}
```

### 7. Fetch User Profile

```dart
Future<Map<String, dynamic>?> getUserProfile(String uid) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    
    if (!doc.exists) {
      return null;
    }
    
    return doc.data();
  } on FirebaseException catch (e) {
    print('Error fetching profile: ${e.message}');
    rethrow;
  }
}
```

### 8. Update User Role (Admin Action)

```dart
// Only admin can do this (enforce in Firestore rules)
await FirebaseFirestore.instance
    .collection('users')
    .doc(targetUid)
    .update({'role': 'admin'});
```

### 9. List All Users (Admin Only)

```dart
// Fetch all users (protect this query in Firestore rules)
final snapshot = await FirebaseFirestore.instance
    .collection('users')
    .get();

final users = snapshot.docs.map((doc) => doc.data()).toList();
```

### 10. Real-Time User Profile Updates

```dart
// Listen for changes to user profile
FirebaseFirestore.instance
    .collection('users')
    .doc(uid)
    .snapshots()
    .listen((doc) {
  if (doc.exists) {
    final userData = doc.data();
    // Update UI with real-time data
  }
});
```

### 11. Delete User Account

```dart
Future<void> deleteAccount(String uid) async {
  try {
    // Delete Firestore document
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
    
    // Delete auth account
    await FirebaseAuth.instance.currentUser?.delete();
  } catch (e) {
    print('Error deleting account: $e');
    rethrow;
  }
}
```

### 12. Email Verification

```dart
// Send verification email after registration
await FirebaseAuth.instance.currentUser?.sendEmailVerification();

// Check if email is verified (in login)
if (!FirebaseAuth.instance.currentUser!.emailVerified) {
  // Show "verify email" screen
  // User can resend verification email
}
```

---

## Firebase Rules Examples

### Basic: User Can Only Access Own Document

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
  }
}
```

### Advanced: Role-Based Access

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User can access own document
    match /users/{uid} {
      allow read: if request.auth.uid == uid;
      allow write: if request.auth.uid == uid;
    }
    
    // Admin can read all users
    match /users/{uid} {
      allow read: if request.auth != null && 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

---

## Error Messages

### Authentication Errors
| Code | Message | Solution |
|------|---------|----------|
| `user-not-found` | User doesn't exist | Show "No account found" |
| `wrong-password` | Password incorrect | Show "Incorrect password" |
| `email-already-in-use` | Email registered | Show "Email already registered" |
| `weak-password` | Password too weak | Show "Password must be 6+ chars" |
| `too-many-requests` | Too many attempts | Show "Try again later" |

### Firestore Errors
| Code | Meaning | Solution |
|------|---------|----------|
| `permission-denied` | User lacks access | Check Firestore rules |
| `not-found` | Document doesn't exist | Create document or handle gracefully |
| `invalid-argument` | Bad query/data | Check field names and types |
| `unavailable` | Service down | Show retry option |

---

## State Management Pattern (SetState)

```dart
void _handleLogin() async {
  // Disable button & show loading
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final uid = await _loginUser();
    
    // Navigate (check mounted to prevent errors after pop)
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(uid: uid)),
      );
    }
  } catch (e) {
    // Show error & enable button
    setState(() {
      _errorMessage = e.toString();
      _isLoading = false;
    });
  }
}
```

---

## Testing Tips

```dart
// Mock Firebase for testing
void main() {
  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  test('User registration creates Firestore document', () async {
    // Test registration flow
  });

  test('Login validates Firestore data', () async {
    // Test login flow
  });
}
```

