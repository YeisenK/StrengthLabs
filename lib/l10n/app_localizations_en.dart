// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'StrengthLabs';

  @override
  String get login => 'Log in';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get name => 'Name';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get alreadyAccount => 'Already have an account? ';

  @override
  String get signUp => 'Sign up';

  @override
  String get signIn => 'Sign in';

  @override
  String get logout => 'Log out';

  @override
  String get logoutConfirmContent =>
      'You will need to sign in again to access your data.';

  @override
  String get workouts => 'Workouts';

  @override
  String get routines => 'Routines';

  @override
  String get fatigue => 'Fatigue';

  @override
  String get export_ => 'Export';

  @override
  String get plan => 'Plan';

  @override
  String get startWorkout => 'Start workout';

  @override
  String get activeWorkout => 'Active workout';

  @override
  String get finishWorkout => 'Finish workout';

  @override
  String get finishWorkoutTitle => 'Finish workout?';

  @override
  String get onlyCompletedSets => 'Only completed sets will be saved.';

  @override
  String get keepGoing => 'Keep going';

  @override
  String get finish => 'Finish';

  @override
  String get discardWorkoutTitle => 'Discard workout?';

  @override
  String get allProgressLost => 'All progress will be lost.';

  @override
  String get discard => 'Discard';

  @override
  String get addExercise => 'Add exercise';

  @override
  String get addExerciseTitle => 'Add Exercise';

  @override
  String get noExercisesYet => 'No exercises yet';

  @override
  String get noExercisesSubtitle => 'Add your first exercise to get started';

  @override
  String get searchExercises => 'Search exercises...';

  @override
  String get addSet => 'Add set';

  @override
  String get createCustomExercise => 'Create custom exercise';

  @override
  String get newExercise => 'New exercise';

  @override
  String get muscleGroup => 'Muscle group';

  @override
  String get create => 'Create';

  @override
  String get noWorkoutsYet => 'No workouts yet';

  @override
  String get noWorkoutsSubtitle => 'Head to the gym and log your first session';

  @override
  String get couldNotLoadWorkouts => 'Could not load workouts';

  @override
  String get workoutNotFound => 'Workout not found';

  @override
  String get workoutNotFoundSubtitle => 'This session may have been deleted.';

  @override
  String get editWorkout => 'Edit workout';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get deleteWorkoutTitle => 'Delete workout?';

  @override
  String get deleteWorkoutHint => 'Tap UNDO in the snackbar to restore it.';

  @override
  String get workoutDeleted => 'Workout deleted';

  @override
  String get undo => 'UNDO';

  @override
  String get date => 'Date';

  @override
  String get volume => 'Volume';

  @override
  String get noResults => 'No results';

  @override
  String get noResultsSubtitle => 'No workouts match the applied filters';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get clear => 'Clear';

  @override
  String get couldNotLoadRoutines => 'Could not load routines';

  @override
  String get noRoutinesFound => 'No routines found';

  @override
  String get tryDifferentFilter => 'Try a different filter';

  @override
  String get routineNotFound => 'Routine not found';

  @override
  String get routineNotFoundSubtitle => 'This routine may have been removed.';

  @override
  String get startThisRoutine => 'Start this routine';

  @override
  String get all => 'All';

  @override
  String get exportExcel => 'Export to Excel';

  @override
  String get exportCsv => 'Export to CSV';

  @override
  String get dateRange => 'Date range';

  @override
  String get exportFormat => 'Export Format';

  @override
  String get excelSubtitle =>
      'Spreadsheet with styled header and column widths (.xlsx)';

  @override
  String get csvSubtitle => 'Flat file for custom analysis (.csv)';

  @override
  String get overallFatigue => 'Overall fatigue';

  @override
  String get weeklyVolume => 'Weekly volume by muscle group';

  @override
  String get fatigueLow => 'Low fatigue — you are fresh';

  @override
  String get fatigueMod => 'Moderate fatigue — train smart';

  @override
  String get fatigueHigh => 'High fatigue — consider a deload';

  @override
  String get fatigueOver => 'Overtraining risk — rest up';

  @override
  String get couldNotLoadFatigue => 'Could not load fatigue';

  @override
  String get readinessScore => 'Readiness Score';

  @override
  String get riskAssessment => 'Risk Assessment';

  @override
  String get recommendations_ => 'Recommendations';

  @override
  String get sevenDayTrend => '7-Day Trend';

  @override
  String get acuteLoad => 'Acute load';

  @override
  String get chronicLoad => 'Chronic load';

  @override
  String get balance => 'Balance';

  @override
  String get workloadRatio => 'Workload ratio';

  @override
  String get injuryRisk => 'Injury Risk';

  @override
  String get overtrainingRisk => 'Overtraining Risk';

  @override
  String get compositeRisk => 'Composite Risk';

  @override
  String get trainingPlan => 'Training Plan';

  @override
  String get generatingPlan => 'Generating plan...';

  @override
  String get loadingFatigueData => 'Loading fatigue data...';

  @override
  String get computeUnavailable => 'Compute server unavailable';

  @override
  String get computeUnavailableDesc =>
      'The training plan requires the compute engine to be running. Start the backend server and go to the Fatigue tab first.';

  @override
  String get weekObjective => 'Week Objective';

  @override
  String get weeklySchedule => 'Weekly Schedule';

  @override
  String get coachNotes => 'Coach Notes';

  @override
  String get periodizationRationale => 'Periodization Rationale';

  @override
  String get rest => 'Rest';

  @override
  String get targetLoad => 'target load';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get retry => 'Retry';

  @override
  String get sets => 'Sets';

  @override
  String get reps => 'Reps';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get weightLb => 'Weight (lb)';

  @override
  String get rpe => 'RPE';

  @override
  String get notes => 'Notes';

  @override
  String get duration => 'Duration';

  @override
  String get exercises => 'Exercises';

  @override
  String get settings => 'Settings';

  @override
  String get account => 'Account';

  @override
  String get preferences => 'Preferences';

  @override
  String get weightUnit => 'Weight unit';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get langEnglish => 'English';

  @override
  String get langSpanish => 'Español';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get noRoutinesYet => 'No routines yet';

  @override
  String get noRoutinesSubtitle => 'Create a routine to organize your training';
}
