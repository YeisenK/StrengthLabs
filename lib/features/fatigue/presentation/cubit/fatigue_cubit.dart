import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs_beta/features/fatigue/domain/entities/fatigue_summary.dart';
import 'package:strengthlabs_beta/features/fatigue/presentation/cubit/fatigue_state.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/exercise.dart';

class FatigueCubit extends Cubit<FatigueState> {
  FatigueCubit() : super(const FatigueInitial());

  Future<void> loadSummary() async {
    emit(const FatigueLoading());
    await Future.delayed(const Duration(milliseconds: 400));

    // TODO: replace with FatigueRepository.getSummary()
    final now = DateTime.now();
    emit(
      FatigueLoaded(
        FatigueSummary(
          overallIndex: 72.0,
          isOvertraining: false,
          weeklyVolume: {
            MuscleGroup.chest: 85.0,
            MuscleGroup.back: 70.0,
            MuscleGroup.legs: 90.0,
            MuscleGroup.shoulders: 55.0,
            MuscleGroup.arms: 45.0,
            MuscleGroup.core: 30.0,
          },
          trend: List.generate(
            7,
            (i) => FatigueDataPoint(
              date: now.subtract(Duration(days: 6 - i)),
              index: [40.0, 48.0, 55.0, 60.0, 68.0, 70.0, 72.0][i],
            ),
          ),
        ),
      ),
    );
  }
}
