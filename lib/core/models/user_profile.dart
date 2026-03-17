class UserProfile {
  final String? photoPath;
  final double? weightKg;
  final double? heightCm;
  final DateTime? birthDate;
  final String? goal;
  final ExperienceLevel experienceLevel;
  final bool notificationsEnabled;

  // Stats — mocked until backend ready
  final int totalSessions;
  final int currentStreak;

  const UserProfile({
    this.photoPath,
    this.weightKg,
    this.heightCm,
    this.birthDate,
    this.goal,
    this.experienceLevel = ExperienceLevel.intermediate,
    this.notificationsEnabled = true,
    this.totalSessions = 0,
    this.currentStreak = 0,
  });

  UserProfile copyWith({
    Object? photoPath = _sentinel,
    Object? weightKg = _sentinel,
    Object? heightCm = _sentinel,
    Object? birthDate = _sentinel,
    Object? goal = _sentinel,
    ExperienceLevel? experienceLevel,
    bool? notificationsEnabled,
    int? totalSessions,
    int? currentStreak,
  }) {
    return UserProfile(
      photoPath: photoPath == _sentinel ? this.photoPath : photoPath as String?,
      weightKg: weightKg == _sentinel ? this.weightKg : weightKg as double?,
      heightCm: heightCm == _sentinel ? this.heightCm : heightCm as double?,
      birthDate: birthDate == _sentinel ? this.birthDate : birthDate as DateTime?,
      goal: goal == _sentinel ? this.goal : goal as String?,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      totalSessions: totalSessions ?? this.totalSessions,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }
}

// Sentinel to differentiate null from "not provided"
const _sentinel = Object();

enum ExperienceLevel {
  beginner('PRINCIPIANTE'),
  intermediate('INTERMEDIO'),
  advanced('AVANZADO'),
  elite('ÉLITE');

  final String label;
  const ExperienceLevel(this.label);
}

const kGoalOptions = [
  'FUERZA MÁXIMA',
  'HIPERTROFIA',
  'PÉRDIDA DE PESO',
  'RESISTENCIA',
  'RENDIMIENTO',
];
