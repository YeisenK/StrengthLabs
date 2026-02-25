// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(planRepository)
final planRepositoryProvider = PlanRepositoryProvider._();

final class PlanRepositoryProvider
    extends $FunctionalProvider<PlanRepository, PlanRepository, PlanRepository>
    with $Provider<PlanRepository> {
  PlanRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'planRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$planRepositoryHash();

  @$internal
  @override
  $ProviderElement<PlanRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlanRepository create(Ref ref) {
    return planRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlanRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlanRepository>(value),
    );
  }
}

String _$planRepositoryHash() => r'bd4d667daae5cb9c00a0600d71bcc148246dff1c';

@ProviderFor(weeklyPlan)
final weeklyPlanProvider = WeeklyPlanProvider._();

final class WeeklyPlanProvider extends $FunctionalProvider<
        AsyncValue<List<PlanWorkout>>,
        List<PlanWorkout>,
        FutureOr<List<PlanWorkout>>>
    with
        $FutureModifier<List<PlanWorkout>>,
        $FutureProvider<List<PlanWorkout>> {
  WeeklyPlanProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'weeklyPlanProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$weeklyPlanHash();

  @$internal
  @override
  $FutureProviderElement<List<PlanWorkout>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<PlanWorkout>> create(Ref ref) {
    return weeklyPlan(ref);
  }
}

String _$weeklyPlanHash() => r'70b4506f0d1d758961b53083f3b9324d07ea0f52';

@ProviderFor(planRecommendation)
final planRecommendationProvider = PlanRecommendationProvider._();

final class PlanRecommendationProvider extends $FunctionalProvider<
        AsyncValue<Map<String, dynamic>>,
        Map<String, dynamic>,
        FutureOr<Map<String, dynamic>>>
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  PlanRecommendationProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'planRecommendationProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$planRecommendationHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    return planRecommendation(ref);
  }
}

String _$planRecommendationHash() =>
    r'2ff0d63cfe6268e08482960a4cd635414580737e';
