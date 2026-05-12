import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum WeightUnit { kg, lb }

class SettingsState extends Equatable {
  const SettingsState({
    this.themeMode = ThemeMode.dark,
    this.locale = const Locale('en'),
    this.weightUnit = WeightUnit.kg,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final WeightUnit weightUnit;

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    WeightUnit? weightUnit,
  }) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        locale: locale ?? this.locale,
        weightUnit: weightUnit ?? this.weightUnit,
      );

  @override
  List<Object?> get props => [themeMode, locale, weightUnit];
}
