class ApiConstants {
  ApiConstants._();

  // Backend base URL. Points at the deployed Cloudflare-fronted server by
  // default so a fresh `flutter run` on a physical device just works.
  // Override for local development:
  //   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080   (emulator)
  //   flutter run --dart-define=API_BASE_URL=http://192.168.1.X:8080 (LAN)
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.blocsa.com',
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
