import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../providers/events_provider.dart';
import '../../providers/event_search_provider.dart';
import '../widgets/event_card.dart';
import '../widgets/event_search_bar.dart';
import '../../../../core/services/ad_manager.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  final _adService = AdManager();
  final Map<int, NativeAd> _loadedAds = {};
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeAds();
  }

  Future<void> _initializeAds() async {
    await _adService.initialize();
  }

  void _loadAd(int index) {
    if (_adService.shouldShowAd(index) && !_loadedAds.containsKey(index)) {
      final ad = _adService.createNativeAd();
      _loadedAds[index] = ad;
      ad.load();
    }
  }

  @override
  void dispose() {
    _loadedAds.forEach((_, ad) => ad.dispose());
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(filteredEventsProvider);
    final selectedCategory = ref.watch(eventCategoryFilterProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Text('Upcoming Events',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  FilledButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/event-creation'),
                    child: const Text('Create Event'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              EventSearchBar(
                onSearch: (query) =>
                    ref.read(eventSearchProvider.notifier).state = query,
                onCategorySelected: (category) => ref
                    .read(eventCategoryFilterProvider.notifier)
                    .state = category.isEmpty ? null : category,
                categories: const [
                  'Music',
                  'Sports',
                  'Arts',
                  'Food',
                  'Business',
                  'Tech',
                  'Education',
                  'Other'
                ],
                selectedCategory: selectedCategory,
              ),
            ],
          ),
        ),
        Expanded(
          child: eventsState.when(
            data: (events) {
              if (events.isEmpty) {
                return const Center(
                  child: Text('No events found'),
                );
              }

              return RefreshIndicator(
                onRefresh: () => ref.read(eventsProvider.notifier).loadEvents(),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length +
                      (events.length ~/ 6), // Show ad every 6 items
                  itemBuilder: (context, index) {
                    if (index > 0 && index % 7 == 6) {
                      // Show ad after every 6 events
                      _loadAd(index);
                      return _loadedAds[index] != null
                          ? Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: AdWidget(ad: _loadedAds[index]!),
                            )
                          : const SizedBox();
                    }

                    final adjustedIndex = index - (index ~/ 7);
                    final event = events[adjustedIndex];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: EventCard(
                        title: event.title,
                        organizerName: event.organizerName,
                        location: event.location,
                        startDate: event.startDate,
                        endDate: event.endDate,
                        imageUrl: event.imageUrl,
                        categories: event.categories,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/event-details',
                          arguments: event,
                        ),
                        isSaved: event.isSaved ?? false,
                        onSaveToggle: () {
                          ref
                              .read(eventsProvider.notifier)
                              .toggleEventSaved(event.id);
                        },
                        ticketPrice: event.ticketPrice,
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),
      ],
    );
  }
}
