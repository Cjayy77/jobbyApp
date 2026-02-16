import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/job.dart';
import 'jobs_provider.dart';
import 'preferences_provider.dart';

final jobRecommendationsProvider = FutureProvider<List<Job>>((ref) async {
  final jobsState = ref.watch(jobsProvider);
  final preferences = ref.watch(preferencesProvider);

  return jobsState.when(
    data: (jobs) => jobs.where((job) {
      if (preferences.remoteOnly &&
          !job.location.toLowerCase().contains('remote')) {
        return false;
      }

      if (preferences.preferredCategories.isNotEmpty &&
          !job.categories
              .any((c) => preferences.preferredCategories.contains(c))) {
        return false;
      }

      if (preferences.preferredLocations.isNotEmpty &&
          !preferences.preferredLocations.contains(job.location)) {
        return false;
      }

      if (preferences.minimumSalary != null &&
          (job.salary == null || job.salary! < preferences.minimumSalary!)) {
        return false;
      }

      return true;
    }).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});
