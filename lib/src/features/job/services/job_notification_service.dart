import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/job.dart';

class JobNotificationService {
  static final JobNotificationService _instance =
      JobNotificationService._internal();
  factory JobNotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  JobNotificationService._internal();

  Future<void> initialize() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _notifications.initialize(initializationSettings);
  }

  Future<void> showNewJobNotification(Job job) async {
    await _notifications.show(
      job.id.hashCode,
      'New Job Posted',
      '${job.title} at ${job.company}',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'new_jobs',
          'New Jobs',
          channelDescription: 'Notifications for new job postings',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showJobApplicationNotification(Job job) async {
    await _notifications.show(
      '${job.id}_application'.hashCode,
      'New Job Application',
      'Someone applied for: ${job.title}',
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
}
