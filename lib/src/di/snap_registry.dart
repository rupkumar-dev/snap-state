import 'package:flutter/widgets.dart';
import '../controller/snap_controller.dart';
import '../observability/snap_logger.dart';
import '../observability/snap_observer.dart';

// ---------------------------------------------------------------------------
// SnapRegistry — The Unified Heart of SnapState v1.0.0
//
// Combines:
//   • Signal store + reactive element bindings (from SnapContainer)
//   • Controller DI / service-locator (from FusionRegistry)
// ---------------------------------------------------------------------------

typedef SnapFactory<T extends SnapController> = T Function();

class SnapRegistry {
  SnapRegistry._();

  // Singleton
  static final SnapRegistry instance = SnapRegistry._();

  // ── Observability ──────────────────────────────────────────────────────────
  static SnapObserver? observer;

  // ── Signal Store ───────────────────────────────────────────────────────────
  /// Raw value store keyed by signal name.
  final Map<String, dynamic> _store = {};

  /// Element → signals binding for auto-rebuild tracking.
  final Map<String, Set<Element>> _bindings = {};

  /// Stack of currently-building elements (for auto-tracking inside SnapCell).
  final List<Element> _trackingStack = [];

  /// Computed/async trigger callbacks keyed by the upstream signal name.
  final Map<String, Set<void Function()>> _computedTriggers = {};

  // ── Controller Store ───────────────────────────────────────────────────────
  final Map<Type, SnapController> _controllers = {};
  final Map<Type, dynamic> _factories = {};

  // ══════════════════════════════════════════════════════════════════════════
  // Signal API
  // ══════════════════════════════════════════════════════════════════════════

  T getSignal<T>(String name, T Function() factory) =>
      _store.putIfAbsent(name, factory) as T;

  void writeSignal(String name, dynamic value) => _store[name] = value;

  /// Called inside a signal getter to record which element is reading it.
  void logReadHook(String name) {
    if (_trackingStack.isNotEmpty) {
      _bindings.putIfAbsent(name, () => {}).add(_trackingStack.last);
    }
  }

  void pushElement(Element element) => _trackingStack.add(element);
  void popElement() {
    if (_trackingStack.isNotEmpty) _trackingStack.removeLast();
  }

  /// Register a computed/async trigger that re-runs when [signalName] changes.
  void addComputedTrigger(String signalName, void Function() trigger) {
    _computedTriggers.putIfAbsent(signalName, () => {}).add(trigger);
  }

  /// Remove computed trigger (e.g., when SnapAsync is garbage-collected).
  void removeComputedTrigger(String signalName, void Function() trigger) {
    _computedTriggers[signalName]?.remove(trigger);
  }

  void unregisterElement(Element element) {
    for (final binds in _bindings.values) {
      binds.remove(element);
    }
  }

  /// Dispatch a state change: notifies observer, triggers computeds, rebuilds elements.
  void dispatch(String name, dynamic oldValue, dynamic newValue) {
    observer?.onStateChange(name, oldValue, newValue);

    // Fire computed/async dependencies
    final triggers = _computedTriggers[name];
    if (triggers != null) {
      for (final fn in List.of(triggers)) {
        fn();
      }
    }

    // Rebuild bound elements
    final elements = _bindings[name];
    if (elements == null || elements.isEmpty) return;
    for (final el in List<Element>.from(elements)) {
      if (el.mounted) {
        el.markNeedsBuild();
      } else {
        elements.remove(el);
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Controller DI API
  // ══════════════════════════════════════════════════════════════════════════

  /// Register a factory for [T]. Optional — if not registered, a no-arg
  /// constructor will be attempted.
  void register<T extends SnapController>(SnapFactory<T> factory) {
    _factories[T] = factory;
  }

  /// Find (or lazily create) a controller of type [T].
  T find<T extends SnapController>() {
    if (_controllers.containsKey(T)) {
      return _controllers[T] as T;
    }

    final factory = _factories[T];
    final T controller;

    if (factory != null) {
      controller = (factory as SnapFactory<T>)();
    } else {
      throw FlutterError(
        'SnapRegistry: Controller of type $T is not registered.\n'
        'Ensure you register its factory using SnapRegistry.instance.register(() => $T()) '
        'or inject it via SnapScope before calling snapOf<$T>().',
      );
    }

    _controllers[T] = controller;
    controller.onInit();
    snapLogger.log('✅ Controller created: $T');
    observer?.onControllerCreated(T);

    return controller;
  }

  /// Manually inject a controller instance into the registry.
  void inject<T extends SnapController>(T controller) {
    final runtimeType = controller.runtimeType;
    _controllers[runtimeType] = controller;
    controller.onInit();
    snapLogger.log('✅ Controller injected: $runtimeType');
    observer?.onControllerCreated(runtimeType);
  }

  /// Check if a controller is already registered without creating it.
  bool isRegistered<T extends SnapController>() =>
      _controllers.containsKey(T);

  /// Check if a dynamic Type is registered in the controller store.
  bool containsType(Type type) => _controllers.containsKey(type);

  /// Dispose specific controllers by type.
  void dispose<T extends SnapController>() {
    final controller = _controllers.remove(T);
    if (controller != null) {
      controller.onClose();
      controller.dispose();
      snapLogger.log('🗑️  Controller disposed: $T');
      observer?.onControllerDisposed(T);
    }
  }

  /// Dispose a set of controllers (used by SnapScope on unmount).
  void disposeAll(Set<Type> types) {
    for (final type in types) {
      final controller = _controllers.remove(type);
      if (controller != null) {
        controller.onClose();
        controller.dispose();
        snapLogger.log('🗑️  Controller disposed: $type');
        observer?.onControllerDisposed(type);
      }
    }
  }
}

// ── Top-level convenience shorthand ─────────────────────────────────────────

/// Retrieve (or lazily create) a [SnapController] of type [T].
///
/// Equivalent to `SnapRegistry.instance.find<T>()`.
///
/// ```dart
/// final counter = snapOf<CounterController>();
/// ```
T snapOf<T extends SnapController>() => SnapRegistry.instance.find<T>();
