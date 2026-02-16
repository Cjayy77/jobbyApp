import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_preferences.dart';

final jobPreferencesProvider =
    StateNotifierProvider<JobPreferencesNotifier, AsyncValue<JobPreferences?>>(
        (ref) {
  return JobPreferencesNotifier();
});

class JobPreferencesNotifier
    extends StateNotifier<AsyncValue<JobPreferences?>> {
  JobPreferencesNotifier() : super(const AsyncValue.data(null));

  final _firestore = FirebaseFirestore.instance;

  Future<void> loadPreferences(String userId) async {
    try {
      state = const AsyncValue.loading();
      final doc =
          await _firestore.collection('jobPreferences').doc(userId).get();

      if (doc.exists) {
        state = AsyncValue.data(JobPreferences.fromFirestore(doc));
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updatePreferences(
      String userId, JobPreferences preferences) async {
    try {
      await _firestore
          .collection('jobPreferences')
          .doc(userId)
          .set(preferences.toFirestore());

      state = AsyncValue.data(preferences);

      // Update the user's hasSetPreferences flag
      await _firestore
          .collection('profiles')
          .doc(userId)
          .update({'hasSetPreferences': true});
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> resetPreferences(String userId) async {
    try {
      await _firestore.collection('jobPreferences').doc(userId).delete();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
