import 'package:flutter/widgets.dart';
import '../atoms/snap_async.dart';
import 'snap_cell.dart';

// ---------------------------------------------------------------------------
// SnapAsyncBuilder<T> — Typed Asynchronous UI Builder
//
// Automatically listens to a [SnapAsync] signal using an internal SnapCell.
// Evaluates the current state (AsyncLoading, AsyncError, or AsyncData) and
// executes the corresponding builder, ensuring type-safe UI renders for async logic.
// ---------------------------------------------------------------------------

class SnapAsyncBuilder<T> extends StatelessWidget {
  final SnapAsync<T> snap;
  final Widget Function(BuildContext context) loading;
  final Widget Function(BuildContext context, Object error) error;
  final Widget Function(BuildContext context, T data) data;

  const SnapAsyncBuilder({
    required this.snap,
    required this.loading,
    required this.error,
    required this.data,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SnapCell(
      builder: (context) {
        final val = snap.value;
        if (val is AsyncLoading<T>) {
          return loading(context);
        } else if (val is AsyncError<T>) {
          return error(context, val.error);
        } else if (val is AsyncData<T>) {
          return data(context, val.data);
        }
        // Fallback for analyzer
        return loading(context);
      },
    );
  }
}
