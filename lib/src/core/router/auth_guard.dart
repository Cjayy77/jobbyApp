import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/profile/providers/profile_provider.dart';

class AuthGuard {
  static Future<String?> guardRoute(
    BuildContext context,
    WidgetRef ref,
    GoRouterState state,
  ) async {
    final user = ref.read(authProvider);
    final prefs = await SharedPreferences.getInstance();

    // Public routes that don't require authentication
    const publicRoutes = [
      '/onboarding',
      '/auth',
      '/login',
    ];

    // Check if route is public
    if (publicRoutes.contains(state.uri.path)) {
      return null;
    }

    // Check if user is authenticated
    if (user == null) {
      return '/auth';
    }

    // Check if user has completed onboarding
    final showOnboarding = prefs.getBool('showOnboarding') ?? true;
    if (showOnboarding) {
      return '/onboarding';
    }

    // Check if user has selected their type
    final hasSelectedUserType = prefs.containsKey('isJobSeeker');
    if (!hasSelectedUserType && state.uri.path != '/user-type') {
      return '/user-type';
    }

    // Check if job seeker needs to set preferences
    final isJobSeeker = prefs.getBool('isJobSeeker') ?? false;
    final hasSetPreferences = prefs.getBool('hasSetPreferences') ?? false;
    if (isJobSeeker &&
        !hasSetPreferences &&
        state.uri.path != '/job-preferences') {
      return '/job-preferences';
    }

    // Load profile if not already loaded
    final profile = ref.read(profileProvider);
    if (profile == null) {
      await ref.read(profileProvider.notifier).loadProfile(user.uid);
    }

    // Allow navigation to proceed
    return null;
  }

  static String? guardLogin(
    BuildContext context,
    WidgetRef ref,
    GoRouterState state,
  ) {
    final user = ref.read(authProvider);

    // If user is authenticated, redirect to home
    if (user != null) {
      return '/home';
    }

    // Allow navigation to proceed
    return null;
  }
}
