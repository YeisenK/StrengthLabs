import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs_beta/core/constants/app_colors.dart';
import 'package:strengthlabs_beta/core/constants/app_strings.dart';
import 'package:strengthlabs_beta/core/router/app_router.dart';
import 'package:strengthlabs_beta/core/storage/workout_local_storage.dart';
import 'package:strengthlabs_beta/features/auth/data/auth_repository.dart';
import 'package:strengthlabs_beta/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:strengthlabs_beta/features/fatigue/data/compute_repository.dart';
import 'package:strengthlabs_beta/features/fatigue/data/fatigue_repository.dart';
import 'package:strengthlabs_beta/features/fatigue/presentation/cubit/fatigue_cubit.dart';
import 'package:strengthlabs_beta/features/plan/data/plan_repository.dart';
import 'package:strengthlabs_beta/features/plan/presentation/cubit/plan_cubit.dart';
import 'package:strengthlabs_beta/features/routines/data/routine_repository.dart';
import 'package:strengthlabs_beta/features/routines/presentation/cubit/routines_cubit.dart';
import 'package:strengthlabs_beta/features/workouts/presentation/cubit/workouts_cubit.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final WorkoutLocalStorage _workoutStorage;
  late final FatigueRepository _fatigueRepo;
  late final ComputeRepository _computeRepo;
  late final PlanRepository _planRepo;

  @override
  void initState() {
    super.initState();
    _workoutStorage = WorkoutLocalStorage();
    _fatigueRepo = FatigueRepository(_workoutStorage);
    _computeRepo = ComputeRepository(_workoutStorage);
    _planRepo = PlanRepository(_computeRepo);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(const AuthRepository())),
        BlocProvider(create: (_) => WorkoutsCubit()),
        BlocProvider(create: (_) => RoutinesCubit(const RoutineRepository())),
        BlocProvider(
          create: (_) => FatigueCubit(_fatigueRepo, _computeRepo),
        ),
        BlocProvider(create: (_) => PlanCubit(_planRepo)),
      ],
      child: MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(Brightness.dark),
        routerConfig: AppRouter.router,
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seedColor,
      brightness: brightness,
      surface: AppColors.surfaceDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme.copyWith(surface: AppColors.surfaceDark),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
          }
          return const TextStyle(fontSize: 12);
        }),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: colorScheme.primary,
        dividerColor: AppColors.divider,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDark,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
