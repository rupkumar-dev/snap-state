# Changelog

All notable changes to the `snap_state` ecosystem will be documented in this file.

---
## 1.0.4

- Update pubs
- Add package logo
-remove linux,windows,mac,ios example

## 1.0.1

- Update README
- Add package logo
-improve  license: MIT
- Improve documentation


## [1.0.0] - 2026-05-28

### 🚀 Merged Ecosystem Release
* **Unified State Management Architecture:** Merged `SnapState` and `FusionState` into a single, high-performance, boilerplate-free state management library.
* **Signals & Derived States:**
  * Added public `.value` typed getter to `Snap<T>` signals.
  * Added `SnapComputed<T>` for derived synchronous computation nodes listening to multiple dependencies.
  * Renamed `SnapComputedAsync` to `SnapAsync` and upgraded it to support listening to multiple dependencies concurrently.
* **Controllers & Events:**
  * Merged `FusionController` and `FusionState` into `SnapController` (extends `ChangeNotifier`, has `onInit`, `onReady`, `onClose` lifecycles).
  * Merged `FusionEvent` into `SnapEvent<T>` (now calls `update()` to notify UI upon `emit`).
* **Dependency Injection (DI) & Scoping:**
  * Combined all registry code into `SnapRegistry` (with support for manual dependency injection and type lookups).
  * Created `SnapScope` widget to replace the bugged global `FusionScope`, ensuring clean lifecycle scope tracking and localized cleanup of registered controller instances.
* **UI Widgets:**
  * Created explicit `SnapBuilder<T>` widget to listen and rebuild dynamically on controller notifications.
  * Created `SnapAsyncBuilder<T>` widget to cleanly handle async loading/data/error states.
* **Observability & Guard Utilities:**
  * Added observer logging for controller creation and disposal lifecycles.
  * Merged `fusionGuard` into `snapGuard`.
  * Added `SnapLogger` with default console debug logger.

---

## [0.1.0] - 2026-05-27

### 🚀 Added (The Pure Automation Era)
* **`SnapComputedAsync` Engine:** Introduced an automated asynchronous state tracker that listens to upstream signals. Manual `.execute()` or refresh triggers are now entirely deprecated.
* **Synchronous Chain-Reactions:** Modifying an isolated parent signal (`Snap`) now instantly propagates through dependent async nodes, automating network refetches seamlessly.

### 🛠️ Fixed & Optimized
* **Eliminated Boilerplate Operators:** Removed the requirement for `.value` and callable brackets `()` across all synchronous signal objects.
* **Implicit Type-String Interceptors:** Overrode native `toString()` and comparison operators (`==`) to allow automated UI element tracking via natural string interpolation and flat property lookups.
* **Thread-Safe Scope Stacking:** Fixed dependency tracking leaks caused by asynchronous loops inside nested structural zones by introducing an element evaluation stack layout.

---

## [0.0.1] - 2026-05-27

### 🎉 Initial Release
* **Autonomous Proxy Binding:** First version of `SnapCell` allowing zero-configuration UI mapping using static RAM registries.
* **Global Observability Middleware:** Added `SnapObserver` hooks for centralized enterprise system tracking and logging.
* **Pinpoint Rebuild Scope:** Implemented targeted dynamic element tracking to avoid tree-wide screen re-renders.