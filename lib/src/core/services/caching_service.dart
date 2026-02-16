import '../../features/job/models/job.dart';

class CachingService {
  final Map<String, Job> _cachedJobs = {};

  Future<void> cacheJob(Job? job) async {
    if (job != null) {
      _cachedJobs[job.id] = job;
    }
  }

  Future<List<Job>> getCachedJobs() async {
    return _cachedJobs.values.toList();
  }

  Future<Job?> getCachedJob(String id) async {
    return _cachedJobs[id];
  }

  void clearCache() {
    _cachedJobs.clear();
  }
}
