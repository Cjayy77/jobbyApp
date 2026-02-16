import 'package:cloud_firestore/cloud_firestore.dart';
import 'application_status.dart';

class JobApplication {
  final String id;
  final String jobId;
  final String userId;
  final String coverLetter;
  final String? resumeUrl;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final String? jobTitle;
  const JobApplication({
    required this.id,
    required this.jobId,
    required this.userId,
    required this.coverLetter,
    this.resumeUrl,
    required this.status,
    required this.appliedAt,
    this.jobTitle,
  });

  JobApplication copyWith({
    String? id,
    String? jobId,
    String? userId,
    String? coverLetter,
    String? resumeUrl,
    String? status,
    DateTime? appliedAt,
  }) {
    return JobApplication(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      userId: userId ?? this.userId,
      coverLetter: coverLetter ?? this.coverLetter,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      status: ApplicationStatus.fromString(status ?? this.status.name),
      appliedAt: appliedAt ?? this.appliedAt,
      jobTitle: jobTitle ?? this.jobTitle,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'jobId': jobId,
      'userId': userId,
      'coverLetter': coverLetter,
      'resumeUrl': resumeUrl,
      'status': status.name,
      'appliedAt': Timestamp.fromDate(appliedAt),
      'jobTitle': jobTitle,
    };
  }

  factory JobApplication.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobApplication(
      id: doc.id,
      jobId: data['jobId'] as String,
      userId: data['userId'] as String,
      coverLetter: data['coverLetter'] as String,
      resumeUrl: data['resumeUrl'] as String?,
      status: ApplicationStatus.fromString(data['status'] as String),
      appliedAt: (data['appliedAt'] as Timestamp).toDate(),
      jobTitle: data['jobTitle'] as String?,
    );
  }
}
