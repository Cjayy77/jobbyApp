import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/chat_message.dart';

class ChatNotificationService {
  static final ChatNotificationService _instance =
      ChatNotificationService._internal();
  factory ChatNotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  ChatNotificationService._internal();

  Future<void> initialize() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _notifications.initialize(initializationSettings);
  }

  Future<void> showNewMessageNotification(
      ChatMessage message, String senderName) async {
    await _notifications.show(
      message.id.hashCode,
      'New Message from $senderName',
      message.text,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'chat_messages',
          'Chat Messages',
          channelDescription: 'Notifications for new chat messages',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.message,
          styleInformation: MessagingStyleInformation(
            const Person(name: 'Me'),
            conversationTitle: 'Job Discussion',
            messages: [
              Message(
                message.text,
                message.timestamp,
                const Person(name: 'Me'),
              ),
            ],
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
