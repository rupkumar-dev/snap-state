

import 'dart:async';

import 'package:snap_state/src/core/container.dart';
import 'package:snap_state/src/types/snap_sync.dart';

/// 🌊 ASYNC STATES
sealed class AsyncSnapState<T> { const AsyncSnapState(); }
final class SnapLoading<T> extends AsyncSnapState<T> { const SnapLoading(); }
final class SnapError<T> extends AsyncSnapState<T> {
  final Object error;
  const SnapError(this.error);
}
final class SnapData<T> extends AsyncSnapState<T> {
  final T data;
  const SnapData(this.data);
}

/// 🚀 AUTOMATED COMPUTED ASYNC ENGINE
final class SnapComputedAsync<T> {
  final String name;
  final Future<T> Function() _futureFn;
  int _activeMutationTicket = 0;

  SnapComputedAsync(this.name, Snap dependentSignal, this._futureFn) {
    SnapContainer.get<AsyncSnapState<T>>(name, () => SnapLoading<T>());
    SnapContainer.registerDependency(dependentSignal.name, () => execute());
    scheduleMicrotask(() => execute());
  }

  /// 🎯 GETTER PROPERTY: Allows reading via 'weatherController.weatherApi.state' cleanly
  AsyncSnapState<T> get state {
    SnapContainer.logReadHook(name);
    return SnapContainer.get<AsyncSnapState<T>>(name, () => SnapLoading<T>());
  }

  Future<void> execute() async {
    final ticket = ++_activeMutationTicket;
    final old = SnapContainer.get<AsyncSnapState<T>>(name, () => SnapLoading<T>());
    
    if (ticket == _activeMutationTicket) {
      SnapContainer.registry[name] = SnapLoading<T>();
      SnapContainer.dispatchUpdate(name, old, SnapLoading<T>());
    }

    try {
      final result = await _futureFn();
      if (ticket != _activeMutationTicket) return;

      final currentOld = SnapContainer.get<AsyncSnapState<T>>(name, () => SnapLoading<T>());
      SnapContainer.registry[name] = SnapData<T>(result);
      SnapContainer.dispatchUpdate(name, currentOld, SnapData<T>(result));
    } catch (e, stack) {
      if (ticket != _activeMutationTicket) return;

      final currentOld = SnapContainer.get<AsyncSnapState<T>>(name, () => SnapLoading<T>());
      SnapContainer.registry[name] = SnapError<T>(e);
      SnapContainer.dispatchUpdate(name, currentOld, SnapError<T>(e));
      SnapContainer.observer?.onError(name, e, stack);
    }
  }
}
