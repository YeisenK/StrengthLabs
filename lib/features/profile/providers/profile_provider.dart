import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/user_profile.dart';

// ── Keys ─────────────────────────────────────────────────
const _kPhoto         = 'profile_photo';
const _kWeight        = 'profile_weight';
const _kHeight        = 'profile_height';
const _kBirthDate     = 'profile_birth_date';
const _kGoal          = 'profile_goal';
const _kLevel         = 'profile_level';
const _kNotifications = 'profile_notifications';

// ── Notifier ─────────────────────────────────────────────
class ProfileNotifier extends StateNotifier<UserProfile> {
  ProfileNotifier() : super(const UserProfile()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final levelIndex = prefs.getInt(_kLevel) ?? ExperienceLevel.intermediate.index;
    final birthMs = prefs.getInt(_kBirthDate);

    state = UserProfile(
      photoPath: prefs.getString(_kPhoto),
      weightKg: prefs.getDouble(_kWeight),
      heightCm: prefs.getDouble(_kHeight),
      birthDate: birthMs != null
          ? DateTime.fromMillisecondsSinceEpoch(birthMs)
          : null,
      goal: prefs.getString(_kGoal),
      experienceLevel: ExperienceLevel.values[levelIndex.clamp(0, ExperienceLevel.values.length - 1)],
      notificationsEnabled: prefs.getBool(_kNotifications) ?? true,
      // TODO: load from backend
      totalSessions: 247,
      currentStreak: 14,
    );
  }

  Future<void> updatePhoto(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPhoto, path);
    state = state.copyWith(photoPath: path);
  }

  Future<void> removePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPhoto);
    state = state.copyWith(photoPath: null);
  }

  Future<void> updateWeight(double? kg) async {
    final prefs = await SharedPreferences.getInstance();
    if (kg == null) {
      await prefs.remove(_kWeight);
    } else {
      await prefs.setDouble(_kWeight, kg);
    }
    state = state.copyWith(weightKg: kg);
  }

  Future<void> updateHeight(double? cm) async {
    final prefs = await SharedPreferences.getInstance();
    if (cm == null) {
      await prefs.remove(_kHeight);
    } else {
      await prefs.setDouble(_kHeight, cm);
    }
    state = state.copyWith(heightCm: cm);
  }

  Future<void> updateBirthDate(DateTime? date) async {
    final prefs = await SharedPreferences.getInstance();
    if (date == null) {
      await prefs.remove(_kBirthDate);
    } else {
      await prefs.setInt(_kBirthDate, date.millisecondsSinceEpoch);
    }
    state = state.copyWith(birthDate: date);
  }

  Future<void> updateGoal(String? goal) async {
    final prefs = await SharedPreferences.getInstance();
    if (goal == null) {
      await prefs.remove(_kGoal);
    } else {
      await prefs.setString(_kGoal, goal);
    }
    state = state.copyWith(goal: goal);
  }

  Future<void> updateLevel(ExperienceLevel level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLevel, level.index);
    state = state.copyWith(experienceLevel: level);
  }

  Future<void> toggleNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifications, enabled);
    state = state.copyWith(notificationsEnabled: enabled);
  }
}

// ── Provider ─────────────────────────────────────────────
final profileProvider =
    StateNotifierProvider<ProfileNotifier, UserProfile>(
  (_) => ProfileNotifier(),
);
