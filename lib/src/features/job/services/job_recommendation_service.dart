import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/job.dart';
import '../models/job_preferences.dart';
import '../../../core/services/notification_service.dart';
import '../../profile/providers/profile_provider.dart';
import '../providers/preferences_provider.dart';
import '../../settings/providers/settings_provider.dart';

final jobRecommendationProvider = Provider<JobRecommendationService>((ref) {
  return JobRecommendationService(ref);
});

class JobRecommendationService {
  final Ref _ref;

  JobRecommendationService(this._ref);

  int _calculateMatchScore(Job job, JobPreferences preferences) {
    var score = 0;

    // Category match (40 points)
    if (preferences.preferredCategories.isNotEmpty) {
      if (job.categories.any(
          (category) => preferences.preferredCategories.contains(category))) {
        score += 40;
      }
    } else {
      score += 40; // No category preference means all categories match
    }

    // Location match (30 points)
    if (preferences.preferredLocations.isNotEmpty) {
      if (preferences.preferredLocations.contains(job.location)) {
        score += 30;
      }
    } else {
      score += 30; // No location preference means all locations match
    }

    // Salary match (30 points)
    if (preferences.minimumSalary != null && job.salary != null) {
      if (job.salary! >= preferences.minimumSalary!) {
        score += 30;
      }
    } else {
      score += 30; // No salary preference means all salaries match
    }

    return score;
  }

  Future<void> processNewJob(Job job) async {
    final settings = _ref.read(settingsProvider);
    if (!settings.notificationsEnabled || !settings.recommendationsEnabled) {
      return;
    }

    final preferences = _ref.read(preferencesProvider);
    final profile = _ref.read(profileProvider).value;

    if (profile == null) return; // Calculate match score based on preferences
    final score = _calculateMatchScore(job, preferences);

    // If score is high enough, send a recommendation notification
    if (score >= 70) {
      await NotificationService().showJobRecommendationNotification(
        jobId: job.id,
        title: 'Recommended Job: ${job.title}',
        body: '${job.company} is hiring - This job matches your preferences!',
      );
    }
  }

  List<Job> getRecommendedJobs(List<Job> allJobs) {
    final preferences = _ref.read(preferencesProvider);
    final profile = _ref.read(profileProvider).value;

    if (profile == null) return [];

    // Filter and sort jobs by match score
    final scoredJobs = allJobs
        .map((job) {
          final score = _calculateMatchScore(job, preferences);
          return (job: job, score: score);
        })
        .where((item) => item.score >= 70)
        .toList();

    // Sort by score descending
    scoredJobs.sort((a, b) => b.score.compareTo(a.score));

    // Return just the jobs, score is used only for sorting
    return scoredJobs.map((item) => item.job).toList();
  }
}
