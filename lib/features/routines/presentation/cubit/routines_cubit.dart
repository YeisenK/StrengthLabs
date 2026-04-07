import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs_beta/features/routines/data/mock_routines.dart';
import 'package:strengthlabs_beta/features/routines/domain/entities/routine.dart';
import 'package:strengthlabs_beta/features/routines/presentation/cubit/routines_state.dart';

class RoutinesCubit extends Cubit<RoutinesState> {
  RoutinesCubit() : super(const RoutinesInitial());

  Future<void> loadRoutines({RoutineLevel? level}) async {
    emit(const RoutinesLoading());
    await Future.delayed(const Duration(milliseconds: 300));

    // TODO: replace with RoutineRepository.getRoutines(level: level)
    final filtered = level == null
        ? kMockRoutines
        : kMockRoutines.where((r) => r.level == level).toList();

    emit(RoutinesLoaded(filtered));
  }

  Routine? findById(String id) {
    try {
      return kMockRoutines.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
