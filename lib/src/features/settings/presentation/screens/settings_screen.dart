import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final currentUser = ref.watch(authProvider);

    return ListView(
      children: [
        const _SectionHeader(title: 'Appearance'),
        ListTile(
          leading: const Icon(Icons.brightness_6),
          title: const Text('Theme'),
          subtitle: Text(
            settings.themeMode.name.substring(0, 1).toUpperCase() +
                settings.themeMode.name.substring(1),
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => _ThemeModeDialog(
                currentMode: settings.themeMode,
                onModeSelected: (mode) {
                  ref.read(settingsProvider.notifier).updateThemeMode(mode);
                },
              ),
            );
          },
        ),
        const _SectionHeader(title: 'Account'),
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('Edit Profile'),
          onTap: () {
            // TODO: Navigate to edit profile screen
          },
        ),
        ListTile(
          leading: const Icon(Icons.security),
          title: const Text('Change Password'),
          onTap: () {
            // TODO: Implement change password functionality
          },
        ),
        const _SectionHeader(title: 'Notifications'),
        SwitchListTile(
          secondary: const Icon(Icons.notifications_outlined),
          title: const Text('Enable Notifications'),
          subtitle:
              const Text('Get updates about your job posts and applications'),
          value: settings.notificationsEnabled,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).toggleNotifications(value);
          },
        ),
        if (settings.notificationsEnabled) ...[
          SwitchListTile(
            secondary: const Icon(Icons.work_outline),
            title: const Text('Job Alerts'),
            subtitle:
                const Text('Get notified when new jobs match your preferences'),
            value: settings.jobAlertsEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleJobAlerts(value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.recommend),
            title: const Text('Job Recommendations'),
            subtitle:
                const Text('Get notified about jobs that match your profile'),
            value: settings.recommendationsEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleRecommendations(value);
            },
          ),
        ],
        const _SectionHeader(title: 'Language'),
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('App Language'),
          subtitle: Text(settings.language.toUpperCase()),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => _LanguageDialog(
                currentLanguage: settings.language,
                onLanguageSelected: (language) {
                  ref.read(settingsProvider.notifier).updateLanguage(language);
                },
              ),
            );
          },
        ),
        const _SectionHeader(title: 'Legal'),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Terms of Service'),
          onTap: () {
            // TODO: Show terms of service
          },
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Privacy Policy'),
          onTap: () {
            // TODO: Show privacy policy
          },
        ),
        if (currentUser != null) ...[
          const _SectionHeader(title: 'Danger Zone'),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(authProvider.notifier).signOut();
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, '/auth');
                      },
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              // TODO: Implement account deletion
            },
          ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _ThemeModeDialog extends StatelessWidget {
  final ThemeMode currentMode;
  final void Function(ThemeMode) onModeSelected;

  const _ThemeModeDialog({
    required this.currentMode,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Choose Theme'),
      children: ThemeMode.values.map((mode) {
        return SimpleDialogOption(
          onPressed: () {
            onModeSelected(mode);
            Navigator.pop(context);
          },
          child: Row(
            children: [
              if (mode == currentMode) ...[
                Icon(
                  Icons.check,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                mode.name.substring(0, 1).toUpperCase() +
                    mode.name.substring(1),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _LanguageDialog extends StatelessWidget {
  final String currentLanguage;
  final void Function(String) onLanguageSelected;

  const _LanguageDialog({
    required this.currentLanguage,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    const languages = {
      'en': 'English',
      'fr': 'Français',
    };

    return SimpleDialog(
      title: const Text('Choose Language'),
      children: languages.entries.map((entry) {
        return SimpleDialogOption(
          onPressed: () {
            onLanguageSelected(entry.key);
            Navigator.pop(context);
          },
          child: Row(
            children: [
              if (entry.key == currentLanguage) ...[
                Icon(
                  Icons.check,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
              ],
              Text(entry.value),
            ],
          ),
        );
      }).toList(),
    );
  }
}
