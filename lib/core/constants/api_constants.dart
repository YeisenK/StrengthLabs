class ApiConstants {
  ApiConstants._();

  // Backend base URL. Override at build/run time:
  //   flutter run --dart-define=API_BASE_URL=http://192.168.1.X:8000
  // Default targets the Android emulator loopback to the host machine.
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  // Auth
  static const register = '/auth/register';
  static const login = '/auth/login';
  static const refresh = '/auth/refresh';
  static const me = '/auth/me';
  static const authGoogle = '/auth/google';

  // Workouts
  static const workouts = '/workouts';
  static String workoutById(String id) => '/workouts/$id';

  // Exercises
  static const exercises = '/exercises';

  // Fatigue
  static const fatigueSummary = '/fatigue/summary';
  static const fatigueWeekly = '/fatigue/weekly';

  // Routines
  static const routines = '/routines';
  static String routineById(String id) => '/routines/$id';

  // Export
  static const exportXlsx = '/export/xlsx';
  static const exportCsv = '/export/csv';
}
