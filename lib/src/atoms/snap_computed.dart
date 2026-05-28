import '../di/snap_registry.dart';
import 'snap.dart';
import 'snap_async.dart';

// ---------------------------------------------------------------------------
// SnapComputed<T> — Synchronous Derived State Signal
//
// Automatically recalculates its value synchronously when any of its
// upstream dependencies change, dispatching changes to its downstream elements.
// ---------------------------------------------------------------------------

final class SnapComputed<T> {
  final String name;
  final List<dynamic> _dependencies;
  final T Function() _computeFn;

  SnapComputed(
    this.name, {
    required List<dynamic> listen,
    required T Function() compute,
  })  : _dependencies = listen,
        _computeFn = compute {
    SnapRegistry.instance.getSignal<T>(name, compute);

    // Bind this computed node to re-evaluate when dependencies mutate
    for (final dep in _dependencies) {
      if (dep is Snap) {
        SnapRegistry.instance.addComputedTrigger(dep.name, _recompute);
      } else if (dep is SnapAsync) {
        SnapRegistry.instance.addComputedTrigger(dep.name, _recompute);
      } else if (dep is SnapComputed) {
        SnapRegistry.instance.addComputedTrigger(dep.name, _recompute);
      }
    }
  }

  /// Accesses the derived value and registers it for reactivity.
  T get value {
    SnapRegistry.instance.logReadHook(name);
    return SnapRegistry.instance.getSignal<T>(name, _computeFn);
  }

  /// Internal reader used for operator overrides.
  T get _peek {
    SnapRegistry.instance.logReadHook(name);
    return SnapRegistry.instance.getSignal<T>(name, _computeFn);
  }

  void _recompute() {
    final old = SnapRegistry.instance.getSignal<T>(name, _computeFn);
    final latest = _computeFn();
    if (old == latest) return;
    SnapRegistry.instance.writeSignal(name, latest);
    SnapRegistry.instance.dispatch(name, old, latest);
  }

  @override
  String toString() => _peek.toString();

  @override
  bool operator ==(Object other) {
    if (other is SnapComputed<T>) return _peek == other._peek;
    return _peek == other;
  }

  @override
  int get hashCode => _peek.hashCode;
}
