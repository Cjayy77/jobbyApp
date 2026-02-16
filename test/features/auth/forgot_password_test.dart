import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobby/src/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:jobby/src/features/auth/providers/auth_provider.dart';
import 'package:mockito/mockito.dart';

class MockAuthNotifier extends Mock implements AuthNotifier {}

void main() {
  late MockAuthNotifier mockAuthNotifier;

  setUp(() {
    mockAuthNotifier = MockAuthNotifier();
  });

  testWidgets('ForgotPasswordScreen UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWithProvider(
            StateNotifierProvider<AuthNotifier, User?>(
                (ref) => mockAuthNotifier),
          ),
        ],
        child: const MaterialApp(
          home: ForgotPasswordScreen(),
        ),
      ),
    );

    // Verify UI elements
    expect(find.text('Reset Password'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);

    // Test invalid email
    await tester.enterText(find.byType(TextFormField), 'invalid-email');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Please enter a valid email'), findsOneWidget);

    // Test valid email
    await tester.enterText(find.byType(TextFormField), 'test@example.com');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    verify(mockAuthNotifier.resetPassword('test@example.com')).called(1);
  });
}
