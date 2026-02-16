import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eventAttendanceProvider = StateNotifierProvider<EventAttendanceNotifier,
    AsyncValue<Map<String, bool>>>((ref) {
  return EventAttendanceNotifier();
});

class EventAttendanceNotifier
    extends StateNotifier<AsyncValue<Map<String, bool>>> {
  EventAttendanceNotifier() : super(const AsyncValue.data({}));

  final _firestore = FirebaseFirestore.instance;

  Future<void> toggleAttendance(
      String eventId, String userId, String eventTitle) async {
    try {
      final eventRef = _firestore.collection('events').doc(eventId);
      final userRef = _firestore.collection('users').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final eventDoc = await transaction.get(eventRef);
        final userDoc = await transaction.get(userRef);

        final attendees = List<String>.from(eventDoc.get('attendees') ?? []);
        final attending = attendees.contains(userId);

        if (attending) {
          attendees.remove(userId);
        } else {
          attendees.add(userId);
        }

        transaction.update(eventRef, {'attendees': attendees});

        // Update user's event registrations
        final userEvents =
            Map<String, dynamic>.from(userDoc.get('events') ?? {});
        if (attending) {
          userEvents.remove(eventId);
        } else {
          userEvents[eventId] = {
            'title': eventTitle,
            'registeredAt': DateTime.now(),
          };
        }

        transaction.update(userRef, {'events': userEvents});

        // Update local state
        state.whenData((registrations) {
          final newRegistrations = Map<String, bool>.from(registrations);
          newRegistrations[eventId] = !attending;
          state = AsyncValue.data(newRegistrations);
        });
      });
    } catch (e, stack) {
      print('Error toggling attendance: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadUserRegistrations(String userId) async {
    try {
      state = const AsyncValue.loading();
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final registeredEvents =
          Map<String, dynamic>.from(userDoc.get('events') ?? {});

      state = AsyncValue.data(
        registeredEvents.map((eventId, _) => MapEntry(eventId, true)),
      );
    } catch (e, stack) {
      print('Error loading user registrations: $e');
      state = AsyncValue.error(e, stack);
    }
  }
}
