import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../job/providers/jobs_provider.dart';
import '../../providers/profile_provider.dart';
import '../../../job/presentation/widgets/job_card.dart';
import '../../../../core/services/storage_service.dart';
import '../../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateProfilePicture() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );

    if (image != null) {
      // TODO: Upload image to Firebase Storage and update profile
      final photoUrl = await _uploadImage(image);
      if (photoUrl != null) {
        ref.read(profileProvider.notifier).updateProfile(photoUrl: photoUrl);
      }
    }
  }

  Future<String?> _uploadImage(XFile image) async {
    try {
      final storageService = StorageService();
      final user = ref.read(authProvider);
      if (user == null) return null;

      final imageFile = File(image.path);
      final downloadUrl =
          await storageService.uploadProfileImage(user.uid, imageFile.path);
      return downloadUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final jobsState = ref.watch(jobsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: profileState.when(
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: Text('Please sign in to view your profile'),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _updateProfilePicture,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: profile.photoUrl != null
                            ? NetworkImage(profile.photoUrl!)
                            : null,
                        child: profile.photoUrl == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      profile.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(
                        profile.isJobSeeker ? 'Job Seeker' : 'Employer',
                      ),
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: [
                  const Tab(text: 'Profile'),
                  Tab(
                    text: profile.isJobSeeker ? 'Saved Jobs' : 'Posted Jobs',
                  ),
                  const Tab(text: 'Applications'),
                  const Tab(text: 'My Jobs'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Profile Tab
                    Center(child: Text('Profile Details Here')), // Placeholder

                    // My Jobs Tab
                    jobsState.when(
                      data: (jobs) {
                        final myJobs = jobs
                            .where((job) => job.employerId == profile.id)
                            .toList();
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: myJobs.length,
                          itemBuilder: (context, index) {
                            final job = myJobs[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: JobCard(
                                job: job,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/job-details',
                                  arguments: job,
                                ),
                                onSaveToggle: () {
                                  ref
                                      .read(profileProvider.notifier)
                                      .toggleSavedJob(job.id);
                                },
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) => Center(
                        child: Text('Error: $error'),
                      ),
                    ),

                    // Saved Jobs Tab
                    jobsState.when(
                      data: (jobs) {
                        final savedJobs =
                            jobs.where((job) => job.isSaved).toList();
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: savedJobs.length,
                          itemBuilder: (context, index) {
                            final job = savedJobs[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: JobCard(
                                job: job,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/job-details',
                                  arguments: job,
                                ),
                                onSaveToggle: () {
                                  ref
                                      .read(profileProvider.notifier)
                                      .toggleSavedJob(job.id);
                                },
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) => Center(
                        child: Text('Error: $error'),
                      ),
                    ),

                    // Applications Tab
                    const Center(
                      child: Text('Applications feature coming soon'),
                    ),

                    // Posted Jobs Tab
                    jobsState.when(
                      data: (jobs) {
                        final postedJobs = jobs
                            .where((job) => job.employerId == profile.id)
                            .toList();
                        return ListView.builder(
                          itemCount: postedJobs.length,
                          itemBuilder: (context, index) {
                            final job = postedJobs[index];
                            return ListTile(
                              title: Text(job.title),
                              subtitle: Text(job.company),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/edit-job',
                                        arguments: job,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      await ref
                                          .read(jobsProvider.notifier)
                                          .deleteJob(job.id);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) => Center(
                        child: Text('Error: $error'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
