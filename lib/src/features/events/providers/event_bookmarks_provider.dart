import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

final eventBookmarksProvider =
    StateNotifierProvider<EventBookmarksNotifier, AsyncValue<List<String>>>(
        (ref) {
  return EventBookmarksNotifier();
});

class EventBookmarksNotifier extends StateNotifier<AsyncValue<List<String>>> {
  EventBookmarksNotifier() : super(const AsyncValue.data([]));

  final _firestore = FirebaseFirestore.instance;

  Future<void> loadBookmarks(String userId) async {
    try {
      state = const AsyncValue.loading();

      final doc = await _firestore.collection('users').doc(userId).get();
      final bookmarks =
          List<String>.from(doc.data()?['bookmarkedEvents'] ?? []);

      state = AsyncValue.data(bookmarks);
    } catch (e, stack) {
      print('Error loading bookmarks: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleBookmark(String userId, String eventId) async {
    try {
      state.whenData((bookmarks) async {
        List<String> updatedBookmarks;

        if (bookmarks.contains(eventId)) {
          updatedBookmarks = bookmarks.where((id) => id != eventId).toList();
        } else {
          updatedBookmarks = [...bookmarks, eventId];
        }

        await _firestore.collection('users').doc(userId).update({
          'bookmarkedEvents': updatedBookmarks,
        });

        state = AsyncValue.data(updatedBookmarks);
      });
    } catch (e, stack) {
      print('Error toggling bookmark: $e');
      state = AsyncValue.error(e, stack);
    }
  }
}
