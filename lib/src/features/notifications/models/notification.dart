import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  message,
  jobApplication,
  newJob,
  eventReminder,
  paymentSuccess,
  paymentFailure,
  chat
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final String? jobId;
  final DateTime createdAt;
  final String userId;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.jobId,
    required this.createdAt,
    required this.userId,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      title: data['title'] as String,
      message: data['message'] as String,
      type: NotificationType.values.byName(data['type'] as String),
      isRead: data['isRead'] as bool,
      jobId: data['jobId'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userId: data['userId'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'type': type.name,
      'isRead': isRead,
      'jobId': jobId,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    bool? isRead,
    String? jobId,
    DateTime? createdAt,
    String? userId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      jobId: jobId ?? this.jobId,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}
