// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fatigue_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fatigueRepository)
final fatigueRepositoryProvider = FatigueRepositoryProvider._();

final class FatigueRepositoryProvider extends $FunctionalProvider<
    FatigueRepository,
    FatigueRepository,
    FatigueRepository> with $Provider<FatigueRepository> {
  FatigueRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'fatigueRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$fatigueRepositoryHash();

  @$internal
  @override
  $ProviderElement<FatigueRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FatigueRepository create(Ref ref) {
    return fatigueRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FatigueRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FatigueRepository>(value),
    );
  }
}

String _$fatigueRepositoryHash() => r'7466b7adecee5939afdbe0351f2675a4a116f6ca';

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

String _$fatigueMetricsHash() => r'ee0feaeb5905aab6d4a79e028628cc77fba58062';
