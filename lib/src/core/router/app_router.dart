import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/auth/presentation/screens/user_type_screen.dart';
import '../../features/job/presentation/screens/job_preferences_screen.dart';
import '../../features/job/presentation/screens/home_screen.dart';
import '../../features/job/presentation/screens/job_creation_screen.dart';
import '../../features/job/presentation/screens/job_confirmation_screen.dart';
import '../../features/job/presentation/screens/job_details_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/chat/models/chat.dart';
import '../../features/events/presentation/screens/event_creation_screen.dart';
import '../../features/events/presentation/screens/event_details_screen.dart';
import '../../features/events/presentation/screens/event_confirmation_screen.dart';
import '../../features/events/models/event.dart';
import '../../features/job/models/job.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    refreshListenable:
        GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/home',
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/user-type',
        builder: (context, state) => const UserTypeScreen(),
      ),
      GoRoute(
        path: '/job-preferences',
        builder: (context, state) => const JobPreferencesScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/job-creation',
        builder: (context, state) => const JobCreationScreen(),
      ),
      GoRoute(
        path: '/job-confirmation',
        builder: (context, state) {
          final jobData = state.extra as Map<String, dynamic>;
          return JobConfirmationScreen(jobData: jobData);
        },
      ),
      GoRoute(
        path: '/job-details',
        builder: (context, state) => JobDetailsScreen(
          job: state.extra as Job,
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/chat/:chatId',
        builder: (context, state) {
          final chat = state.extra as Chat;
          final title = state.uri.queryParameters['jobTitle'] ?? 'Job Chat';
          return ChatScreen(chat: chat, jobTitle: title);
        },
      ),
      GoRoute(
        path: '/event-creation',
        builder: (context, state) => const EventCreationScreen(),
      ),
      GoRoute(
        path: '/event-details',
        builder: (context, state) {
          final event = state.extra as Event;
          return EventDetailsScreen(event: event);
        },
      ),
      GoRoute(
        path: '/event-confirmation',
        builder: (context, state) {
          final eventData = state.extra as Map<String, dynamic>;
          return EventConfirmationScreen(eventData: eventData);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Page not found: ${state.uri.toString()}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    ),
  );
});
