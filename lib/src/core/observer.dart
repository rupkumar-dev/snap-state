/// Interface for auditing, logging, and crashlytics tracking in big projects.
library;

abstract interface class SnapObserver {
  void onStateChange(String name, dynamic oldValue, dynamic newValue);
  void onError(String name, Object error, StackTrace stackTrace);
}
