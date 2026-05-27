import 'dart:async';
import 'package:flutter/material.dart';

abstract class SnapObserver {
  void onStateChange(String name, dynamic oldValue, dynamic newValue);
  void onError(String name, Object error, StackTrace stackTrace);
}

class SnapContainer {
  static SnapObserver? observer;
  static final Map<String, dynamic> _registry = {};
  static final Map<String, Set<Element>> _bindingTree = {};
  static Element? _activeCompileElement;

  static T get<T>(String name, T Function() factory) {
    return _registry.putIfAbsent(name, factory) as T;
  }

  static void logReadHook(String name) {
    if (_activeCompileElement != null) {
      final listeners = _bindingTree.putIfAbsent(name, () => {});
      listeners.add(_activeCompileElement!);
    }
  }

  static void dispatchUpdate(String name, dynamic old, dynamic latest) {
    observer?.onStateChange(name, old, latest);
    final elements = _bindingTree[name];
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

/// ⚡ THE REACTIVE ATOMIC SIGNAL (For Synchronous States)
class Snap<T> {
  final String name;
  final T _initialValue;

  Snap({required this.name, required this._initialValue}) {
    SnapContainer.get(name, () => _initialValue);
  }

  T get value {
    SnapContainer.logReadHook(name);
    return SnapContainer._registry[name] as T;
  }

  set value(T newValue) {
    final old = SnapContainer._registry[name];
    if (old == newValue) return;
    SnapContainer._registry[name] = newValue;
    SnapContainer.dispatchUpdate(name, old, newValue);
  }
}

/// 🌊 THE AUTONOMOUS ASYNC STREAM PIPELINE (Type Safe)
sealed class AsyncSnapState<T> { const AsyncSnapState(); }
class SnapLoading<T> extends AsyncSnapState<T> { const SnapLoading(); }
class SnapError<T> extends AsyncSnapState<T> {
  final Object error;
  const SnapError(this.error);
}
class SnapData<T> extends AsyncSnapState<T> {
  final T data;
  const SnapData(this.data);
}

class AsyncSnap<T> {
  final String name;
  final Future<T> Function() _executionGraph;

  AsyncSnap({required this.name, required this._executionGraph}) {
    // 🎯 FIXED: Explicitly typed SnapLoading<T>() instead of raw generic runtime object
    SnapContainer.get<AsyncSnapState<T>>(name, () => SnapLoading<T>());
    scheduleMicrotask(() => execute());
  }

  AsyncSnapState<T> get state {
    SnapContainer.logReadHook(name);
    return SnapContainer._registry[name] as AsyncSnapState<T>;
  }

  Future<void> execute() async {
    final old = SnapContainer._registry[name];
    try {
      SnapContainer._registry[name] = SnapLoading<T>();
      SnapContainer.dispatchUpdate(name, old, SnapLoading<T>());
      
      final result = await _executionGraph();
      
      final currentOld = SnapContainer._registry[name];
      SnapContainer._registry[name] = SnapData<T>(result);
      SnapContainer.dispatchUpdate(name, currentOld, SnapData<T>(result));
    } catch (e, stack) {
      final currentOld = SnapContainer._registry[name];
      SnapContainer._registry[name] = SnapError<T>(e);
      SnapContainer.dispatchUpdate(name, currentOld, SnapError<T>(e));
      SnapContainer.observer?.onError(name, e, stack);
    }
  }
}

/// 🎯 INTERCEPTOR SCOPE
class SnapCell extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  const SnapCell({required this.builder, super.key});

  @override
  State<SnapCell> createState() => _SnapCellState();
}

class _SnapCellState extends State<SnapCell> {
  @override
  Widget build(BuildContext context) {
    SnapContainer._activeCompileElement = context as Element;
    final renderedWidget = widget.builder(context);
    SnapContainer._activeCompileElement = null;
    return renderedWidget;
  }
}