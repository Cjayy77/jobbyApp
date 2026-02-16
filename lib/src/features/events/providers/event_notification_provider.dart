import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_notification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

final eventNotificationProvider = StateNotifierProvider<
    EventNotificationNotifier, AsyncValue<List<EventNotification>>>((ref) {
  return EventNotificationNotifier();
});

class EventNotificationNotifier
    extends StateNotifier<AsyncValue<List<EventNotification>>> {
  EventNotificationNotifier() : super(const AsyncValue.data([])) {
    tz.initializeTimeZones();
  }

  final _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(initializationSettings);
  }

  Future<void> scheduleEventReminder({
    required String eventId,
    required String userId,
    required String title,
    required String message,
    required DateTime eventDateTime,
  }) async {
    try {
      // Schedule notification 1 hour before the event
      final scheduledFor = eventDateTime.subtract(const Duration(hours: 1));

      // Create notification in Firestore
      final notification = EventNotification(
        id: '', // Will be set by Firestore
        eventId: eventId,
        userId: userId,
        title: title,
        message: message,
        scheduledFor: scheduledFor,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('notifications')
          .add(notification.toFirestore()); // Schedule local notification
      await _notifications.zonedSchedule(
        docRef.id.hashCode,
        title,
        message,
        tz.TZDateTime.from(scheduledFor, tz.local),
        NotificationDetails(
          android: const AndroidNotificationDetails(
            'event_reminders',
            'Event Reminders',
            channelDescription: 'Notifications for upcoming events',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      // Update state
      state.whenData((notifications) {
        final updatedNotifications = List<EventNotification>.from(notifications)
          ..add(notification);
        state = AsyncValue.data(updatedNotifications);
      });
    } catch (e, stack) {
      print('Error scheduling notification: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadUserNotifications(String userId) async {
    try {
      state = const AsyncValue.loading();

      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('scheduledFor', descending: true)
          .get();

      final notifications = querySnapshot.docs
          .map((doc) => EventNotification.fromFirestore(doc))
          .toList();

      state = AsyncValue.data(notifications);
    } catch (e, stack) {
      print('Error loading notifications: $e');
      state = AsyncValue.error(e, stack);
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
            return EventNotification(
              id: notification.id,
              eventId: notification.eventId,
              userId: notification.userId,
              title: notification.title,
              message: notification.message,
              scheduledFor: notification.scheduledFor,
              isRead: true,
              createdAt: notification.createdAt,
            );
          }
          return notification;
        }).toList();
        state = AsyncValue.data(updatedNotifications);
      });
    } catch (e, stack) {
      print('Error marking notification as read: $e');
      state = AsyncValue.error(e, stack);
    }
  }
}
