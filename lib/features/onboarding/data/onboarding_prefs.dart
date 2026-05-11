import 'package:shared_preferences/shared_preferences.dart';

/// Persists whether the user has completed the post-registration onboarding.
class OnboardingPrefs {
  OnboardingPrefs._();

  static const _keyCompleted = 'onboarding_completed';

  static Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyCompleted) ?? false;
  }

  static Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCompleted, true);
  }

  /// Reset for tests / logout-from-fresh-account flows.
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCompleted);
  }
}
