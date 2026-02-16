import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../../../features/auth/providers/auth_provider.dart';

final eventsProvider =
    StateNotifierProvider<EventsNotifier, AsyncValue<List<Event>>>((ref) {
  return EventsNotifier(ref);
});

class EventsNotifier extends StateNotifier<AsyncValue<List<Event>>> {
  EventsNotifier(this.ref) : super(const AsyncValue.data([]));

  final Ref ref;
  final _firestore = FirebaseFirestore.instance;

  Future<void> loadEvents({String? category}) async {
    try {
      state = const AsyncValue.loading();
      
      Query query = _firestore.collection('events')
          .orderBy('startDateTime');
      
      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      final querySnapshot = await query.get();
      final events = querySnapshot.docs
          .map((doc) => Event.fromFirestore(doc))
          .toList();

      state = AsyncValue.data(events);
    } catch (e, stack) {
      print('Error loading events: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<String> createEvent(Event event) async {
    try {
      final docRef = await _firestore.collection('events').add(event.toFirestore());
      
      state.whenData((events) {
        final newEvent = Event(
          id: docRef.id,          title: event.title,
          description: event.description,
          organizerId: event.organizerId,
          organizerName: event.organizerName,
          location: event.location,
          categories: event.categories,
          startDateTime: event.startDateTime,
          endDateTime: event.endDateTime,
          maxAttendees: event.maxAttendees,
          attendees: event.attendees,
          imageUrl: event.imageUrl,
          ticketPrice: event.ticketPrice,
          createdAt: event.createdAt,
          updatedAt: event.updatedAt,
        );
        
        state = AsyncValue.data([...events, newEvent]);
      });

      return docRef.id;
    } catch (e, stack) {
      print('Error creating event: $e');
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> updateEvent(Event event) async {
    try {
      await _firestore
          .collection('events')
          .doc(event.id)
          .update(event.toFirestore());

      state.whenData((events) {
        final updatedEvents = events.map((e) {
          return e.id == event.id ? event : e;
        }).toList();
        
        state = AsyncValue.data(updatedEvents);
      });
    } catch (e, stack) {
      print('Error updating event: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();

      state.whenData((events) {
        final updatedEvents = events.where((e) => e.id != eventId).toList();
        state = AsyncValue.data(updatedEvents);
      });
    } catch (e, stack) {
      print('Error deleting event: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleAttendance(String eventId, String userId) async {
    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      final event = Event.fromFirestore(eventDoc);
      
      List<String> updatedAttendees;
      if (event.attendees.contains(userId)) {
        updatedAttendees = event.attendees.where((id) => id != userId).toList();
      } else {
        if (event.attendees.length >= event.maxAttendees) {
          throw Exception('Event has reached maximum attendees limit');
        }
        updatedAttendees = [...event.attendees, userId];
      }

      final updatedEvent = event.copyWith(
        attendees: updatedAttendees,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('events')
          .doc(eventId)
          .update(updatedEvent.toFirestore());

      state.whenData((events) {
        final updatedEvents = events.map((e) {
          return e.id == eventId ? updatedEvent : e;
        }).toList();
        
        state = AsyncValue.data(updatedEvents);
      });
    } catch (e, stack) {
      print('Error toggling attendance: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<List<Event>> searchEvents({
    String? query,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query eventsQuery = _firestore.collection('events');

      if (category != null) {
        eventsQuery = eventsQuery.where('category', isEqualTo: category);
      }

      if (startDate != null) {
        eventsQuery = eventsQuery.where('startDateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        eventsQuery = eventsQuery.where('startDateTime',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final querySnapshot = await eventsQuery.get();
      var events = querySnapshot.docs
          .map((doc) => Event.fromFirestore(doc))
          .toList();

      if (query != null && query.isNotEmpty) {
        final lowercaseQuery = query.toLowerCase();
        events = events.where((event) {
          return event.title.toLowerCase().contains(lowercaseQuery) ||
              event.description.toLowerCase().contains(lowercaseQuery) ||
              event.location.toLowerCase().contains(lowercaseQuery);
        }).toList();
      }

      return events;
    } catch (e) {
      print('Error searching events: $e');
      rethrow;
    }
  }

  Future<void> registerForEvent(String eventId) async {
    try {
      final user = ref.read(authProvider);
      if (user == null) {
        throw Exception('User must be logged in to register for events');
      }

      await toggleAttendance(eventId, user.uid);
    } catch (e, stack) {
      print('Error registering for event: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleEventSaved(String eventId) async {
    try {
      state.whenData((events) {
        final eventIndex = events.indexWhere((e) => e.id == eventId);
        if (eventIndex != -1) {
          final event = events[eventIndex];
          final updatedEvent = event.copyWith(
            isSaved: !(event.isSaved ?? false),
            updatedAt: DateTime.now(),
          );
          
          final updatedEvents = List<Event>.from(events);
          updatedEvents[eventIndex] = updatedEvent;
          state = AsyncValue.data(updatedEvents);
          
          _firestore
              .collection('events')
              .doc(eventId)
              .update({'isSaved': updatedEvent.isSaved});
        }
      });
    } catch (e, stack) {
      print('Error toggling event saved status: $e');
      state = AsyncValue.error(e, stack);
    }
  }
}
