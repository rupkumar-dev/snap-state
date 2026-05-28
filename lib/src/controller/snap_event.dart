import 'snap_controller.dart';

// ---------------------------------------------------------------------------
// SnapEvent<T> — Merged FusionEvent, now reactive out-of-the-box
//
// Usage:
//   class WeatherFetchedEvent extends SnapEvent<String> {
//     @override
//     String initialState() => 'Mumbai';
//
//     void fetch(String newCity) {
//       emit(newCity); // Auto-notifies any SnapBuilder/ListenableBuilder
//     }
//   }
// ---------------------------------------------------------------------------

abstract class SnapEvent<T> extends SnapController {
  late T _state;

  T get state => _state;

  SnapEvent() {
    _state = initialState();
  }

  /// Define the starting state value.
  T initialState();

  /// Updates the internal state value and notifies all listening UI elements.
  void emit(T value) {
    _state = value;
    onEmit(value);
    update(); // Notifies ChangeNotifier/UI listeners
  }

  /// Hook triggered whenever [emit] is called. Use for logging or side-effects.
  void onEmit(T value) {}
}
