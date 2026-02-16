import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'job_preferences.dart';

enum JobDuration { fullTime, partTime, contract, temporary }

@immutable
class Job {
  final String id;
  final String title;
  final String description;
  final String company;
  final String location;
  final double? salary;
  final JobDuration duration;
  final String employerId;
  final String? imageUrl;
  final List<String> categories;
  final DateTime postedDate;
  final bool isActive;
  final bool isSaved;
  final List<String> applicants;
  final List<String> requirements;
  final List<String> benefits;
  final String status;

  const Job({
    required this.id,
    required this.title,
    required this.description,
    required this.company,
    required this.location,
    this.salary,
    required this.duration,
    required this.employerId,
    this.imageUrl,
    required this.categories,
    required this.postedDate,
    this.isActive = true,
    this.isSaved = false,
    this.applicants = const [],
    this.requirements = const [],
    this.benefits = const [],
    this.status = 'open',
  });

  Job copyWith({
    String? id,
    String? title,
    String? description,
    String? company,
    String? location,
    double? salary,
    JobDuration? duration,
    String? employerId,
    String? imageUrl,
    List<String>? categories,
    DateTime? postedDate,
    bool? isActive,
    bool? isSaved,
    List<String>? applicants,
    List<String>? requirements,
    List<String>? benefits,
    String? status,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      company: company ?? this.company,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      duration: duration ?? this.duration,
      employerId: employerId ?? this.employerId,
      imageUrl: imageUrl ?? this.imageUrl,
      categories: categories ?? this.categories,
      postedDate: postedDate ?? this.postedDate,
      isActive: isActive ?? this.isActive,
      isSaved: isSaved ?? this.isSaved,
      applicants: applicants ?? this.applicants,
      requirements: requirements ?? this.requirements,
      benefits: benefits ?? this.benefits,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'company': company,
      'location': location,
      'salary': salary,
      'duration': duration.toString().split('.').last,
      'employerId': employerId,
      'imageUrl': imageUrl,
      'categories': categories,
      'postedDate': Timestamp.fromDate(postedDate),
      'isActive': isActive,
      'applicants': applicants,
      'requirements': requirements,
      'benefits': benefits,
      'status': status,
    };
  }

  factory Job.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Job(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String,
      company: data['company'] as String,
      location: data['location'] as String,
      salary: data['salary'] as double?,
      duration: JobDuration.values.firstWhere(
        (e) => e.toString().split('.').last == data['duration'],
      ),
      employerId: data['employerId'] as String,
      imageUrl: data['imageUrl'] as String?,
      categories: (data['categories'] as List<dynamic>).cast<String>(),
      postedDate: (data['postedDate'] as Timestamp).toDate(),
      isActive: data['isActive'] as bool? ?? true,
      applicants: (data['applicants'] as List<dynamic>?)?.cast<String>() ?? [],
      requirements:
          (data['requirements'] as List<dynamic>?)?.cast<String>() ?? [],
      benefits: (data['benefits'] as List<dynamic>?)?.cast<String>() ?? [],
      status: data['status'] as String? ?? 'open',
    );
  }

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      company: json['company'] as String,
      location: json['location'] as String,
      salary: json['salary'] as double?,
      duration: JobDuration.values.firstWhere(
        (e) => e.toString().split('.').last == json['duration'],
      ),
      employerId: json['employerId'] as String,
      imageUrl: json['imageUrl'] as String?,
      categories: (json['categories'] as List<dynamic>).cast<String>(),
      postedDate: DateTime.parse(json['postedDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      applicants: (json['applicants'] as List<dynamic>?)?.cast<String>() ?? [],
      requirements:
          (json['requirements'] as List<dynamic>?)?.cast<String>() ?? [],
      benefits: (json['benefits'] as List<dynamic>?)?.cast<String>() ?? [],
      status: json['status'] as String? ?? 'open',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'company': company,
      'location': location,
      'salary': salary,
      'duration': describeEnum(duration),
      'employerId': employerId,
      'imageUrl': imageUrl,
      'categories': categories,
      'postedDate': Timestamp.fromDate(postedDate),
      'isActive': isActive,
      'isSaved': isSaved,
      'applicants': applicants,
      'requirements': requirements,
      'benefits': benefits,
      'status': status,
    };
  }

  bool matches(JobPreferences preferences) {
    if (preferences.remoteOnly && !location.toLowerCase().contains('remote')) {
      return false;
    }

    if (preferences.preferredCategories.isNotEmpty &&
        !categories.any((c) => preferences.preferredCategories.contains(c))) {
      return false;
    }

    if (preferences.preferredLocations.isNotEmpty &&
        !preferences.preferredLocations.contains(location)) {
      return false;
    }

    if (preferences.minimumSalary != null &&
        (salary == null || salary! < preferences.minimumSalary!)) {
      return false;
    }

    if (preferences.preferredDurations.isNotEmpty &&
        !preferences.preferredDurations.contains(duration)) {
      return false;
    }

    return true;
  }
}
