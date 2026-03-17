import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/models/auth_user.dart';
import '../data/auth_repository.dart';

// ─────────────────────────────────────────────────────────
// AUTH STATE
// ─────────────────────────────────────────────────────────
sealed class AuthState {
  const AuthState();
}

/// App just launched — checking stored token.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// User is logged in.
class AuthAuthenticated extends AuthState {
  final AuthUser user;
  const AuthAuthenticated(this.user);
}

/// User is not logged in. [error] is set when a login attempt failed.
class AuthUnauthenticated extends AuthState {
  final String? error;
  const AuthUnauthenticated({this.error});
}

// ─────────────────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthInitial()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final user = await _repo.restoreSession();
    state = user != null
        ? AuthAuthenticated(user)
        : const AuthUnauthenticated();
  }

  Future<void> login(String email, String password) async {
    try {
      final user = await _repo.login(email, password);
      state = AuthAuthenticated(user);
    } catch (e) {
      state = AuthUnauthenticated(
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void setError(String? error) {
    state = AuthUnauthenticated(error: error);
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final user = await _repo.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
      state = AuthAuthenticated(user);
    } catch (e) {
      state = AuthUnauthenticated(
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthUnauthenticated();
  }
}

// ─────────────────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>(
  (_) => const AuthRepository(FlutterSecureStorage()),
);

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authRepositoryProvider)),
);
