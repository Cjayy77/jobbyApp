import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile.dart';

final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<Profile?>>((ref) {
  return ProfileNotifier();
});

class ProfileNotifier extends StateNotifier<AsyncValue<Profile?>> {
  ProfileNotifier() : super(const AsyncValue.data(null));

  final _firestore = FirebaseFirestore.instance;

  Future<void> loadProfile(String userId) async {
    try {
      state = const AsyncValue.loading();
      final doc = await _firestore.collection('profiles').doc(userId).get();
      if (doc.exists) {
        state = AsyncValue.data(Profile.fromFirestore(doc));
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      print('Error loading profile: $e');
    }
  }

  Future<void> createProfile({
    required String name,
    required String email,
    required bool isJobSeeker,
    String? userId,
  }) async {
    try {
      state = const AsyncValue.loading();
      final profile = Profile(
        id: userId ?? '',
        name: name,
        email: email,
        isJobSeeker: isJobSeeker,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('profiles')
          .doc(userId)
          .set(profile.toFirestore());

      state = AsyncValue.data(profile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      print('Error creating profile: $e');
      rethrow;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
    String? about,
    String? companyName,
    String? location,
    String? website,
  }) async {
    try {
      state.whenData((profile) async {
        if (profile == null) return;

        final updatedProfile = profile.copyWith(
          name: name,
          phone: phone,
          photoUrl: photoUrl,
          about: about,
          companyName: companyName,
          location: location,
          website: website,
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection('profiles')
            .doc(profile.id)
            .update(updatedProfile.toFirestore());

        state = AsyncValue.data(updatedProfile);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      print('Error updating profile: $e');
      rethrow;
    }
  }

  Future<void> toggleSavedJob(String jobId) async {
    try {
      state.whenData((profile) async {
        if (profile == null) return;

        final savedJobs = List<String>.from(profile.savedJobs);
        if (savedJobs.contains(jobId)) {
          savedJobs.remove(jobId);
        } else {
          savedJobs.add(jobId);
        }

        final updatedProfile = profile.copyWith(savedJobs: savedJobs);

        await _firestore
            .collection('profiles')
            .doc(profile.id)
            .update({'savedJobs': savedJobs});

        state = AsyncValue.data(updatedProfile);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      print('Error toggling saved job: $e');
    }
  }

  Future<void> deleteProfile() async {
    try {
      state.whenData((profile) async {
        if (profile == null) return;

        await _firestore.collection('profiles').doc(profile.id).delete();
        state = const AsyncValue.data(null);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      print('Error deleting profile: $e');
      rethrow;
    }
  }
}
