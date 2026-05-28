import 'package:flutter/widgets.dart';
import '../di/snap_registry.dart';

// ---------------------------------------------------------------------------
// SnapCell — Fine-Grained Autonomous Reactive Interceptor Widget
//
// Automatically intercepts any active Snap, SnapAsync, or SnapComputed read hooks
// within its builder hierarchy, binding the underlying element for selective rebuilds.
// ---------------------------------------------------------------------------

final class SnapCell extends StatefulWidget {
  final Widget Function(BuildContext context) builder;

  const SnapCell({required this.builder, super.key});

  @override
  State<SnapCell> createState() => _SnapCellState();
}

final class _SnapCellState extends State<SnapCell> {
  @override
  Widget build(BuildContext context) {
    SnapRegistry.instance.pushElement(context as Element);
    final renderedLayout = widget.builder(context);
    SnapRegistry.instance.popElement();
    return renderedLayout;
  }

  @override
  void dispose() {
    SnapRegistry.instance.unregisterElement(context as Element);
    super.dispose();
  }
}