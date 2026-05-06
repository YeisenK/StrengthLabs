import 'package:equatable/equatable.dart';

enum MuscleGroup { chest, back, legs, shoulders, arms, core }

extension MuscleGroupParsing on MuscleGroup {
  static MuscleGroup fromString(String mg) {
    switch (mg.toLowerCase()) {
      case 'chest':
        return MuscleGroup.chest;
      case 'back':
        return MuscleGroup.back;
      case 'shoulders':
        return MuscleGroup.shoulders;
      case 'arms':
      case 'biceps':
      case 'triceps':
      case 'forearms':
        return MuscleGroup.arms;
      case 'legs':
      case 'quads':
      case 'hamstrings':
      case 'glutes':
      case 'calves':
        return MuscleGroup.legs;
      default:
        return MuscleGroup.core;
    }
  }
}

extension MuscleGroupLabel on MuscleGroup {
  String get label {
    switch (this) {
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.back:
        return 'Back';
      case MuscleGroup.legs:
        return 'Legs';
      case MuscleGroup.shoulders:
        return 'Shoulders';
      case MuscleGroup.arms:
        return 'Arms';
      case MuscleGroup.core:
        return 'Core';
    }
  }
}

class Exercise extends Equatable {
  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.isCustom = false,
  });

  final String id;
  final String name;
  final MuscleGroup muscleGroup;
  final bool isCustom;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'muscleGroup': muscleGroup.name,
        'isCustom': isCustom,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'] as String,
        name: json['name'] as String,
        muscleGroup: MuscleGroup.values.byName(json['muscleGroup'] as String),
        isCustom: json['isCustom'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [id, name, muscleGroup, isCustom];
}
