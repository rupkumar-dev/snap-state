import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// SnapLogger — Merged FusionLogger, used internally by the SnapState engine
// ---------------------------------------------------------------------------

abstract class SnapLogger {
  void log(String message);
  void warn(String message);
  void error(String message);
}

/// Default logger: prints to the debug console only in debug mode.
class SnapDebugLogger extends SnapLogger {
  @override
  void log(String message) {
    if (kDebugMode) debugPrint('[SnapState] $message');
  }

  @override
  void warn(String message) {
    if (kDebugMode) debugPrint('[SnapState ⚠️] $message');
  }

  @override
  void error(String message) {
    if (kDebugMode) debugPrint('[SnapState ❌] $message');
  }
}

/// Global logger instance. Replace with a custom logger if needed:
/// ```dart
/// snapLogger = MyProductionLogger();
/// ```
// ignore: prefer_final_fields
SnapLogger snapLogger = SnapDebugLogger();
