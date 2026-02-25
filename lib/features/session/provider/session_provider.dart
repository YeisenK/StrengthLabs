import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:asip_fitness_analytics/features/session/repository/session_repository.dart';
import 'package:asip_fitness_analytics/shared/models/workout_session.dart';

part 'session_provider.g.dart';

@riverpod
SessionRepository sessionRepository(Ref ref) {
  return SessionRepository();
}

@riverpod
class SessionController extends _$SessionController {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<bool> submitSession(WorkoutSession session) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(sessionRepositoryProvider);
      await repository.submitSession(session);
      state = const AsyncData(null);
      return true;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      return false;
    }
  }
}