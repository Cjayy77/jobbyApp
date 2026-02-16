import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/job.dart';
import '../../../core/di/service_locator.dart' as di;
import '../../../core/services/analytics_service.dart';
import '../../../core/services/notification_service.dart';

class JobService {
  final FirebaseFirestore _firestore;
  final NotificationService _notificationService;
  final AnalyticsService _analyticsService;

  JobService(
    this._firestore, {
    required NotificationService notificationService,
    required AnalyticsService analyticsService,
  })  : _notificationService = notificationService,
        _analyticsService = analyticsService;

  Future<List<Job>> getJobs() async {
    try {
      final snapshot = await _firestore
          .collection('jobs')
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) => Job.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch jobs: $e');
    }
  }

  Future<void> applyForJob(String jobId, String userId, String jobTitle) async {
    try {
      await _firestore.collection('applications').add({
        'jobId': jobId,
        'userId': userId,
        'status': 'pending',
        'appliedAt': FieldValue.serverTimestamp(),
      });

      await _notificationService.sendNotification(
        userId,
        'Application Submitted',
        'Your application for $jobTitle has been submitted successfully.',
      );

      await _analyticsService.logJobApply(jobId, jobTitle);
    } catch (e) {
      throw Exception('Failed to apply for job: $e');
    }
  }

  Future<String?> getApplicationStatus(String jobId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return snapshot.docs.first.get('status') as String;
    } catch (e) {
      throw Exception('Failed to get application status: $e');
    }
  }

  Future<void> createJob(Job job) async {
    try {
      await _firestore.collection('jobs').doc(job.id).set(job.toJson());
    } catch (e) {
      throw Exception('Failed to create job: $e');
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).delete();
    } catch (e) {
      throw Exception('Failed to delete job: $e');
    }
  }
}

final jobServiceProvider = Provider<JobService>((ref) {
  final notificationService = ref.watch(di.notificationServiceProvider);
  final analyticsService = ref.watch(di.analyticsServiceProvider);
  return JobService(
    FirebaseFirestore.instance,
    notificationService: notificationService,
    analyticsService: analyticsService,
  );
});
