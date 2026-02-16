import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'job.dart';

@immutable
class JobPreferences {
  final List<String> preferredLocations;
  final List<String> preferredCategories;
  final List<JobDuration> preferredDurations;
  final double? minimumSalary;
  final bool remoteOnly;

  const JobPreferences({
    this.preferredLocations = const [],
    this.preferredCategories = const [],
    this.preferredDurations = const [],
    this.minimumSalary,
    this.remoteOnly = false,
  });

  JobPreferences copyWith({
    List<String>? preferredLocations,
    List<String>? preferredCategories,
    List<JobDuration>? preferredDurations,
    double? minimumSalary,
    bool? remoteOnly,
  }) {
    return JobPreferences(
      preferredLocations: preferredLocations ?? this.preferredLocations,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      preferredDurations: preferredDurations ?? this.preferredDurations,
      minimumSalary: minimumSalary ?? this.minimumSalary,
      remoteOnly: remoteOnly ?? this.remoteOnly,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferredLocations': preferredLocations,
      'preferredCategories': preferredCategories,
      'preferredDurations':
          preferredDurations.map((d) => d.toString().split('.').last).toList(),
      'minimumSalary': minimumSalary,
      'remoteOnly': remoteOnly,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'preferredLocations': preferredLocations,
      'preferredCategories': preferredCategories,
      'preferredDurations':
          preferredDurations.map((d) => d.toString().split('.').last).toList(),
      'minimumSalary': minimumSalary,
      'remoteOnly': remoteOnly,
    };
  }

  factory JobPreferences.fromJson(Map<String, dynamic> json) {
    return JobPreferences(
      preferredLocations:
          (json['preferredLocations'] as List<dynamic>?)?.cast<String>() ?? [],
      preferredCategories:
          (json['preferredCategories'] as List<dynamic>?)?.cast<String>() ?? [],
      preferredDurations: ((json['preferredDurations'] as List<dynamic>?) ?? [])
          .map((d) => JobDuration.values.firstWhere(
                (e) => e.toString().split('.').last == d,
              ))
          .toList(),
      minimumSalary: json['minimumSalary'] as double?,
      remoteOnly: json['remoteOnly'] as bool? ?? false,
    );
  }

  factory JobPreferences.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobPreferences(
      preferredLocations:
          (data['preferredLocations'] as List<dynamic>?)?.cast<String>() ?? [],
      preferredCategories:
          (data['preferredCategories'] as List<dynamic>?)?.cast<String>() ?? [],
      preferredDurations: ((data['preferredDurations'] as List<dynamic>?) ?? [])
          .map((d) => JobDuration.values.firstWhere(
                (e) => e.toString().split('.').last == d,
              ))
          .toList(),
      minimumSalary: data['minimumSalary'] as double?,
      remoteOnly: data['remoteOnly'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JobPreferences &&
        listEquals(other.preferredLocations, preferredLocations) &&
        listEquals(other.preferredCategories, preferredCategories) &&
        listEquals(other.preferredDurations, preferredDurations) &&
        other.minimumSalary == minimumSalary &&
        other.remoteOnly == remoteOnly;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(preferredLocations),
        Object.hashAll(preferredCategories),
        Object.hashAll(preferredDurations),
        minimumSalary,
        remoteOnly,
      );
}
