import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs/features/routines/data/routine_repository.dart';
import 'package:strengthlabs/features/routines/domain/entities/routine.dart';
import 'package:strengthlabs/features/routines/presentation/cubit/routines_state.dart';

class RoutinesCubit extends Cubit<RoutinesState> {
  RoutinesCubit(this._repository) : super(const RoutinesInitial());

  final RoutineRepository _repository;
  List<Routine> _cached = [];

  Future<void> loadRoutines({RoutineLevel? level}) async {
    emit(const RoutinesLoading());
    try {
      final routines = await _repository.getRoutines(level: level);
      if (level == null) _cached = routines;
      emit(RoutinesLoaded(routines));
    } catch (_) {
      emit(const RoutinesError('Could not load routines'));
    }
  }

  Routine? findById(String id) {
    try {
      return _cached.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Routine?> fetchDetail(String id) async {
    try {
      return await _repository.getRoutine(id);
    } catch (_) {
      return null;
    }
  }
}
