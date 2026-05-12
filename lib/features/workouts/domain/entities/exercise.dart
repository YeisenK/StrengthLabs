import 'package:equatable/equatable.dart';
import 'package:strengthlabs/l10n/app_localizations.dart';

/// Muscle groups as emitted by the backend (snake_case server names).
///
/// Mirrors the 12 categories defined server-side in
/// `GetFatigueSummaryUseCase.MUSCLE_GROUPS`. Keeping them granular is required
/// so the fatigue dashboard can show per-muscle volume without collapsing
/// biceps + triceps + forearms into a single bucket.
enum MuscleGroup {
  chest('chest'),
  back('back'),
  shoulders('shoulders'),
  biceps('biceps'),
  triceps('triceps'),
  forearms('forearms'),
  legs('legs'),
  glutes('glutes'),
  calves('calves'),
  core('core'),
  cardio('cardio'),
  other('other');

  const MuscleGroup(this.serverName);

  /// Identifier sent/received by the API (`muscle_group` field).
  final String serverName;
}

/// Coarse UI grouping used by chip filters and high-level summaries when 12
/// categories are too noisy.
enum MuscleCategory { chest, back, shoulders, arms, legs, core, conditioning }

extension MuscleGroupParsing on MuscleGroup {
  /// Parse an arbitrary backend string. Unknown values map to [MuscleGroup.other]
  /// so the client never crashes on a payload it doesn't understand.
  static MuscleGroup fromString(String mg) {
    final normalized = mg.toLowerCase().trim();
    for (final v in MuscleGroup.values) {
      if (v.serverName == normalized) return v;
    }
    // Legacy / coarse aliases — keep working with older payloads.
    switch (normalized) {
      case 'arms':
        return MuscleGroup.biceps;
      case 'quads':
      case 'hamstrings':
        return MuscleGroup.legs;
      default:
        return MuscleGroup.other;
    }
  }
}

extension MuscleGroupCategory on MuscleGroup {
  MuscleCategory get category {
    switch (this) {
      case MuscleGroup.chest:
        return MuscleCategory.chest;
      case MuscleGroup.back:
        return MuscleCategory.back;
      case MuscleGroup.shoulders:
        return MuscleCategory.shoulders;
      case MuscleGroup.biceps:
      case MuscleGroup.triceps:
      case MuscleGroup.forearms:
        return MuscleCategory.arms;
      case MuscleGroup.legs:
      case MuscleGroup.glutes:
      case MuscleGroup.calves:
        return MuscleCategory.legs;
      case MuscleGroup.core:
        return MuscleCategory.core;
      case MuscleGroup.cardio:
      case MuscleGroup.other:
        return MuscleCategory.conditioning;
    }
  }
}

extension MuscleGroupLabel on MuscleGroup {
  String localized(AppLocalizations l10n) {
    switch (this) {
      case MuscleGroup.chest:
        return l10n.muscleChest;
      case MuscleGroup.back:
        return l10n.muscleBack;
      case MuscleGroup.shoulders:
        return l10n.muscleShoulders;
      case MuscleGroup.biceps:
        return l10n.muscleBiceps;
      case MuscleGroup.triceps:
        return l10n.muscleTriceps;
      case MuscleGroup.forearms:
        return l10n.muscleForearms;
      case MuscleGroup.legs:
        return l10n.muscleLegs;
      case MuscleGroup.glutes:
        return l10n.muscleGlutes;
      case MuscleGroup.calves:
        return l10n.muscleCalves;
      case MuscleGroup.core:
        return l10n.muscleCore;
      case MuscleGroup.cardio:
        return l10n.muscleCardio;
      case MuscleGroup.other:
        return l10n.muscleOther;
    }
  }
}

extension MuscleCategoryLabel on MuscleCategory {
  String localized(AppLocalizations l10n) {
    switch (this) {
      case MuscleCategory.chest:
        return l10n.muscleChest;
      case MuscleCategory.back:
        return l10n.muscleBack;
      case MuscleCategory.shoulders:
        return l10n.muscleShoulders;
      case MuscleCategory.arms:
        return l10n.muscleArms;
      case MuscleCategory.legs:
        return l10n.muscleLegs;
      case MuscleCategory.core:
        return l10n.muscleCore;
      case MuscleCategory.conditioning:
        return l10n.muscleOther;
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
        'muscle_group': muscleGroup.serverName,
        'is_custom': isCustom,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'] as String,
        name: json['name'] as String,
        muscleGroup: MuscleGroupParsing.fromString(
          (json['muscle_group'] ?? json['muscleGroup']) as String,
        ),
        isCustom: (json['is_custom'] ?? json['isCustom']) as bool? ?? false,
      );

  @override
  List<Object?> get props => [id, name, muscleGroup, isCustom];
}
