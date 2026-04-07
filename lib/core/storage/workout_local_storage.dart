import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/workout.dart';

class WorkoutLocalStorage {
  static const _workoutsKey = 'workouts_v1';
  static const _seededKey = 'workouts_seeded_v1';

  Future<List<Workout>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_workoutsKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list
        .map((e) => Workout.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(List<Workout> workouts) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(workouts.map((w) => w.toJson()).toList());
    await prefs.setString(_workoutsKey, json);
  }

  /// Returns true if this is the first launch (storage not yet seeded).
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_seededKey) != true;
  }

  Future<void> markSeeded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seededKey, true);
  }
}
