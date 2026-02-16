import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final String? about;
  final bool isJobSeeker;
  final String? companyName;
  final String? location;
  final String? website;
  final List<String> savedJobs;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.about,
    required this.isJobSeeker,
    this.companyName,
    this.location,
    this.website,
    this.savedJobs = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Profile copyWith({
    String? name,
    String? phone,
    String? photoUrl,
    String? about,
    String? companyName,
    String? location,
    String? website,
    List<String>? savedJobs,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      about: about ?? this.about,
      isJobSeeker: isJobSeeker,
      companyName: companyName ?? this.companyName,
      location: location ?? this.location,
      website: website ?? this.website,
      savedJobs: savedJobs ?? this.savedJobs,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'about': about,
      'isJobSeeker': isJobSeeker,
      'companyName': companyName,
      'location': location,
      'website': website,
      'savedJobs': savedJobs,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Profile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Profile(
      id: doc.id,
      name: data['name'] as String,
      email: data['email'] as String,
      phone: data['phone'] as String?,
      photoUrl: data['photoUrl'] as String?,
      about: data['about'] as String?,
      isJobSeeker: data['isJobSeeker'] as bool,
      companyName: data['companyName'] as String?,
      location: data['location'] as String?,
      website: data['website'] as String?,
      savedJobs: List<String>.from(data['savedJobs'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}