import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:strengthlabs/core/connectivity/connectivity_cubit.dart';

class _MockConnectivity extends Mock implements Connectivity {}

void main() {
  late _MockConnectivity connectivity;

  setUp(() {
    connectivity = _MockConnectivity();
    when(() => connectivity.onConnectivityChanged)
        .thenAnswer((_) => const Stream<List<ConnectivityResult>>.empty());
  });

  blocTest<ConnectivityCubit, ConnectivityStatus>(
    'emits offline when initial check returns [none]',
    build: () {
      when(() => connectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      return ConnectivityCubit(connectivity: connectivity);
    },
    act: (cubit) => cubit.start(),
    expect: () => [ConnectivityStatus.offline],
  );

  blocTest<ConnectivityCubit, ConnectivityStatus>(
    'stays online when wifi is reported',
    build: () {
      when(() => connectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      return ConnectivityCubit(connectivity: connectivity);
    },
    act: (cubit) => cubit.start(),
    verify: (cubit) => expect(cubit.state, ConnectivityStatus.online),
  );

  blocTest<ConnectivityCubit, ConnectivityStatus>(
    'treats any non-none interface as online (wifi + none)',
    build: () {
      when(() => connectivity.checkConnectivity()).thenAnswer((_) async =>
          [ConnectivityResult.wifi, ConnectivityResult.none]);
      return ConnectivityCubit(connectivity: connectivity);
    },
    act: (cubit) => cubit.start(),
    verify: (cubit) => expect(cubit.state, ConnectivityStatus.online),
  );

  blocTest<ConnectivityCubit, ConnectivityStatus>(
    'returns to online when interface comes back',
    build: () {
      final controller = StreamController<List<ConnectivityResult>>();
      when(() => connectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => connectivity.onConnectivityChanged)
          .thenAnswer((_) => controller.stream);
      addTearDown(controller.close);
      final cubit = ConnectivityCubit(connectivity: connectivity);
      // Inject events after start() so the listener is wired.
      Future.microtask(() async {
        await cubit.start();
        controller.add([ConnectivityResult.wifi]);
      });
      return cubit;
    },
    skip: 1, // skip the initial offline emission
    expect: () => const [ConnectivityStatus.online],
  );
}
