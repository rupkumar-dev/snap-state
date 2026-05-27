
import 'package:flutter/widgets.dart';
import 'observer.dart';

final class SnapContainer {
  static SnapObserver? observer;
  static final Map<String, dynamic> registry = {};
  static final Map<String, Set<Element>> _bindings = {};
  static final List<Element> _trackingStack = [];
  static final Map<String, Set<void Function()>> _automatedTriggers = {};

  static void pushActiveElement(Element element) => _trackingStack.add(element);
  static void popActiveElement() => _trackingStack.isNotEmpty ? _trackingStack.removeLast() : null;

  static T get<T>(String name, T Function() factory) {
    return registry.putIfAbsent(name, factory) as T;
  }

  static void logReadHook(String name) {
    if (_trackingStack.isNotEmpty) {
      final activeElement = _trackingStack.last;
      _bindings.putIfAbsent(name, () => {}).add(activeElement);
    }
  }

  static void registerDependency(String signalName, void Function() triggerCallback) {
    _automatedTriggers.putIfAbsent(signalName, () => {}).add(triggerCallback);
  }

  static void unregisterElement(Element element) {
    for (final key in _bindings.keys) {
      _bindings[key]?.remove(element);
    }
  }

  static void dispatchUpdate(String name, dynamic old, dynamic latest) {
    observer?.onStateChange(name, old, latest);
    
    final triggers = _automatedTriggers[name];
    if (triggers != null) {
      for (final trigger in triggers) {
        trigger();
      }
    }

    final elements = _bindings[name];
    if (elements == null) return;
    for (final element in List<Element>.from(elements)) {
      if (element.mounted) {
        element.markNeedsBuild();
      } else {
        elements.remove(element);
      }
    }
  }
}