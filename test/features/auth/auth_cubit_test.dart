import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:strengthlabs/features/auth/data/auth_repository.dart';
import 'package:strengthlabs/features/auth/domain/entities/user.dart';
import 'package:strengthlabs/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:strengthlabs/features/auth/presentation/cubit/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  const user = User(id: 'user-1', name: 'Alice', email: 'alice@test.com');

  setUp(() {
    repository = MockAuthRepository();
  });

  group('AuthCubit.checkAuthStatus', () {
    blocTest<AuthCubit, AuthState>(
      'emits AuthUnauthenticated when no token stored',
      build: () {
        when(() => repository.hasStoredTokens()).thenAnswer((_) async => false);
        return AuthCubit(repository);
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [const AuthUnauthenticated()],
      verify: (_) => verifyNever(() => repository.getCurrentUser()),
    );

    blocTest<AuthCubit, AuthState>(
      'emits AuthAuthenticated when token valid and getCurrentUser succeeds',
      build: () {
        when(() => repository.hasStoredTokens()).thenAnswer((_) async => true);
        when(() => repository.getCurrentUser()).thenAnswer((_) async => user);
        return AuthCubit(repository);
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => const [AuthAuthenticated(user)],
    );

    blocTest<AuthCubit, AuthState>(
      'falls back to AuthUnauthenticated when getCurrentUser throws',
      build: () {
        when(() => repository.hasStoredTokens()).thenAnswer((_) async => true);
        when(() => repository.getCurrentUser())
            .thenThrow(Exception('Token expired'));
        when(() => repository.logout()).thenAnswer((_) async {});
        return AuthCubit(repository);
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [const AuthUnauthenticated()],
      verify: (_) => verify(() => repository.logout()).called(1),
    );
  });

  group('AuthCubit.login', () {
    blocTest<AuthCubit, AuthState>(
      'emits [Loading, Authenticated] on success',
      build: () {
        when(() => repository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => user);
        return AuthCubit(repository);
      },
      act: (cubit) => cubit.login(email: 'alice@test.com', password: 'pw'),
      expect: () => const [AuthLoading(), AuthAuthenticated(user)],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [Loading, Error] on failure with cleaned message',
      build: () {
        when(() => repository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(Exception('Invalid credentials'));
        return AuthCubit(repository);
      },
      act: (cubit) => cubit.login(email: 'alice@test.com', password: 'pw'),
      expect: () => const [AuthLoading(), AuthError('Invalid credentials')],
    );
  });

  group('AuthCubit.register', () {
    blocTest<AuthCubit, AuthState>(
      'emits [Loading, Authenticated] on success',
      build: () {
        when(() => repository.register(
              name: any(named: 'name'),
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => user);
        return AuthCubit(repository);
      },
      act: (cubit) => cubit.register(
        name: 'Alice',
        email: 'alice@test.com',
        password: 'pw',
      ),
      expect: () => const [AuthLoading(), AuthAuthenticated(user)],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [Loading, Error] when email already registered',
      build: () {
        when(() => repository.register(
              name: any(named: 'name'),
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(Exception('Email already registered'));
        return AuthCubit(repository);
      },
      act: (cubit) => cubit.register(
        name: 'Alice',
        email: 'alice@test.com',
        password: 'pw',
      ),
      expect: () =>
          const [AuthLoading(), AuthError('Email already registered')],
    );
  });

  group('AuthCubit.loginWithGoogle', () {
    blocTest<AuthCubit, AuthState>(
      'emits Unauthenticated when user cancels (does not surface as error)',
      build: () {
        when(() => repository.loginWithGoogle())
            .thenThrow(Exception('Google Sign-In cancelled'));
        return AuthCubit(repository);
      },
      act: (cubit) => cubit.loginWithGoogle(),
      expect: () => const [AuthLoading(), AuthUnauthenticated()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits Error on real Google failure',
      build: () {
        when(() => repository.loginWithGoogle())
            .thenThrow(Exception('Network error'));
        return AuthCubit(repository);
      },
      act: (cubit) => cubit.loginWithGoogle(),
      expect: () => const [AuthLoading(), AuthError('Network error')],
    );
  });

  group('AuthCubit.logout', () {
    blocTest<AuthCubit, AuthState>(
      'emits AuthUnauthenticated and calls repository.logout',
      build: () {
        when(() => repository.logout()).thenAnswer((_) async {});
        return AuthCubit(repository);
      },
      act: (cubit) => cubit.logout(),
      expect: () => [const AuthUnauthenticated()],
      verify: (_) => verify(() => repository.logout()).called(1),
    );
  });
}
