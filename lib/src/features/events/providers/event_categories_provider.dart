import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final eventCategoriesProvider =
    StateNotifierProvider<EventCategoriesNotifier, AsyncValue<List<String>>>(
        (ref) {
  return EventCategoriesNotifier();
});

class EventCategoriesNotifier extends StateNotifier<AsyncValue<List<String>>> {
  EventCategoriesNotifier() : super(const AsyncValue.data([]));

  final _firestore = FirebaseFirestore.instance;

  Future<void> loadCategories() async {
    try {
      state = const AsyncValue.loading();

      final doc =
          await _firestore.collection('settings').doc('categories').get();
      final categories =
          List<String>.from(doc.data()?['eventCategories'] ?? []);

      state = AsyncValue.data(categories);
    } catch (e, stack) {
      print('Error loading categories: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addCategory(String category) async {
    try {
      state.whenData((categories) async {
        if (!categories.contains(category)) {
          final updatedCategories = [...categories, category];

          await _firestore.collection('settings').doc('categories').set({
            'eventCategories': updatedCategories,
          }, SetOptions(merge: true));

          state = AsyncValue.data(updatedCategories);
        }
      });
    } catch (e, stack) {
      print('Error adding category: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> removeCategory(String category) async {
    try {
      state.whenData((categories) async {
        final updatedCategories =
            categories.where((c) => c != category).toList();

        await _firestore.collection('settings').doc('categories').set({
          'eventCategories': updatedCategories,
        }, SetOptions(merge: true));

        state = AsyncValue.data(updatedCategories);
      });
    } catch (e, stack) {
      print('Error removing category: $e');
      state = AsyncValue.error(e, stack);
    }
  }
}
