import 'package:go_router/go_router.dart';
import 'package:strengthlabs_beta/features/auth/presentation/pages/login_page.dart';
import 'package:strengthlabs_beta/features/auth/presentation/pages/register_page.dart';
import 'package:strengthlabs_beta/features/export/presentation/pages/export_page.dart';
import 'package:strengthlabs_beta/features/fatigue/presentation/pages/fatigue_dashboard_page.dart';
import 'package:strengthlabs_beta/features/routines/presentation/pages/routine_detail_page.dart';
import 'package:strengthlabs_beta/features/routines/presentation/pages/routines_page.dart';
import 'package:strengthlabs_beta/features/workouts/presentation/pages/active_workout_page.dart';
import 'package:strengthlabs_beta/features/workouts/presentation/pages/workout_detail_page.dart';
import 'package:strengthlabs_beta/features/workouts/presentation/pages/workout_list_page.dart';
import 'package:strengthlabs_beta/shared/widgets/main_shell.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, _s) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, _s) => const RegisterPage(),
      ),
      GoRoute(
        path: '/active-workout',
        builder: (_, _s) => const ActiveWorkoutPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/workouts',
                builder: (_, _s) => const WorkoutListPage(),
                routes: [
                  GoRoute(
                    path: 'detail/:id',
                    builder: (_, state) =>
                        WorkoutDetailPage(id: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/routines',
                builder: (_, _s) => const RoutinesPage(),
                routes: [
                  GoRoute(
                    path: 'detail/:id',
                    builder: (_, state) =>
                        RoutineDetailPage(id: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/fatigue',
                builder: (_, _s) => const FatigueDashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/export',
                builder: (_, _s) => const ExportPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
