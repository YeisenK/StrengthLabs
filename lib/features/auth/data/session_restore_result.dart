import 'package:strengthlabs/features/auth/domain/entities/user.dart';

/// Outcome of restoring a session on app startup.
///
/// Distinguishes the offline-but-cached path (where we let the user in) from
/// the explicit "session is invalid" path (where we force a login), so the
/// UI doesn't bounce people to the login screen every time the network blips.
sealed class SessionRestoreResult {
  const SessionRestoreResult();
}

/// No token on disk — user has never logged in or has explicitly logged out.
class SessionMissing extends SessionRestoreResult {
  const SessionMissing();
}

/// Server confirmed the user, or we used a cached copy because the server was
/// unreachable. [fromCache] = true means the network call failed and we
/// degraded gracefully.
class SessionRestored extends SessionRestoreResult {
  const SessionRestored(this.user, {this.fromCache = false});
  final User user;
  final bool fromCache;
}

/// Server explicitly rejected the token (401). Tokens have been cleared.
class SessionExpired extends SessionRestoreResult {
  const SessionExpired();
}

/// Device is offline and we have no cached user — first launch without
/// network. Treat as logged out for now.
class SessionOfflineNoCache extends SessionRestoreResult {
  const SessionOfflineNoCache();
}
