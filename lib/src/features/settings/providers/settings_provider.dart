import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsState {
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final bool jobAlertsEnabled;
  final bool recommendationsEnabled;
  final String language;

  const SettingsState({
    required this.themeMode,
    required this.notificationsEnabled,
    required this.jobAlertsEnabled,
    required this.recommendationsEnabled,
    required this.language,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? jobAlertsEnabled,
    bool? recommendationsEnabled,
    String? language,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      jobAlertsEnabled: jobAlertsEnabled ?? this.jobAlertsEnabled,
      recommendationsEnabled:
          recommendationsEnabled ?? this.recommendationsEnabled,
      language: language ?? this.language,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
      : super(const SettingsState(
          themeMode: ThemeMode.system,
          notificationsEnabled: true,
          jobAlertsEnabled: true,
          recommendationsEnabled: true,
          language: 'en',
        )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    state = SettingsState(
      themeMode: ThemeMode.values.byName(
        prefs.getString('themeMode') ?? 'system',
      ),
      notificationsEnabled: prefs.getBool('notificationsEnabled') ?? true,
      jobAlertsEnabled: prefs.getBool('jobAlertsEnabled') ?? true,
      recommendationsEnabled: prefs.getBool('recommendationsEnabled') ?? true,
      language: prefs.getString('language') ?? 'en',
    );
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> toggleNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', enabled);
    state = state.copyWith(notificationsEnabled: enabled);
  }

  Future<void> toggleJobAlerts(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('jobAlertsEnabled', enabled);
    state = state.copyWith(jobAlertsEnabled: enabled);
  }

  Future<void> toggleRecommendations(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('recommendationsEnabled', enabled);
    state = state.copyWith(recommendationsEnabled: enabled);
  }

  Future<void> updateLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    state = state.copyWith(language: language);
  }
}
