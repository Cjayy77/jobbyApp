import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/job.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../profile/providers/profile_provider.dart';
import '../../../../core/widgets/error_dialog.dart';

class JobDetailsScreen extends ConsumerWidget {
  final Job job;

  const JobDetailsScreen({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final profile = ref.watch(profileProvider).asData?.value;
    final isSaved = profile?.savedJobs.contains(job.id) ?? false;
    final isEmployer = profile?.id == job.employerId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          if (!isEmployer && user != null)
            IconButton(
              icon: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_outline,
                color: isSaved ? Theme.of(context).primaryColor : null,
              ),
              onPressed: () {
                ref.read(profileProvider.notifier).toggleSavedJob(job.id);
              },
            ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (job.imageUrl != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    job.imageUrl!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              job.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              job.company,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              Icons.location_on_outlined,
              job.location,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              Icons.access_time,
              _formatDuration(job.duration),
            ),
            if (job.salary != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.attach_money,
                'XAF ${job.salary!.toStringAsFixed(0)}',
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Job Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(job.description),
            if (job.requirements.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Requirements',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...job.requirements.map((requirement) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(requirement)),
                    ],
                  ),
                );
              }),
            ],
            if (job.benefits.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Benefits',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...job.benefits.map((benefit) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.star, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(benefit)),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 24),
            Text(
              'Categories',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: job.categories.map((category) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            if (!isEmployer && user != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _apply(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Apply Now'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  String _formatDuration(JobDuration duration) {
    switch (duration) {
      case JobDuration.fullTime:
        return 'Full Time';
      case JobDuration.partTime:
        return 'Part Time';
      case JobDuration.contract:
        return 'Contract';
      case JobDuration.temporary:
        return 'Temporary';
    }
  }

  Future<void> _apply(BuildContext context) async {
    try {
      final result = await Navigator.pushNamed(
        context,
        '/job-application',
        arguments: job.id,
      );

      if (result == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        await ErrorDialog.show(
          context,
          error: e,
          title: 'Application Error',
        );
      }
    }
  }
}
