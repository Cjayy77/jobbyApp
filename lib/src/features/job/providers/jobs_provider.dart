import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/job.dart';
import '../services/job_service.dart';

class JobsNotifier extends StateNotifier<AsyncValue<List<Job>>> {
  final JobService _jobService;

  JobsNotifier(this._jobService) : super(const AsyncValue.loading()) {
    loadJobs();
  }

  Future<void> loadJobs() async {
    try {
      state = const AsyncValue.loading();
      final jobs = await _jobService.getJobs();
      state = AsyncValue.data(jobs);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createJob(Job job) async {
    try {
      await _jobService.createJob(job);
      await loadJobs(); // Reload jobs after creating new one
    } catch (e) {
      rethrow; // Let the UI handle the error
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      await _jobService.deleteJob(jobId);
      await loadJobs(); // Reload jobs after deleting one
    } catch (e) {
      rethrow; // Let the UI handle the error
    }
  }
}

final jobsProvider =
    StateNotifierProvider<JobsNotifier, AsyncValue<List<Job>>>((ref) {
  final jobService = ref.watch(jobServiceProvider);
  return JobsNotifier(jobService);
});
