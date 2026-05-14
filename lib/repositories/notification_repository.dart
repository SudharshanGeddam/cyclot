// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:cyclot_v1/core/constants.dart';
import 'package:cyclot_v1/models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Create new notification
  Future<String> createNotification(AppNotification notification) async {
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.notifications)
          .add(notification.toFirestore());

      return doc.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Get notifications for employee
  Future<List<AppNotification>> getEmployeeNotifications(
    String employeeId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.notifications)
          .where(FirestoreFields.employeeId, isEqualTo: employeeId)
          .orderBy(FirestoreFields.createdAtField, descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get notifications stream for real-time updates
  Stream<List<AppNotification>> getNotificationsStream(String employeeId) {
    return _firestore
        .collection(FirestoreCollections.notifications)
        .where(FirestoreFields.employeeId, isEqualTo: employeeId)
        .orderBy(FirestoreFields.createdAtField, descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppNotification.fromFirestore(doc))
              .toList(),
        );
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(FirestoreCollections.notifications)
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String employeeId) async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.notifications)
          .where(FirestoreFields.employeeId, isEqualTo: employeeId)
          .where('read', isEqualTo: false)
          .get();

      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'read': true});
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection(FirestoreCollections.notifications)
          .doc(notificationId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount(String employeeId) async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.notifications)
          .where(FirestoreFields.employeeId, isEqualTo: employeeId)
          .where('read', isEqualTo: false)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      rethrow;
    }
  }
}
