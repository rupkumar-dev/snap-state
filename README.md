# SnapState ⚡

The Autonomous Reactive Engine for Flutter. A production-ready, ultra-lightweight state management ecosystem designed to eliminate boilerplate, maximize performance with pinpoint micro-rebuilds, and bypass the limitations of BLoC and Riverpod.

[![pub package](https://img.shields.io/pub/v/snap_state.svg)](https://pub.dev/packages/snap_state)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## ⚔️ Why SnapState Beats BLoC & Riverpod

Large enterprise applications suffer from **Boilerplate Hell** (BLoC) and **Dependency Drilling/Ref Tracking** (Riverpod). `SnapState` introduces **Autonomous Proxy Binding**, meaning your UI dynamically registers state nodes at runtime with zero manual configuration.

| Feature | BLoC (`BlocBuilder`) | Riverpod (`Consumer`) | SnapState (`SnapCell`) |
| :--- | :--- | :--- | :--- |
| **Engine Core** | Streams (`StreamController`) | Container Framework Elements | Atomic Notifiers + Dynamic Proxies |
| **Setup Boilerplate** | 🔴 High (Events, States, Blocs) | 🟡 Medium (Providers, WidgetRef) | 🟢 **Ultra Low** (Just declare & use) |
| **Type Dependencies** | Explicit typing required | Explicit Provider Names needed | 🟢 **Automatic Lookup** (Auto-detects on read) |
| **Context/Ref Lock** | Locked to `BuildContext` | Locked to `WidgetRef` | 🟢 **0% Dependency** (Mutate anywhere) |
| **Rebuild Scope** | Full Block Level Rebuild | Provider Scope Rebuild | 🟢 **Pinpoint Element Rebuild** |

---

## ⚡ The Holy Grail: Automatic Under-the-Hood Linkage

Unlike other solutions where you must explicitly pass types or providers to the builder widget, `SnapCell` is a blind interceptor. It activates an invisible recording pipeline during its build phase. Any `Snap` or `AsyncSnap` read inside its hierarchy automatically binds to it. **One cell can listen to 50 different controllers simultaneously without nested wrappers!**

---

## 🚀 Quick Start

### 1. Declare Global or Controller-scoped States
```dart
import 'package:snap_state/snap_state.dart';

// Synchronous state node
final counter = Snap<int>(name: 'user_counter', initialValue: 0);

// Asynchronous API network node
final dashboardApi = AsyncSnap<String>(
  name: 'dashboard_api',
  executionGraph: () async {
    await Future.delayed(const Duration(seconds: 2));
    return "Enterprise Core Engine Data Synced!";
  },
);