import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:strengthlabs_beta/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:strengthlabs_beta/features/auth/presentation/cubit/auth_state.dart';
import 'package:strengthlabs_beta/features/auth/presentation/pages/login_page.dart';
import 'package:strengthlabs_beta/features/auth/presentation/pages/register_page.dart';
import 'package:strengthlabs_beta/features/export/presentation/pages/export_page.dart';
import 'package:strengthlabs_beta/features/fatigue/presentation/pages/fatigue_dashboard_page.dart';
import 'package:strengthlabs_beta/features/plan/presentation/pages/plan_page.dart';
import 'package:strengthlabs_beta/features/routines/presentation/pages/routine_detail_page.dart';
import 'package:strengthlabs_beta/features/routines/presentation/pages/routines_page.dart';
import 'package:strengthlabs_beta/features/workouts/presentation/cubit/active_workout_cubit.dart';
import 'package:strengthlabs_beta/features/workouts/presentation/pages/active_workout_page.dart';
import 'package:strengthlabs_beta/features/workouts/presentation/pages/workout_detail_page.dart';
import 'package:strengthlabs_beta/features/workouts/presentation/pages/workout_list_page.dart';
import 'package:strengthlabs_beta/shared/widgets/main_shell.dart';

class AppRouter {
  AppRouter._();

  static GoRouter createRouter(AuthCubit authCubit) {
    final notifier = _AuthNotifier(authCubit);

    return GoRouter(
      initialLocation: '/login',
      refreshListenable: notifier,
      redirect: (context, state) {
        final authState = authCubit.state;
        final loc = state.matchedLocation;
        final isAuthRoute = loc == '/login' || loc == '/register';

        // Still checking stored credentials — don't redirect yet
        if (authState is AuthInitial || authState is AuthLoading) return null;

        if ((authState is AuthUnauthenticated || authState is AuthError) &&
            !isAuthRoute) {
          return '/login';
        }

        if (authState is AuthAuthenticated && isAuthRoute) {
          return '/workouts';
        }

        return null;
      },
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
          builder: (_, state) {
            final extra = state.extra;
            return ActiveWorkoutPage(
              template: extra is ActiveWorkoutTemplate ? extra : null,
            );
          },
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
                  path: '/plan',
                  builder: (_, _s) => const PlanPage(),
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
}

/// Bridges AuthCubit stream to GoRouter's refreshListenable mechanism.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(AuthCubit cubit) {
    _sub = cubit.stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
