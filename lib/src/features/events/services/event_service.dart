import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Event>> getFilteredEvents() async {
    final now = DateTime.now();
    final snapshot = await _firestore
        .collection('events')
        .where('endDate',
            isGreaterThanOrEqualTo: now.subtract(const Duration(days: 3)))
        .get();

    return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
  }

  // ...existing code...
}
