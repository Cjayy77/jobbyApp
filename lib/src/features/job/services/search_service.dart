import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job.dart';
import '../../../core/services/analytics_service.dart';

class SearchService {
  final _firestore = FirebaseFirestore.instance;
  final _analyticsService = AnalyticsService();

  Future<List<Job>> searchJobs({
    String? query,
    List<String>? categories,
    List<String>? locations,
    double? minSalary,
    double? maxSalary,
    List<String>? jobTypes,
    bool? isRemote,
  }) async {
    try {
      // Start with base query
      Query jobsQuery = _firestore
          .collection('jobs')
          .where('isActive', isEqualTo: true)
          .orderBy('postedDate', descending: true);

      // Apply filters that can be done at database level
      if (minSalary != null) {
        jobsQuery =
            jobsQuery.where('salary', isGreaterThanOrEqualTo: minSalary);
      }

      if (maxSalary != null) {
        jobsQuery = jobsQuery.where('salary', isLessThanOrEqualTo: maxSalary);
      }

      if (isRemote != null) {
        jobsQuery = jobsQuery.where('isRemote', isEqualTo: isRemote);
      }

      // Execute query
      final snapshot = await jobsQuery.get();
      var jobs = snapshot.docs
          .map((doc) => Job.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();

      // Apply remaining filters that can't be done in query
      jobs = jobs.where((job) {
        // Text search
        if (query != null && query.isNotEmpty) {
          final searchText = query.toLowerCase();
          final titleMatch = job.title.toLowerCase().contains(searchText);
          final descriptionMatch =
              job.description.toLowerCase().contains(searchText);
          final companyMatch = job.company.toLowerCase().contains(searchText);
          if (!titleMatch && !descriptionMatch && !companyMatch) return false;
        }

        // Categories filter
        if (categories != null && categories.isNotEmpty) {
          if (!job.categories.any((cat) => categories.contains(cat)))
            return false;
        }

        // Locations filter
        if (locations != null && locations.isNotEmpty) {
          if (!locations.contains(job.location)) return false;
        }

        // Job types filter
        if (jobTypes != null && jobTypes.isNotEmpty) {
          if (!jobTypes.contains(job.duration.toString().split('.').last))
            return false;
        }

        return true;
      }).toList();

      // Log search analytics
      if (query != null && query.isNotEmpty) {
        await _analyticsService.logSearch(query);
      }

      return jobs;
    } catch (e) {
      print('Error searching jobs: $e');
      rethrow;
    }
  }
}
