import 'package:flutter_test/flutter_test.dart';

class SimpleJobService {
  final List<Map<String, dynamic>> fakeDatabase = [];

  Future<void> applyForJob(String jobId, String userId, String jobTitle) async {
    fakeDatabase.add({
      'jobId': jobId,
      'userId': userId,
      'status': 'pending',
      'appliedAt': DateTime.now(),
    });
  }

  Future<String?> getApplicationStatus(String jobId, String userId) async {
    final application = fakeDatabase.firstWhere(
      (app) => app['jobId'] == jobId && app['userId'] == userId,
      orElse: () => {},
    );
    return application['status'];
  }
}

void main() {
  late SimpleJobService jobService;

  setUp(() {
    jobService = SimpleJobService();
  });

  group('Job Application Tests', () {
    final jobId = 'test-job-id';
    final userId = 'test-user-id';
    final jobTitle = 'Software Developer';

    test('applyForJob should create application', () async {
      await jobService.applyForJob(jobId, userId, jobTitle);

      final status = await jobService.getApplicationStatus(jobId, userId);
      expect(status, equals('pending'));
    });

    test('getApplicationStatus should return null when no application exists',
        () async {
      final status =
          await jobService.getApplicationStatus('non-existent-job', userId);
      expect(status, isNull);
    });
  });
}
