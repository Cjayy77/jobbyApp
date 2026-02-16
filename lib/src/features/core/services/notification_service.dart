import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
  }

  Future<void> sendJobApplicationNotification({
    required String userId,
    required String jobTitle,
  }) async {
    await _notifications.show(
      userId.hashCode,
      'Application Submitted',
      'Your application for $jobTitle has been submitted successfully',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'job_applications',
          'Job Applications',
          channelDescription: 'Notifications for job applications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> sendJobStatusUpdateNotification({
    required String userId,
    required String jobTitle,
    required String status,
  }) async {
    await _notifications.show(
      '${userId}_${jobTitle}'.hashCode,
      'Application Status Update',
      'Your application for $jobTitle has been $status',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'job_status',
          'Job Status Updates',
          channelDescription:
              'Notifications for job application status updates',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}
