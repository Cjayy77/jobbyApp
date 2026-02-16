import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_application.dart';
import '../models/application_status.dart';
import '../../../features/auth/providers/auth_provider.dart';

final jobApplicationsProvider = StateNotifierProvider<JobApplicationsNotifier,
    AsyncValue<List<JobApplication>>>((ref) {
  return JobApplicationsNotifier(ref);
});

class JobApplicationsNotifier
    extends StateNotifier<AsyncValue<List<JobApplication>>> {
  final Ref _ref;

  JobApplicationsNotifier(this._ref) : super(const AsyncValue.loading());

  Future<void> submitApplication({
    required String jobId,
    required String userId,
    required String resumePath,
    String? coverLetter,
  }) async {
    try {
      state = const AsyncValue.loading();

      final application = JobApplication(
        id: '',
        jobId: jobId,
        userId: userId,
        coverLetter: coverLetter ?? '',
        resumeUrl: resumePath,
        status: ApplicationStatus.pending,
        appliedAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('job_applications')
          .add(application.toFirestore());

      _loadApplications(userId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _loadApplications(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('job_applications')
          .where('userId', isEqualTo: userId)
          .orderBy('appliedAt', descending: true)
          .get();

      final applications = snapshot.docs
          .map((doc) => JobApplication.fromFirestore(doc))
          .toList();

      state = AsyncValue.data(applications);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> withdrawApplication(String applicationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('job_applications')
          .doc(applicationId)
          .update({
        'status': ApplicationStatus.withdrawn.name,
      });

      // Refresh the applications list after withdrawal
      final currentUser = _ref.read(authProvider);
      if (currentUser != null) {
        await _loadApplications(currentUser.uid);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
