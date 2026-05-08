import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strengthlabs/features/settings/presentation/cubit/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  static const _keyTheme = 'settings_theme';
  static const _keyLocale = 'settings_locale';
  static const _keyWeightUnit = 'settings_weight_unit';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt(_keyTheme);
    final localeCode = prefs.getString(_keyLocale);
    final unitIndex = prefs.getInt(_keyWeightUnit);

    emit(SettingsState(
      themeMode: themeIndex != null
          ? ThemeMode.values[themeIndex]
          : ThemeMode.dark,
      locale: localeCode != null ? Locale(localeCode) : const Locale('en'),
      weightUnit: unitIndex != null
          ? WeightUnit.values[unitIndex]
          : WeightUnit.kg,
    ));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTheme, mode.index);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, locale.languageCode);
    emit(state.copyWith(locale: locale));
  }

  Future<void> setWeightUnit(WeightUnit unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyWeightUnit, unit.index);
    emit(state.copyWith(weightUnit: unit));
  }
}
