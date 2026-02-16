import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final String jobId;
  final String jobSeekerId;
  final String employerId;
  final DateTime lastMessageAt;

  const Chat({
    required this.id,
    required this.jobId,
    required this.jobSeekerId,
    required this.employerId,
    required this.lastMessageAt,
  });

  Chat copyWith({
    String? id,
    String? jobId,
    String? jobSeekerId,
    String? employerId,
    DateTime? lastMessageAt,
  }) {
    return Chat(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      jobSeekerId: jobSeekerId ?? this.jobSeekerId,
      employerId: employerId ?? this.employerId,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'jobId': jobId,
      'jobSeekerId': jobSeekerId,
      'employerId': employerId,
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
    };
  }

  factory Chat.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Chat(
      id: doc.id,
      jobId: data['jobId'] as String,
      jobSeekerId: data['jobSeekerId'] as String,
      employerId: data['employerId'] as String,
      lastMessageAt: (data['lastMessageAt'] as Timestamp).toDate(),
    );
  }
}
