
import 'package:flutter/widgets.dart';
import 'package:snap_state/src/core/container.dart';

/// 🎯 SNAP CELL INTERCEPTOR
final class SnapCell extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  const SnapCell({required this.builder, super.key});

  @override
  State<SnapCell> createState() => _SnapCellState();
}

final class _SnapCellState extends State<SnapCell> {
  @override
  Widget build(BuildContext context) {
    SnapContainer.pushActiveElement(context as Element);
    final renderedLayout = widget.builder(context);
    SnapContainer.popActiveElement();
    return renderedLayout;
  }

  @override
  void dispose() {
    SnapContainer.unregisterElement(context as Element);
    super.dispose();
  }
}