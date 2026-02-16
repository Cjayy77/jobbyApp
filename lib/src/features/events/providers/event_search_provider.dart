import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';
import './events_provider.dart';

final eventSearchProvider = StateProvider<String>((ref) => '');
final eventCategoryFilterProvider = StateProvider<String?>((ref) => null);

final filteredEventsProvider = Provider<AsyncValue<List<Event>>>((ref) {
  final eventsState = ref.watch(eventsProvider);
  final searchQuery = ref.watch(eventSearchProvider).toLowerCase();
  final categoryFilter = ref.watch(eventCategoryFilterProvider);

  return eventsState.when(
    data: (events) {
      var filteredEvents = events;

      // Apply category filter
      if (categoryFilter != null && categoryFilter.isNotEmpty) {
        filteredEvents = filteredEvents
            .where(
              (event) => event.categories.contains(categoryFilter),
            )
            .toList();
      }

      // Apply search filter
      if (searchQuery.isNotEmpty) {
        filteredEvents = filteredEvents.where((event) {
          return event.title.toLowerCase().contains(searchQuery) ||
              event.description.toLowerCase().contains(searchQuery) ||
              event.location.toLowerCase().contains(searchQuery) ||
              event.organizerName.toLowerCase().contains(searchQuery);
        }).toList();
      }

      return AsyncValue.data(filteredEvents);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
