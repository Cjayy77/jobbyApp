import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final bool isJobSeeker;
  final List<String> savedJobs;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.isJobSeeker,
    this.savedJobs = const [],
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      isJobSeeker: data['isJobSeeker'] ?? true,
      savedJobs: List<String>.from(data['savedJobs'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'isJobSeeker': isJobSeeker,
      'savedJobs': savedJobs,
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    bool? isJobSeeker,
    List<String>? savedJobs,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isJobSeeker: isJobSeeker ?? this.isJobSeeker,
      savedJobs: savedJobs ?? this.savedJobs,
    );
  }
}