class ApiConstants {
  ApiConstants._();

  static const baseUrl = 'http://localhost:8000';

  // Auth
  static const register = '/auth/register';
  static const login = '/auth/login';
  static const refresh = '/auth/refresh';
  static const me = '/auth/me';

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

  // Compute engine (localhost:8001 when running separately)
  static const computeBaseUrl = 'http://localhost:8001';
  static const computeFatigue = '/compute/fatigue';
  static const computeRisk = '/compute/risk';
  static const computePlan = '/compute/plan';

  // JWT
  static const tokenHeader = 'Authorization';
  static String bearerToken(String token) => 'Bearer $token';
}
