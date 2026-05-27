# SnapState ⚡

The Autonomous Reactive Engine for Flutter. A production-ready, ultra-lightweight state management ecosystem designed to eliminate boilerplate, maximize performance with pinpoint micro-rebuilds, and bypass the limitations of BLoC and Riverpod.

[![pub package](https://img.shields.io/pub/v/snap_state.svg)](https://pub.dev/packages/snap_state)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## ⚔️ Why SnapState?

Large enterprise applications suffer from **Boilerplate Hell** (BLoC) and **Dependency Drilling/Ref Tracking** (Riverpod). `SnapState` introduces **Autonomous Proxy Binding** and **Pure Object Interaction**. No `.value` tracking, no callable brackets `()`, and zero manual configurations.

| Feature | BLoC (`BlocBuilder`) | Riverpod (`Consumer`) | SnapState (`SnapCell`) |
| :--- | :--- | :--- | :--- |
| **Engine Core** | Streams (`StreamController`) | Container Framework Elements | Atomic Notifiers + Dynamic Proxies |
| **Setup Boilerplate** | 🔴 High (Events, States, Blocs) | 🟡 Medium (Providers, WidgetRef) | 🟢 **Ultra Low** (Just declare & use) |
| **Read Syntax** | `state.property` | `ref.watch(provider)` | 🟢 **Pure Variable** (`controller.city`) |
| **Context/Ref Lock** | Locked to `BuildContext` | Locked to `WidgetRef` | 🟢 **0% Dependency** (Mutate anywhere) |
| **Rebuild Scope** | Full Block Level Rebuild | Provider Scope Rebuild | 🟢 **Pinpoint Element Rebuild** |

---

## ⚡ The Holy Grail: Automatic Under-the-Hood Linkage

Unlike other solutions where you must explicitly pass types or providers to the builder widget, `SnapCell` is a blind interceptor. It activates an invisible recording pipeline during its build phase. Any `Snap` or `SnapComputedAsync` read inside its hierarchy automatically binds to it via internal interceptors. **One cell can listen to 50 different controllers simultaneously without nested wrappers!**

---

## 🚀 Quick Start

### 1. Declare Controller-scoped States & Async Pipelines

Define your state nodes natively. To handle asynchronous flows or automated network calls, use `SnapComputedAsync` by simply passing the upstream dependent signal. It builds an unbreakable reactive chain reaction automatically.

```dart
import 'package:snap_state/snap_state.dart';

class WeatherController {
  // Pure Synchronous state node
  final city = Snap<String>('current_city', 'Mumbai');

  // Automated Asynchronous network node linked to 'city'
  late final weatherApi = SnapComputedAsync('weather_service', city, () async {
    // 🎯 Pure Object Interpolation reads the active value implicitly! No `.value` or `()`
    final activeCity = '$city'; 
    await Future.delayed(const Duration(seconds: 1)); // Network Simulation
    return "Weather in $activeCity: 32°C - Sunny";
  });

  void updateCity(String newCity) {
    // Mutate state using the .set() handler
    city.set(newCity); 
  }
}

final weatherController = WeatherController();