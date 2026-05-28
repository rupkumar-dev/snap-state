import '../observability/snap_logger.dart';

// ---------------------------------------------------------------------------
// snapGuard — Asynchronous try-catch wrapper (Merged from fusionGuard)
//
// Automatically catches errors thrown in asynchronous callbacks, preventing
// application crashes and sending formatted log messages to the SnapLogger.
// ---------------------------------------------------------------------------

Future<void> snapGuard(
  Future<void> Function() callback,
) async {
  try {
    await callback();
  } catch (e, stack) {
    snapLogger.error('Unhandled async exception caught by guard: $e\n$stack');
  }
}
