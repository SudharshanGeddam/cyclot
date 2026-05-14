/// Constants for Cyclot application
///
/// Firestore collection names, field names, role types, and status values
/// are defined here to avoid string literal duplication and ensure consistency.
library;

/// Firestore collection names
class FirestoreCollections {
  static const String users = 'users';
  static const String bikes = 'bikes';
  static const String allocations = 'allocations';
  static const String notifications = 'notifications';
}

/// Firestore field names
class FirestoreFields {
  // User fields
  static const String name = 'name';
  static const String email = 'email';
  static const String role = 'role';
  static const String createdAt = 'createdAt';

  // Bike fields
  static const String bikeId = 'bikeId';
  static const String isAllocated = 'isAllocated';
  static const String isDamaged = 'isDamaged';

  // Allocation fields
  static const String employeeId = 'employeeId';
  static const String userName = 'userName';
  static const String allocatedAt = 'allocatedAt';
  static const String returned = 'returned';
  static const String bikeDocId = 'bikeDocId';
  static const String allocationId = 'allocationId';
  static const String reviewedAt = 'reviewedAt';
  static const String reviewStatus = 'reviewStatus';

  // Notification fields
  static const String notificationId = 'notificationId';
  static const String message = 'message';
  static const String isRead = 'isRead';
  static const String createdAtField = 'createdAt';
}

/// User roles
class UserRoles {
  static const String employee = 'employee';
  static const String security = 'security';
  static const String admin = 'admin';
}

/// Bike status values
class BikeStatus {
  static const String available = 'available';
  static const String allocated = 'allocated';
  static const String damaged = 'damaged';
  static const String returned = 'returned';
}

/// Review status for damaged bikes
class ReviewStatus {
  static const String damaged = 'damaged';
  static const String undamaged = 'undamaged';
}
