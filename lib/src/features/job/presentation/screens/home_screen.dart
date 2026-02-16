import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/jobs_provider.dart';
import '../../services/ad_service.dart';
import '../../services/job_recommendation_service.dart';
import '../widgets/job_search_bar.dart';
import '../widgets/job_card.dart';
import '../../../events/presentation/screens/events_screen.dart';
import '../../../chat/presentation/screens/chat_list_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../notifications/providers/notifications_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  final _scrollController = ScrollController();
  final _adService = AdService();
  final _loadedAds = <int, NativeAd>{};

  @override
  void initState() {
    super.initState();
    _adService.initialize();
  }

  @override
  void dispose() {
    _loadedAds.forEach((_, ad) => ad.dispose());
    _scrollController.dispose();
    super.dispose();
  }

  void _loadAd(int index) {
    if (_adService.shouldShowAd(index) && !_loadedAds.containsKey(index)) {
      final ad = _adService.createJobListAd();
      _loadedAds[index] = ad;
      ad.load();
    }
  }

  Widget _buildNotificationIcon() {
    final notifications = ref.watch(notificationsProvider);
    return notifications.when(
      data: (notifications) {
        final unreadCount = notifications.where((n) => !n.isRead).length;
        if (unreadCount == 0) {
          return const Icon(Icons.notifications_outlined);
        }
        return Badge(
          label: Text('$unreadCount'),
          child: const Icon(Icons.notifications_outlined),
        );
      },
      loading: () => const Icon(Icons.notifications_outlined),
      error: (_, __) => const Icon(Icons.notifications_outlined),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobsState = ref.watch(jobsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobby'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Jobs Tab
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: JobSearchBar(),
              ),
              Expanded(
                child: jobsState.when(
                  data: (jobs) {
                    if (jobs.isEmpty) {
                      return const Center(
                        child: Text('No jobs found'),
                      );
                    }

                    // Get recommended jobs
                    final recommendationService =
                        ref.read(jobRecommendationProvider);
                    final recommendedJobs =
                        recommendationService.getRecommendedJobs(jobs);
                    final regularJobs = jobs
                        .where((job) => !recommendedJobs.contains(job))
                        .toList();

                    return RefreshIndicator(
                      onRefresh: () =>
                          ref.read(jobsProvider.notifier).loadJobs(),
                      child: ListView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (recommendedJobs.isNotEmpty) ...[
                            Text(
                              'Recommended for You',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            ...recommendedJobs
                                .map((job) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      child: JobCard(
                                        job: job,
                                        onTap: () => Navigator.pushNamed(
                                          context,
                                          '/job-details',
                                          arguments: job,
                                        ),
                                        isRecommended: true,
                                      ),
                                    ))
                                .toList(),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(),
                            ),
                            Text(
                              'All Jobs',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          ...regularJobs.asMap().entries.map((entry) {
                            final index = entry.key;
                            final job = entry.value;
                            _loadAd(index);

                            if (_adService.shouldShowAd(index)) {
                              return Column(
                                children: [
                                  if (_loadedAds.containsKey(index))
                                    Container(
                                      height: 120,
                                      margin: const EdgeInsets.only(bottom: 16),
                                      child: AdWidget(ad: _loadedAds[index]!),
                                    ),
                                  JobCard(
                                    job: job,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      '/job-details',
                                      arguments: job,
                                    ),
                                  ),
                                ],
                              );
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: JobCard(
                                job: job,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/job-details',
                                  arguments: job,
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stack) => Center(
                    child: Text('Error: $error'),
                  ),
                ),
              ),
            ],
          ),
          // Events Tab
          const EventsScreen(),
          // Messages Tab
          const ChatListScreen(),
          // Notifications Tab
          const NotificationsScreen(),
          // Settings Tab
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: 'Jobs',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: _buildNotificationIcon(),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
