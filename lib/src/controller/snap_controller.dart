import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// SnapController — The Unified Business Logic Base Class
//
// Merges:
//   • FusionController  (onInit / onReady / onDispose lifecycle)
//   • FusionState       (ChangeNotifier + update())
//
// Usage:
//   class CounterController extends SnapController {
//     int count = 0;
//
//     @override
//     void onInit() => count = 0;  // runs on first find()
//
//     void increment() {
//       count++;
//       update(); // notifies all SnapBuilder widgets listening
//     }
//   }
// ---------------------------------------------------------------------------

abstract class SnapController extends ChangeNotifier {
  // ── Lifecycle Hooks ────────────────────────────────────────────────────────

  /// Called immediately after the controller is created by [SnapRegistry].
  /// Use for initialization logic (e.g., fetch initial data).
  void onInit() {}

  /// Called after the first frame is rendered.
  /// Use for animations, navigation, or post-build logic.
  void onReady() {}

  /// Called just before the controller is disposed.
  /// Use for cleanup (cancel subscriptions, close streams, etc.).
  void onClose() {}

  // ── State Update ──────────────────────────────────────────────────────────

  /// Notifies all [SnapBuilder] widgets listening to this controller to rebuild.
  ///
  /// Call this after mutating any property:
  /// ```dart
  /// void increment() { count++; update(); }
  /// ```
  void update() => notifyListeners();
}
