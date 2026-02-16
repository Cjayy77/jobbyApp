import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/job_application.dart';
import '../../models/application_status.dart';
import '../../providers/job_applications_provider.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';

class ApplicationTrackingScreen extends ConsumerStatefulWidget {
  const ApplicationTrackingScreen({super.key});

  @override
  ConsumerState<ApplicationTrackingScreen> createState() =>
      _ApplicationTrackingScreenState();
}

class _ApplicationTrackingScreenState
    extends ConsumerState<ApplicationTrackingScreen> {
  ApplicationStatus _selectedFilter = ApplicationStatus.pending;

  Future<void> _loadApplications() async {
    ref.invalidate(jobApplicationsProvider);
  }

  Color getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return Colors.orange;
      case ApplicationStatus.reviewing:
        return Colors.blue;
      case ApplicationStatus.interviewed:
        return Colors.purple;
      case ApplicationStatus.accepted:
        return Colors.green;
      case ApplicationStatus.rejected:
        return Colors.red;
      case ApplicationStatus.withdrawn:
        return Colors.grey;
    }
  }

  String getStatusText(ApplicationStatus status) {
    return status.name[0].toUpperCase() + status.name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final applicationsState = ref.watch(jobApplicationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadApplications,
        child: applicationsState.when(
          data: (applications) {
            final filteredApplications = applications
                .where((app) => app.status == _selectedFilter)
                .toList();

            if (filteredApplications.isEmpty) {
              return Center(
                child: Text('No ${_selectedFilter.name} applications'),
              );
            }

            return Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: ApplicationStatus.values.map((status) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: _selectedFilter == status,
                          label: Text(getStatusText(status)),
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = status;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredApplications.length,
                    itemBuilder: (context, index) {
                      final application = filteredApplications[index];
                      return Card(
                        child: ListTile(
                          title:
                              Text(application.jobTitle ?? 'Job Application'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Applied ${timeago.format(application.appliedAt)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: getStatusColor(application.status)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  getStatusText(application.status),
                                  style: TextStyle(
                                    color: getStatusColor(application.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () =>
                                _showApplicationOptions(application),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const LoadingIndicator(),
          error: (error, stack) => ErrorView(
            message: 'Error loading applications',
            onRetry: _loadApplications,
          ),
        ),
      ),
    );
  }

  Future<void> _showApplicationOptions(JobApplication application) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Application Options'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'view'),
            child: const Text('View Details'),
          ),
          if (application.status == ApplicationStatus.pending)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'withdraw'),
              child: const Text(
                'Withdraw Application',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );

    if (!mounted) return;

    switch (result) {
      case 'view':
        // Navigate to application details
        break;
      case 'withdraw':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Withdraw Application'),
            content: const Text(
              'Are you sure you want to withdraw this application? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Withdraw',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await ref
              .read(jobApplicationsProvider.notifier)
              .withdrawApplication(application.id);
        }
        break;
    }
  }
}
