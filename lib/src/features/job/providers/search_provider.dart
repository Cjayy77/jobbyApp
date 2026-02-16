import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/job.dart';
import 'jobs_provider.dart';

class SearchFilters {
  final String? query;
  final bool? isRemote;
  final List<String>? jobTypes;
  final String? location;
  final double? minSalary;

  const SearchFilters({
    this.query,
    this.isRemote,
    this.jobTypes,
    this.location,
    this.minSalary,
  });

  SearchFilters copyWith({
    String? query,
    bool? isRemote,
    List<String>? jobTypes,
    String? location,
    double? minSalary,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      isRemote: isRemote ?? this.isRemote,
      jobTypes: jobTypes ?? this.jobTypes,
      location: location ?? this.location,
      minSalary: minSalary ?? this.minSalary,
    );
  }
}

final searchFiltersProvider = StateProvider<SearchFilters>((ref) {
  return const SearchFilters();
});

final searchResultsProvider = FutureProvider<List<Job>>((ref) async {
  final filters = ref.watch(searchFiltersProvider);
  final jobsAsyncValue = ref.watch(jobsProvider);

  return jobsAsyncValue.when(
    data: (jobs) => jobs.where((job) {
      if (filters.query != null && filters.query!.isNotEmpty) {
        final query = filters.query!.toLowerCase();
        if (!job.title.toLowerCase().contains(query) &&
            !job.company.toLowerCase().contains(query) &&
            !job.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      if (filters.isRemote == true &&
          !job.location.toLowerCase().contains('remote')) {
        return false;
      }

      if (filters.jobTypes != null && filters.jobTypes!.isNotEmpty) {
        final jobType = job.duration.toString().split('.').last;
        if (!filters.jobTypes!.contains(jobType)) {
          return false;
        }
      }

      if (filters.location != null &&
          filters.location!.isNotEmpty &&
          !job.location
              .toLowerCase()
              .contains(filters.location!.toLowerCase())) {
        return false;
      }

      if (filters.minSalary != null &&
          (job.salary == null || job.salary! < filters.minSalary!)) {
        return false;
      }

      return true;
    }).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});
