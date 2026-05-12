import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:strengthlabs/features/auth/domain/entities/user.dart';

/// Persists the last-known authenticated user so the app can hydrate the
/// `/auth/me` screen without a network round-trip — and stay logged in when
/// the device is offline.
///
/// Backed by `shared_preferences` for the MVP; will move to the Drift
/// database (single-source-of-truth) in the offline-first refactor.
class UserCache {
  UserCache({SharedPreferences? prefs}) : _injected = prefs;

  static const _key = 'auth.cached_user';
  final SharedPreferences? _injected;

  Future<SharedPreferences> get _prefs async =>
      _injected ?? await SharedPreferences.getInstance();

  Future<void> save(User user) async {
    final p = await _prefs;
    await p.setString(
      _key,
      jsonEncode({'id': user.id, 'name': user.name, 'email': user.email}),
    );
  }

  Future<User?> read() async {
    final p = await _prefs;
    final raw = p.getString(_key);
    if (raw == null) return null;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return User(
        id: data['id'] as String,
        name: data['name'] as String,
        email: data['email'] as String,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final p = await _prefs;
    await p.remove(_key);
  }
}
