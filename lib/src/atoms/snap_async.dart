import 'dart:async';
import '../di/snap_registry.dart';
import 'snap.dart';

// ---------------------------------------------------------------------------
// AsyncValue<T> — Standard State Containers for Asynchronous Computations
// ---------------------------------------------------------------------------

sealed class AsyncValue<T> {
  const AsyncValue();
}

class AsyncLoading<T> extends AsyncValue<T> {
  const AsyncLoading();
}

class AsyncData<T> extends AsyncValue<T> {
  final T data;
  const AsyncData(this.data);
}

class AsyncError<T> extends AsyncValue<T> {
  final Object error;
  const AsyncError(this.error);
}

// ---------------------------------------------------------------------------
// SnapAsync<T> — Reactive Asynchronous Computation Engine
//
// Automatically listens to multiple synchronous/asynchronous dependencies
// and runs a future computation when any of them mutate.
// Includes active-ticket tracking to discard stale network responses.
// ---------------------------------------------------------------------------

final class SnapAsync<T> {
  final String name;
  final List<dynamic> _dependencies;
  final Future<T> Function() _futureFn;
  int _activeMutationTicket = 0;

  SnapAsync(
    this.name, {
    required List<dynamic> listen,
    required Future<T> Function() compute,
  })  : _dependencies = listen,
        _futureFn = compute {
    SnapRegistry.instance.getSignal<AsyncValue<T>>(name, () => AsyncLoading<T>());

    // Wire up listeners to each dependency
    for (final dep in _dependencies) {
      if (dep is Snap) {
        SnapRegistry.instance.addComputedTrigger(dep.name, execute);
      } else if (dep is SnapAsync) {
        SnapRegistry.instance.addComputedTrigger(dep.name, execute);
      }
    }
    // Initial run
    scheduleMicrotask(() => execute());
  }

  /// Accesses the underlying [AsyncValue] state and registers it for reactivity.
  AsyncValue<T> get value {
    SnapRegistry.instance.logReadHook(name);
    return SnapRegistry.instance.getSignal<AsyncValue<T>>(name, () => AsyncLoading<T>());
  }

  /// Backwards-compatibility alias for [value].
  AsyncValue<T> get state => value;

  /// Executes the future computation, maintaining concurrency tickets.
  Future<void> execute() async {
    final ticket = ++_activeMutationTicket;
    final old = SnapRegistry.instance.getSignal<AsyncValue<T>>(name, () => AsyncLoading<T>());

    // Set status to loading before execution
    if (ticket == _activeMutationTicket) {
      SnapRegistry.instance.writeSignal(name, AsyncLoading<T>());
      SnapRegistry.instance.dispatch(name, old, AsyncLoading<T>());
    }

    try {
      final result = await _futureFn();
      if (ticket != _activeMutationTicket) return;

      final currentOld = SnapRegistry.instance.getSignal<AsyncValue<T>>(name, () => AsyncLoading<T>());
      SnapRegistry.instance.writeSignal(name, AsyncData<T>(result));
      SnapRegistry.instance.dispatch(name, currentOld, AsyncData<T>(result));
    } catch (e, stack) {
      if (ticket != _activeMutationTicket) return;

      final currentOld = SnapRegistry.instance.getSignal<AsyncValue<T>>(name, () => AsyncLoading<T>());
      SnapRegistry.instance.writeSignal(name, AsyncError<T>(e));
      SnapRegistry.instance.dispatch(name, currentOld, AsyncError<T>(e));
      SnapRegistry.observer?.onError(name, e, stack);
    }
  }

  /// Manually force a re-evaluation of this asynchronous pipeline.
  void refresh() => execute();
}
