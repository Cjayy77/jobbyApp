import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification.dart';

final notificationsProvider = StateNotifierProvider<NotificationsNotifier,
    AsyncValue<List<AppNotification>>>((ref) {
  return NotificationsNotifier();
});

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<AppNotification>>> {
  NotificationsNotifier() : super(const AsyncValue.data([]));

  final _firestore = FirebaseFirestore.instance;

  Future<void> loadNotifications(String userId) async {
    try {
      state = const AsyncValue.loading();

      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final notifications = snapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .toList();

      state = AsyncValue.data(notifications);
    } catch (e, stack) {
      print('Error loading notifications: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createNotification(AppNotification notification) async {
    try {
      final docRef = await _firestore
          .collection('notifications')
          .add(notification.toFirestore());

      state.whenData((notifications) {
        final newNotification = notification.copyWith(id: docRef.id);
        state = AsyncValue.data([newNotification, ...notifications]);
      });
    } catch (e) {
      print('Error creating notification: $e');
      rethrow;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});

      state.whenData((notifications) {
        final updatedNotifications = notifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();
        state = AsyncValue.data(updatedNotifications);
      });
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();

      state.whenData((notifications) {
        state = AsyncValue.data(
            notifications.where((n) => n.id != notificationId).toList());
      });
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }
}
