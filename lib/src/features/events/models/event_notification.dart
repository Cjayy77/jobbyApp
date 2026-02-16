import 'package:cloud_firestore/cloud_firestore.dart';

class EventNotification {
  final String id;
  final String eventId;
  final String userId;
  final String title;
  final String message;
  final DateTime scheduledFor;
  final bool isRead;
  final DateTime createdAt;

  const EventNotification({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.title,
    required this.message,
    required this.scheduledFor,
    this.isRead = false,
    required this.createdAt,
  });

  factory EventNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventNotification(
      id: doc.id,
      eventId: data['eventId'] as String,
      userId: data['userId'] as String,
      title: data['title'] as String,
      message: data['message'] as String,
      scheduledFor: (data['scheduledFor'] as Timestamp).toDate(),
      isRead: data['isRead'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'userId': userId,
      'title': title,
      'message': message,
      'scheduledFor': Timestamp.fromDate(scheduledFor),
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
