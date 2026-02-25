// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardRepositoryHash() =>
    r'3551e5fdd95ef3d930edf72d251cb2d06134ea0a';

/// See also [dashboardRepository].
@ProviderFor(dashboardRepository)
final dashboardRepositoryProvider =
    AutoDisposeProvider<DashboardRepository>.internal(
  dashboardRepository,
  name: r'dashboardRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dashboardRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardRepositoryRef = AutoDisposeProviderRef<DashboardRepository>;
String _$fatigueMetricsHash() => r'7ef4ca6fc8d87ca6516a3e308548661c60634edc';

/// See also [fatigueMetrics].
@ProviderFor(fatigueMetrics)
final fatigueMetricsProvider =
    AutoDisposeFutureProvider<FatigueMetrics>.internal(
  fatigueMetrics,
  name: r'fatigueMetricsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fatigueMetricsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FatigueMetricsRef = AutoDisposeFutureProviderRef<FatigueMetrics>;
String _$recentSessionsHash() => r'2267c895f5eee17c6510f9db172fff8f148d6751';

/// See also [recentSessions].
@ProviderFor(recentSessions)
final recentSessionsProvider =
    AutoDisposeFutureProvider<List<WorkoutSession>>.internal(
  recentSessions,
  name: r'recentSessionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentSessionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentSessionsRef = AutoDisposeFutureProviderRef<List<WorkoutSession>>;
String _$activeAlertsHash() => r'fc6e1769cee6d14d58bfd6b8948db06b223132eb';

/// See also [activeAlerts].
@ProviderFor(activeAlerts)
final activeAlertsProvider = AutoDisposeFutureProvider<List<Alert>>.internal(
  activeAlerts,
  name: r'activeAlertsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$activeAlertsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveAlertsRef = AutoDisposeFutureProviderRef<List<Alert>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
