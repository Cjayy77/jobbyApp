import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/job_recommendations_provider.dart';
import 'job_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';

class JobRecommendations extends ConsumerWidget {
  const JobRecommendations({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendations = ref.watch(jobRecommendationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Recommended for You',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        recommendations.when(
          data: (jobs) {
            if (jobs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Complete your job preferences to get personalized recommendations',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  final job = jobs[index];
                  return SizedBox(
                    width: 300,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: JobCard(
                        job: job,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/job-details',
                          arguments: job,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(
            height: 200,
            child: Center(child: LoadingIndicator()),
          ),
          error: (error, stack) => SizedBox(
            height: 200,
            child: Center(
              child: ErrorView(
                message: 'Error loading recommendations',
                onRetry: () => ref.invalidate(jobRecommendationsProvider),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
