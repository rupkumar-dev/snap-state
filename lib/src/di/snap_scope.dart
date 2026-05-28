import 'package:flutter/widgets.dart';
import 'snap_registry.dart';
import '../controller/snap_controller.dart';

// ---------------------------------------------------------------------------
// SnapScope — The Lifecycle & Dependency Scoping Widget
//
// Wraps a widget tree and registers/injects instances of [SnapController]s.
// Automatically triggers `onReady()` on the controllers after the first frame is rendered.
// Disposes only the scoped controllers when the widget is unmounted/disposed.
// ---------------------------------------------------------------------------

class SnapScope extends StatefulWidget {
  final Widget child;
  /// Factories to instantiate controllers scoped to this widget tree.
  final List<SnapController Function()> providers;

  const SnapScope({
    super.key,
    required this.child,
    this.providers = const [],
  });

  @override
  State<SnapScope> createState() => _SnapScopeState();
}

class _SnapScopeState extends State<SnapScope> {
  final Set<Type> _scopedTypes = {};

  @override
  void initState() {
    super.initState();
    for (final provider in widget.providers) {
      final controller = provider();
      final type = controller.runtimeType;
      _scopedTypes.add(type);

      // Inject the controller instance into SnapRegistry
      SnapRegistry.instance.inject(controller);

      // Schedule onReady post-frame hook
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && SnapRegistry.instance.containsType(type)) {
          controller.onReady();
        }
      });
    }
  }

  @override
  void dispose() {
    SnapRegistry.instance.disposeAll(_scopedTypes);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
