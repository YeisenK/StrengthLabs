import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs_beta/features/fatigue/data/fatigue_repository.dart';
import 'package:strengthlabs_beta/features/fatigue/presentation/cubit/fatigue_state.dart';

class FatigueCubit extends Cubit<FatigueState> {
  FatigueCubit(this._repository) : super(const FatigueInitial());

  final FatigueRepository _repository;

  Future<void> loadSummary() async {
    emit(const FatigueLoading());
    try {
      final summary = await _repository.getSummary();
      emit(FatigueLoaded(summary));
    } catch (e) {
      emit(FatigueError(e.toString()));
    }
  }
}
