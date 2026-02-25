// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$planRepositoryHash() => r'bd4d667daae5cb9c00a0600d71bcc148246dff1c';

/// See also [planRepository].
@ProviderFor(planRepository)
final planRepositoryProvider = AutoDisposeProvider<PlanRepository>.internal(
  planRepository,
  name: r'planRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$planRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlanRepositoryRef = AutoDisposeProviderRef<PlanRepository>;
String _$weeklyPlanHash() => r'70b4506f0d1d758961b53083f3b9324d07ea0f52';

/// See also [weeklyPlan].
@ProviderFor(weeklyPlan)
final weeklyPlanProvider =
    AutoDisposeFutureProvider<List<PlanWorkout>>.internal(
  weeklyPlan,
  name: r'weeklyPlanProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$weeklyPlanHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WeeklyPlanRef = AutoDisposeFutureProviderRef<List<PlanWorkout>>;
String _$planRecommendationHash() =>
    r'2ff0d63cfe6268e08482960a4cd635414580737e';

/// See also [planRecommendation].
@ProviderFor(planRecommendation)
final planRecommendationProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
  planRecommendation,
  name: r'planRecommendationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$planRecommendationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlanRecommendationRef
    = AutoDisposeFutureProviderRef<Map<String, dynamic>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
