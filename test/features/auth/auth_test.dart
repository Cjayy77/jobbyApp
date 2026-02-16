import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jobby/src/features/auth/providers/auth_provider.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late AuthNotifier authNotifier;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    authNotifier = AuthNotifier();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
  });

  group('AuthNotifier Tests', () {
    test('signIn should update state with user', () async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);

      await authNotifier.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(authNotifier.state, equals(mockUser));
    });

    test('signUp should create user and update state', () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);

      await authNotifier.signUp(
        email: 'test@example.com',
        password: 'password123',
        username: 'testuser',
      );

      expect(authNotifier.state, equals(mockUser));
      verify(mockUser.updateDisplayName('testuser')).called(1);
    });

    test('resetPassword should send reset email', () async {
      when(mockFirebaseAuth.sendPasswordResetEmail(
        email: 'test@example.com',
      )).thenAnswer((_) async {});

      await authNotifier.resetPassword('test@example.com');

      verify(mockFirebaseAuth.sendPasswordResetEmail(
        email: 'test@example.com',
      )).called(1);
    });

    test('signOut should clear state', () async {
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      await authNotifier.signOut();

      expect(authNotifier.state, isNull);
      verify(mockFirebaseAuth.signOut()).called(1);
    });
  });
}
