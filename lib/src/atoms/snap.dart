import '../di/snap_registry.dart';

// ---------------------------------------------------------------------------
// Snap<T> — Upgraded Atomic State Signal
//
// Features:
//   • Pure Variable Interpolation: '$city' evaluates to value via toString()
//   • Typed Getter: 'city.value' allows accessing the typed object directly
//   • Fine-grained tracking: automatic rebuilds when read inside a SnapCell
// ---------------------------------------------------------------------------

final class Snap<T> {
  final String name;
  final T _initialValue;

  Snap(this.name, this._initialValue) {
    SnapRegistry.instance.getSignal<T>(name, () => _initialValue);
  }

  /// Access the typed underlying value directly and registers it for reactivity.
  T get value {
    SnapRegistry.instance.logReadHook(name);
    return SnapRegistry.instance.getSignal<T>(name, () => _initialValue);
  }

  /// Internal reader that triggers reactive tracking (used by string overrides)
  T get _peek {
    SnapRegistry.instance.logReadHook(name);
    return SnapRegistry.instance.getSignal<T>(name, () => _initialValue);
  }

  /// Mutates the state and triggers rebuilds of all bound cells and dependencies.
  void set(T newValue) {
    final old = SnapRegistry.instance.getSignal<T>(name, () => _initialValue);
    if (old == newValue) return;
    SnapRegistry.instance.writeSignal(name, newValue);
    SnapRegistry.instance.dispatch(name, old, newValue);
  }

  /// Shorthand alias to update the state.
  void update(T newValue) => set(newValue);

  @override
  String toString() => _peek.toString();

  @override
  bool operator ==(Object other) {
    if (other is Snap<T>) return _peek == other._peek;
    return _peek == other;
  }

  @override
  int get hashCode => _peek.hashCode;
}
