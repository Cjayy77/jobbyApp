import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

class AnalyticsService {
  final _analytics = FirebaseAnalytics.instance;

  Future<void> logJobApply(String jobId, String jobTitle) async {
    await _analytics.logEvent(
      name: 'job_apply',
      parameters: {
        'job_id': jobId,
        'job_title': jobTitle,
      },
    );
  }

  Future<void> logJobCreation(String jobId, String jobTitle) async {
    await _analytics.logEvent(
      name: 'job_creation',
      parameters: {
        'job_id': jobId,
        'job_title': jobTitle,
      },
    );
  }

  Future<void> logSearch(String query) async {
    await _analytics.logEvent(
      name: 'job_search',
      parameters: {
        'query': query,
      },
    );
  }
}
