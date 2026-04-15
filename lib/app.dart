import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs_beta/core/constants/app_colors.dart';
import 'package:strengthlabs_beta/core/constants/app_strings.dart';
import 'package:strengthlabs_beta/core/network/dio_client.dart';
import 'package:strengthlabs_beta/core/router/app_router.dart';
import 'package:strengthlabs_beta/core/storage/token_storage.dart';
import 'package:strengthlabs_beta/core/storage/workout_local_storage.dart';
import 'package:strengthlabs_beta/features/auth/data/auth_repository.dart';
import 'package:strengthlabs_beta/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:strengthlabs_beta/features/fatigue/data/fatigue_repository.dart';
import 'package:strengthlabs_beta/features/fatigue/presentation/cubit/fatigue_cubit.dart';
import 'package:strengthlabs_beta/features/plan/data/plan_repository.dart';
import 'package:strengthlabs_beta/features/plan/presentation/cubit/plan_cubit.dart';
import 'package:strengthlabs_beta/features/routines/data/routine_repository.dart';
import 'package:strengthlabs_beta/features/routines/presentation/cubit/routines_cubit.dart';
import 'package:strengthlabs_beta/features/workouts/data/workout_repository.dart';
import 'package:strengthlabs_beta/features/workouts/presentation/cubit/workouts_cubit.dart';
import 'package:go_router/go_router.dart';

// Local import only needed for PlanRepository's ComputeRepository
import 'package:strengthlabs_beta/features/fatigue/data/compute_repository.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final TokenStorage _tokenStorage;
  late final DioClient _dioClient;
  late final AuthCubit _authCubit;
  late final WorkoutRepository _workoutRepo;
  late final FatigueRepository _fatigueRepo;
  late final RoutineRepository _routineRepo;
  late final ComputeRepository _computeRepo;
  late final PlanRepository _planRepo;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _tokenStorage = TokenStorage();
    _dioClient = DioClient(_tokenStorage);

    _authCubit = AuthCubit(AuthRepository(_dioClient, _tokenStorage));
    _workoutRepo = WorkoutRepository(_dioClient);
    _fatigueRepo = FatigueRepository(_dioClient);
    _routineRepo = RoutineRepository(_dioClient);

    // ComputeRepository / PlanRepository stay local — plan generation uses
    // metrics already fetched from the API (via FatigueCubit) and builds
    // the weekly session plan locally without hitting the backend.
    _computeRepo = ComputeRepository(WorkoutLocalStorage());
    _planRepo = PlanRepository(_computeRepo);

    _router = AppRouter.createRouter(_authCubit);

    // Restore session on startup
    _authCubit.checkAuthStatus();
  }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // AuthCubit is created manually above so the router can listen to it
        BlocProvider.value(value: _authCubit),
        BlocProvider(create: (_) => WorkoutsCubit(_workoutRepo)),
        BlocProvider(create: (_) => RoutinesCubit(_routineRepo)),
        BlocProvider(create: (_) => FatigueCubit(_fatigueRepo)),
        BlocProvider(create: (_) => PlanCubit(_planRepo)),
      ],
      child: MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(Brightness.dark),
        routerConfig: _router,
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
