import '../core/container.dart';



/// ⚡ THE PURE ATOMIC SIGNAL (NO `.value`, NO `()`)
final class Snap<T> {
  final String name;
  final T _initialValue;

  Snap(this.name, this._initialValue) {
    SnapContainer.get<T>(name, () => _initialValue);
  }

  /// Internal reader that triggers reactive tracking
  T get _peek {
    SnapContainer.logReadHook(name);
    return SnapContainer.get<T>(name, () => _initialValue);
  }

  void set(T newValue) {
    final old = SnapContainer.get<T>(name, () => _initialValue);
    if (old == newValue) return;
    SnapContainer.registry[name] = newValue;
    SnapContainer.dispatchUpdate(name, old, newValue);
  }

  /// 🎯 OVERRIDE TOSTRING: This allows string interpolation like '$city' to look up data automatically
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