import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../../profile/providers/profile_provider.dart';

class UserTypeScreen extends ConsumerWidget {
  const UserTypeScreen({super.key});

  Future<void> _selectUserType(
    BuildContext context,
    WidgetRef ref,
    bool isJobSeeker,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isJobSeeker', isJobSeeker);

    final user = ref.read(authProvider);
    if (user != null) {
      await ref.read(profileProvider.notifier).createProfile(
            name: user.displayName ?? '',
            email: user.email!,
            isJobSeeker: isJobSeeker,
          );
    }

    if (context.mounted) {
      if (isJobSeeker) {
        context.go('/job-preferences');
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'How will you primarily use Jobby?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Both options allow you to browse and post jobs',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _UserTypeCard(
                title: 'I\'m looking for work',
                subtitle:
                    'Create a job seeker profile to showcase your skills and experience',
                icon: Icons.work_outline,
                description:
                    'Browse jobs, save favorites, and contact employers directly',
                onTap: () => _selectUserType(context, ref, true),
              ),
              const SizedBox(height: 24),
              _UserTypeCard(
                title: 'I\'m hiring',
                subtitle:
                    'Create a business profile to attract the right candidates',
                icon: Icons.business_center_outlined,
                description:
                    'Post jobs, manage applications, and contact candidates',
                onTap: () => _selectUserType(context, ref, false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
