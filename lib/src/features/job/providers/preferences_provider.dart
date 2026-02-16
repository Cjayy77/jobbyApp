import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job_preferences.dart';

final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, JobPreferences>((ref) {
  return PreferencesNotifier();
});

class PreferencesNotifier extends StateNotifier<JobPreferences> {
  PreferencesNotifier() : super(const JobPreferences()) {
    _loadPreferences();
  }

  static const _prefsKey = 'job_preferences';

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsJson = prefs.getString(_prefsKey);
    if (prefsJson != null) {
      try {
        final map = Map<String, dynamic>.from(
            Map.from(const JsonDecoder().convert(prefsJson)));
        state = JobPreferences.fromJson(map);
      } catch (e) {
        print('Error loading preferences: $e');
      }
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _prefsKey, const JsonEncoder().convert(state.toJson()));
  }

  void updateCategories(List<String> categories) {
    state = state.copyWith(preferredCategories: categories);
    _savePreferences();
  }

  void updateLocations(List<String> locations) {
    state = state.copyWith(preferredLocations: locations);
    _savePreferences();
  }

  void updateSalaryRange(double? min, double? max) {
    state = state.copyWith(minimumSalary: min);
    _savePreferences();
  }

  void toggleRemoteOnly() {
    state = state.copyWith(remoteOnly: !state.remoteOnly);
    _savePreferences();
  }

  void clearPreferences() {
    state = const JobPreferences();
    _savePreferences();
  }
}
