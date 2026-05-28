// ---------------------------------------------------------------------------
// SnapObserver — Enhanced global state-change observer
// ---------------------------------------------------------------------------

/// Implement this interface to hook into all state mutations and controller
/// lifecycle events. Ideal for Crashlytics, analytics, and debug logging.
///
/// ```dart
/// SnapRegistry.observer = MyAnalyticsObserver();
/// ```
abstract interface class SnapObserver {
  /// Called every time a [Snap] or [SnapAsync] value changes.
  void onStateChange(String name, dynamic oldValue, dynamic newValue);

  /// Called when an async state throws an unhandled exception.
  void onError(String name, Object error, StackTrace stackTrace);

  /// Called when a [SnapController] is created by [SnapRegistry].
  void onControllerCreated(Type controllerType);

  /// Called when a [SnapController] is disposed.
  void onControllerDisposed(Type controllerType);
}
