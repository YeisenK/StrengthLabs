import 'package:asip_fitness_analytics/features/dashboard/screen/dashboard_screen.dart';
import 'package:asip_fitness_analytics/features/fatigue/screen/fatigue_analysis_screen.dart';
import 'package:asip_fitness_analytics/features/plan/screen/adaptive_plan_screen.dart';
import 'package:asip_fitness_analytics/features/session/screen/session_registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: NavigationBar(
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.fitness_center_outlined),
                  selectedIcon: Icon(Icons.fitness_center),
                  label: 'Session',
                ),
                NavigationDestination(
                  icon: Icon(Icons.analytics_outlined),
                  selectedIcon: Icon(Icons.analytics),
                  label: 'Fatigue',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_awesome_outlined),
                  selectedIcon: Icon(Icons.auto_awesome),
                  label: 'Plan',
                ),
              ],
              onDestinationSelected: (index) {
                switch (index) {
                  case 0:
                    context.go('/dashboard');
                    break;
                  case 1:
                    context.go('/session');
                    break;
                  case 2:
                    context.go('/fatigue');
                    break;
                  case 3:
                    context.go('/plan');
                    break;
                }
              },
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/session',
            name: 'session',
            builder: (context, state) => const SessionRegistrationScreen(),
          ),
          GoRoute(
            path: '/fatigue',
            name: 'fatigue',
            builder: (context, state) => const FatigueAnalysisScreen(),
          ),
          GoRoute(
            path: '/plan',
            name: 'plan',
            builder: (context, state) => const AdaptivePlanScreen(),
          ),
        ],
      ),
    ],
  );
});