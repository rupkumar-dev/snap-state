import 'package:flutter/widgets.dart';
import '../controller/snap_controller.dart';
import '../di/snap_registry.dart';

// ---------------------------------------------------------------------------
// SnapBuilder<T> — Controller UI Rebuilding Widget
//
// Subscribes explicitly to a [SnapController] (resolving it lazily from DI if not provided)
// and triggers a rebuild only of its builder subtree when `update()` is called on the controller.
// Fully compatible with all Flutter versions.
// ---------------------------------------------------------------------------

class SnapBuilder<T extends SnapController> extends StatefulWidget {
  final Widget Function(BuildContext context, T controller) builder;
  /// Optional custom controller instance. If null, the controller will be resolved via DI (`snapOf<T>()`).
  final T? controller;

  const SnapBuilder({
    required this.builder,
    this.controller,
    super.key,
  });

  @override
  State<SnapBuilder<T>> createState() => _SnapBuilderState<T>();
}

class _SnapBuilderState<T extends SnapController> extends State<SnapBuilder<T>> {
  late T _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? snapOf<T>();
    _controller.addListener(_handleChange);
  }

  @override
  void didUpdateWidget(SnapBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextController = widget.controller ?? snapOf<T>();
    if (nextController != _controller) {
      _controller.removeListener(_handleChange);
      _controller = nextController;
      _controller.addListener(_handleChange);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _controller);
  }
}
