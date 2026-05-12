import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:strengthlabs/core/constants/app_colors.dart';
import 'package:strengthlabs/core/network/dio_client.dart';
import 'package:strengthlabs/core/router/app_router.dart';
import 'package:strengthlabs/core/storage/token_storage.dart';
import 'package:strengthlabs/features/auth/data/auth_repository.dart';
import 'package:strengthlabs/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:strengthlabs/features/fatigue/data/fatigue_repository.dart';
import 'package:strengthlabs/features/fatigue/presentation/cubit/fatigue_cubit.dart';
import 'package:strengthlabs/features/plan/data/plan_builder.dart';
import 'package:strengthlabs/features/plan/presentation/cubit/plan_cubit.dart';
import 'package:strengthlabs/features/routines/data/routine_repository.dart';
import 'package:strengthlabs/features/routines/presentation/cubit/routines_cubit.dart';
import 'package:strengthlabs/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:strengthlabs/features/settings/presentation/cubit/settings_state.dart';
import 'package:strengthlabs/features/workouts/data/workout_repository.dart';
import 'package:strengthlabs/features/workouts/presentation/cubit/workouts_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:strengthlabs/l10n/app_localizations.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final TokenStorage _tokenStorage;
  late final DioClient _dioClient;
  late final AuthCubit _authCubit;
  late final SettingsCubit _settingsCubit;
  late final WorkoutRepository _workoutRepo;
  late final FatigueRepository _fatigueRepo;
  late final RoutineRepository _routineRepo;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _tokenStorage = TokenStorage();
    _dioClient = DioClient(_tokenStorage);

    _authCubit = AuthCubit(AuthRepository(_dioClient, _tokenStorage));
    _settingsCubit = SettingsCubit();
    _workoutRepo = WorkoutRepository(_dioClient);
    _fatigueRepo = FatigueRepository(_dioClient);
    _routineRepo = RoutineRepository(_dioClient);

    _router = AppRouter.createRouter(_authCubit);

    AppRouter.primeOnboardingFlag();
    _authCubit.checkAuthStatus();
    _settingsCubit.load();
  }

  @override
  void dispose() {
    _authCubit.close();
    _settingsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _workoutRepo),
        RepositoryProvider.value(value: _fatigueRepo),
        RepositoryProvider.value(value: _routineRepo),
      ],
      child: MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider.value(value: _settingsCubit),
        BlocProvider(create: (_) => WorkoutsCubit(_workoutRepo)),
        BlocProvider(create: (_) => RoutinesCubit(_routineRepo)),
        BlocProvider(create: (_) => FatigueCubit(_fatigueRepo)),
        BlocProvider(create: (_) => PlanCubit(const PlanBuilder())),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) => MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          themeMode: settings.themeMode,
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: _router,
        ),
      ),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seedColor,
      brightness: brightness,
      surface: isDark ? AppColors.surfaceDark : null,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: isDark
          ? colorScheme.copyWith(surface: AppColors.surfaceDark)
          : colorScheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.backgroundDark : colorScheme.surface,
      cardTheme: CardThemeData(
        color: isDark ? AppColors.cardDark : colorScheme.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? AppColors.divider : colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:
            isDark ? AppColors.surfaceDark : colorScheme.surfaceContainer,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
          }
          return const TextStyle(fontSize: 12);
        }),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? AppColors.backgroundDark : colorScheme.surface,
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
        dividerColor: isDark ? AppColors.divider : colorScheme.outlineVariant,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.cardDark : colorScheme.surfaceContainerLow,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
