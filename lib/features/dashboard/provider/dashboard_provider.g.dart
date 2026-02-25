// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dashboardRepository)
final dashboardRepositoryProvider = DashboardRepositoryProvider._();

final class DashboardRepositoryProvider extends $FunctionalProvider<
    DashboardRepository,
    DashboardRepository,
    DashboardRepository> with $Provider<DashboardRepository> {
  DashboardRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dashboardRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dashboardRepositoryHash();

  @$internal
  @override
  $ProviderElement<DashboardRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DashboardRepository create(Ref ref) {
    return dashboardRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DashboardRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DashboardRepository>(value),
    );
  }
}

String _$dashboardRepositoryHash() =>
    r'3551e5fdd95ef3d930edf72d251cb2d06134ea0a';

@ProviderFor(fatigueMetrics)
final fatigueMetricsProvider = FatigueMetricsProvider._();

final class FatigueMetricsProvider extends $FunctionalProvider<
        AsyncValue<FatigueMetrics>, FatigueMetrics, FutureOr<FatigueMetrics>>
    with $FutureModifier<FatigueMetrics>, $FutureProvider<FatigueMetrics> {
  FatigueMetricsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'fatigueMetricsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$fatigueMetricsHash();

  @$internal
  @override
  $FutureProviderElement<FatigueMetrics> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<FatigueMetrics> create(Ref ref) {
    return fatigueMetrics(ref);
  }
}

String _$fatigueMetricsHash() => r'7ef4ca6fc8d87ca6516a3e308548661c60634edc';

@ProviderFor(recentSessions)
final recentSessionsProvider = RecentSessionsProvider._();

final class RecentSessionsProvider extends $FunctionalProvider<
        AsyncValue<List<WorkoutSession>>,
        List<WorkoutSession>,
        FutureOr<List<WorkoutSession>>>
    with
        $FutureModifier<List<WorkoutSession>>,
        $FutureProvider<List<WorkoutSession>> {
  RecentSessionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'recentSessionsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recentSessionsHash();

  @$internal
  @override
  $FutureProviderElement<List<WorkoutSession>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<WorkoutSession>> create(Ref ref) {
    return recentSessions(ref);
  }
}

String _$recentSessionsHash() => r'2267c895f5eee17c6510f9db172fff8f148d6751';

@ProviderFor(activeAlerts)
final activeAlertsProvider = ActiveAlertsProvider._();

final class ActiveAlertsProvider extends $FunctionalProvider<
        AsyncValue<List<Alert>>, List<Alert>, FutureOr<List<Alert>>>
    with $FutureModifier<List<Alert>>, $FutureProvider<List<Alert>> {
  ActiveAlertsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeAlertsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeAlertsHash();

  @$internal
  @override
  $FutureProviderElement<List<Alert>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Alert>> create(Ref ref) {
    return activeAlerts(ref);
  }
}

String _$activeAlertsHash() => r'fc6e1769cee6d14d58bfd6b8948db06b223132eb';
