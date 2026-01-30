# Cyclot - Bike Management System

A Flutter-based bike management application designed for organizations to manage bike allocations, returns, and inventory tracking. The app uses Firebase for authentication and data storage.

## Features

### Authentication
- User registration with role selection (Employee, Security, Admin)
- Email/password login with Firebase Authentication
- Role-based navigation and access control

### Employee Portal
- **View Available Bikes** - Browse bikes that are available for allocation
- **Request Bike** - Allocate an available bike to yourself
- **Return Bike** - Return your currently allocated bike (pending security review)
- **Notification Inbox** - View notifications about bike return reviews

### Security Portal
- **Dashboard Overview** - View counts of available and allocated bikes
- **Add Bikes** - Add new bikes to the inventory
- **Review Returned Bikes** - Inspect returned bikes and mark as damaged/undamaged
- **View Allocations** - See which bikes are allocated and to whom
- **Push Notifications** - Automatically notify employees when their returned bike is reviewed

### Admin Dashboard
- **Statistics Overview** - View total bikes, allocated, available, damaged counts
- **Allocation Status Chart** - Visual representation of bike allocation status
- **Bike Condition Chart** - Visual representation of damaged vs undamaged bikes

## Tech Stack

- **Framework**: Flutter
- **Backend**: Firebase
  - Firebase Authentication
  - Cloud Firestore
- **Charts**: fl_chart
- **Animations**: Lottie

## Project Structure

```
lib/
├── main.dart                 # App entry point & auth check
├── firebase_options.dart     # Firebase configuration
├── core/
│   ├── extensions/           # Context extensions
│   └── theme/                # App theme configuration
├── models/
│   └── user_model.dart       # User data model
└── screens/
    ├── login_screen.dart
    ├── register_screen.dart
    ├── role_router_screen.dart
    ├── employee_home_screen.dart
    ├── employee_available_bikes_screen.dart
    ├── employee_return_bike_screen.dart
    ├── employee_notifications_screen.dart
    ├── security_home_screen.dart
    ├── security_add_bikes_screen.dart
    ├── security_returned_bikes_screen.dart
    └── admin_dashboard_screen.dart
```

## Firestore Collections

- **users** - User profiles with role information
- **bikes** - Bike inventory with status (isAllocated, isDamaged)
- **allocations** - Bike allocation records
- **notifications** - Employee notifications for bike review status

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Firebase:
   - Create a Firebase project
   - Enable Authentication (Email/Password)
   - Create Firestore database
   - Run `flutterfire configure`
4. Run the app: `flutter run`

## Not Yet Implemented

### Features
- [ ] Bike search and filtering functionality
- [ ] Bike details screen with full information
- [ ] Edit/delete bike functionality for security
- [ ] User profile management and password change
- [ ] Admin user management (view/edit/delete users)
- [ ] Allocation history for employees
- [ ] Export reports functionality for admin

### Technical Improvements
- [ ] Offline support with local caching
- [ ] Image upload for bike photos
- [ ] QR code scanning for bike identification
- [ ] Unit and widget tests
- [ ] CI/CD pipeline setup
- [ ] Firestore security rules optimization
- [ ] Pagination for large datasets (partially implemented)
- [ ] Error boundary and crash reporting
- [ ] Analytics integration

### UI/UX Enhancements
- [ ] Onboarding screens for new users
- [ ] Skeleton loading states
- [ ] Pull-to-refresh on all list screens
- [ ] Empty state illustrations
- [ ] Success/error animations
- [ ] Responsive layout for tablets/web

## License

This project is private and proprietary.
