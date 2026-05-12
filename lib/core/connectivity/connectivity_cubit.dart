import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ConnectivityStatus { online, offline }

/// Streams whether the device currently has any non-`none` network interface.
///
/// `connectivity_plus` reports a list because devices can have several
/// interfaces active at once (e.g. wifi + cellular). We collapse that to a
/// single boolean: online if *any* interface is non-none. This is a
/// best-effort signal — actual reachability can still fail, but the UI uses
/// it to decide whether to show the offline banner and when SyncManager
/// should attempt a drain.
class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  ConnectivityCubit({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        super(ConnectivityStatus.online);

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Hook up after construction (so tests can run the cubit synchronously).
  Future<void> start() async {
    final initial = await _connectivity.checkConnectivity();
    emit(_collapse(initial));
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      emit(_collapse(results));
    });
  }

  ConnectivityStatus _collapse(List<ConnectivityResult> results) {
    final hasAny =
        results.any((r) => r != ConnectivityResult.none);
    return hasAny ? ConnectivityStatus.online : ConnectivityStatus.offline;
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
