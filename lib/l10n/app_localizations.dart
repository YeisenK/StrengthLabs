import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'StrengthLabs'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @alreadyAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @logoutConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to access your data.'**
  String get logoutConfirmContent;

  /// No description provided for @workouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workouts;

  /// No description provided for @routines.
  ///
  /// In en, this message translates to:
  /// **'Routines'**
  String get routines;

  /// No description provided for @fatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get fatigue;

  /// No description provided for @export_.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export_;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @startWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start workout'**
  String get startWorkout;

  /// No description provided for @activeWorkout.
  ///
  /// In en, this message translates to:
  /// **'Active workout'**
  String get activeWorkout;

  /// No description provided for @finishWorkout.
  ///
  /// In en, this message translates to:
  /// **'Finish workout'**
  String get finishWorkout;

  /// No description provided for @finishWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish workout?'**
  String get finishWorkoutTitle;

  /// No description provided for @onlyCompletedSets.
  ///
  /// In en, this message translates to:
  /// **'Only completed sets will be saved.'**
  String get onlyCompletedSets;

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get keepGoing;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @discardWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard workout?'**
  String get discardWorkoutTitle;

  /// No description provided for @allProgressLost.
  ///
  /// In en, this message translates to:
  /// **'All progress will be lost.'**
  String get allProgressLost;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @addExercise.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get addExercise;

  /// No description provided for @addExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get addExerciseTitle;

  /// No description provided for @noExercisesYet.
  ///
  /// In en, this message translates to:
  /// **'No exercises yet'**
  String get noExercisesYet;

  /// No description provided for @noExercisesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first exercise to get started'**
  String get noExercisesSubtitle;

  /// No description provided for @searchExercises.
  ///
  /// In en, this message translates to:
  /// **'Search exercises...'**
  String get searchExercises;

  /// No description provided for @addSet.
  ///
  /// In en, this message translates to:
  /// **'Add set'**
  String get addSet;

  /// No description provided for @createCustomExercise.
  ///
  /// In en, this message translates to:
  /// **'Create custom exercise'**
  String get createCustomExercise;

  /// No description provided for @newExercise.
  ///
  /// In en, this message translates to:
  /// **'New exercise'**
  String get newExercise;

  /// No description provided for @muscleGroup.
  ///
  /// In en, this message translates to:
  /// **'Muscle group'**
  String get muscleGroup;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @noWorkoutsYet.
  ///
  /// In en, this message translates to:
  /// **'No workouts yet'**
  String get noWorkoutsYet;

  /// No description provided for @noWorkoutsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Head to the gym and log your first session'**
  String get noWorkoutsSubtitle;

  /// No description provided for @couldNotLoadWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Could not load workouts'**
  String get couldNotLoadWorkouts;

  /// No description provided for @workoutNotFound.
  ///
  /// In en, this message translates to:
  /// **'Workout not found'**
  String get workoutNotFound;

  /// No description provided for @workoutNotFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This session may have been deleted.'**
  String get workoutNotFoundSubtitle;

  /// No description provided for @editWorkout.
  ///
  /// In en, this message translates to:
  /// **'Edit workout'**
  String get editWorkout;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @deleteWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete workout?'**
  String get deleteWorkoutTitle;

  /// No description provided for @deleteWorkoutHint.
  ///
  /// In en, this message translates to:
  /// **'Tap UNDO in the snackbar to restore it.'**
  String get deleteWorkoutHint;

  /// No description provided for @workoutDeleted.
  ///
  /// In en, this message translates to:
  /// **'Workout deleted'**
  String get workoutDeleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get undo;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @noResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No workouts match the applied filters'**
  String get noResultsSubtitle;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @couldNotLoadRoutines.
  ///
  /// In en, this message translates to:
  /// **'Could not load routines'**
  String get couldNotLoadRoutines;

  /// No description provided for @noRoutinesFound.
  ///
  /// In en, this message translates to:
  /// **'No routines found'**
  String get noRoutinesFound;

  /// No description provided for @tryDifferentFilter.
  ///
  /// In en, this message translates to:
  /// **'Try a different filter'**
  String get tryDifferentFilter;

  /// No description provided for @routineNotFound.
  ///
  /// In en, this message translates to:
  /// **'Routine not found'**
  String get routineNotFound;

  /// No description provided for @routineNotFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This routine may have been removed.'**
  String get routineNotFoundSubtitle;

  /// No description provided for @startThisRoutine.
  ///
  /// In en, this message translates to:
  /// **'Start this routine'**
  String get startThisRoutine;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @exportExcel.
  ///
  /// In en, this message translates to:
  /// **'Export to Excel'**
  String get exportExcel;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export to CSV'**
  String get exportCsv;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get dateRange;

  /// No description provided for @exportFormat.
  ///
  /// In en, this message translates to:
  /// **'Export Format'**
  String get exportFormat;

  /// No description provided for @excelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Spreadsheet with styled header and column widths (.xlsx)'**
  String get excelSubtitle;

  /// No description provided for @csvSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Flat file for custom analysis (.csv)'**
  String get csvSubtitle;

  /// No description provided for @overallFatigue.
  ///
  /// In en, this message translates to:
  /// **'Overall fatigue'**
  String get overallFatigue;

  /// No description provided for @weeklyVolume.
  ///
  /// In en, this message translates to:
  /// **'Weekly volume by muscle group'**
  String get weeklyVolume;

  /// No description provided for @fatigueLow.
  ///
  /// In en, this message translates to:
  /// **'Low fatigue — you are fresh'**
  String get fatigueLow;

  /// No description provided for @fatigueMod.
  ///
  /// In en, this message translates to:
  /// **'Moderate fatigue — train smart'**
  String get fatigueMod;

  /// No description provided for @fatigueHigh.
  ///
  /// In en, this message translates to:
  /// **'High fatigue — consider a deload'**
  String get fatigueHigh;

  /// No description provided for @fatigueOver.
  ///
  /// In en, this message translates to:
  /// **'Overtraining risk — rest up'**
  String get fatigueOver;

  /// No description provided for @couldNotLoadFatigue.
  ///
  /// In en, this message translates to:
  /// **'Could not load fatigue'**
  String get couldNotLoadFatigue;

  /// No description provided for @readinessScore.
  ///
  /// In en, this message translates to:
  /// **'Readiness Score'**
  String get readinessScore;

  /// No description provided for @riskAssessment.
  ///
  /// In en, this message translates to:
  /// **'Risk Assessment'**
  String get riskAssessment;

  /// No description provided for @recommendations_.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations_;

  /// No description provided for @sevenDayTrend.
  ///
  /// In en, this message translates to:
  /// **'7-Day Trend'**
  String get sevenDayTrend;

  /// No description provided for @acuteLoad.
  ///
  /// In en, this message translates to:
  /// **'Acute load'**
  String get acuteLoad;

  /// No description provided for @chronicLoad.
  ///
  /// In en, this message translates to:
  /// **'Chronic load'**
  String get chronicLoad;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @workloadRatio.
  ///
  /// In en, this message translates to:
  /// **'Workload ratio'**
  String get workloadRatio;

  /// No description provided for @injuryRisk.
  ///
  /// In en, this message translates to:
  /// **'Injury Risk'**
  String get injuryRisk;

  /// No description provided for @overtrainingRisk.
  ///
  /// In en, this message translates to:
  /// **'Overtraining Risk'**
  String get overtrainingRisk;

  /// No description provided for @compositeRisk.
  ///
  /// In en, this message translates to:
  /// **'Composite Risk'**
  String get compositeRisk;

  /// No description provided for @trainingPlan.
  ///
  /// In en, this message translates to:
  /// **'Training Plan'**
  String get trainingPlan;

  /// No description provided for @generatingPlan.
  ///
  /// In en, this message translates to:
  /// **'Generating plan...'**
  String get generatingPlan;

  /// No description provided for @loadingFatigueData.
  ///
  /// In en, this message translates to:
  /// **'Loading fatigue data...'**
  String get loadingFatigueData;

  /// No description provided for @computeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Compute server unavailable'**
  String get computeUnavailable;

  /// No description provided for @computeUnavailableDesc.
  ///
  /// In en, this message translates to:
  /// **'The training plan requires the compute engine to be running. Start the backend server and go to the Fatigue tab first.'**
  String get computeUnavailableDesc;

  /// No description provided for @weekObjective.
  ///
  /// In en, this message translates to:
  /// **'Week Objective'**
  String get weekObjective;

  /// No description provided for @weeklySchedule.
  ///
  /// In en, this message translates to:
  /// **'Weekly Schedule'**
  String get weeklySchedule;

  /// No description provided for @coachNotes.
  ///
  /// In en, this message translates to:
  /// **'Coach Notes'**
  String get coachNotes;

  /// No description provided for @periodizationRationale.
  ///
  /// In en, this message translates to:
  /// **'Periodization Rationale'**
  String get periodizationRationale;

  /// No description provided for @rest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get rest;

  /// No description provided for @targetLoad.
  ///
  /// In en, this message translates to:
  /// **'target load'**
  String get targetLoad;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @sets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get sets;

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @weightLb.
  ///
  /// In en, this message translates to:
  /// **'Weight (lb)'**
  String get weightLb;

  /// No description provided for @rpe.
  ///
  /// In en, this message translates to:
  /// **'RPE'**
  String get rpe;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @weightUnit.
  ///
  /// In en, this message translates to:
  /// **'Weight unit'**
  String get weightUnit;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get langSpanish;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @noRoutinesYet.
  ///
  /// In en, this message translates to:
  /// **'No routines yet'**
  String get noRoutinesYet;

  /// No description provided for @noRoutinesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a routine to organize your training'**
  String get noRoutinesSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
