

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:snap_state/snap_state.dart';

class HomeController {
  final points = Snap<int>(name: 'user_points', initialValue: 0);

  late final dashboardData = AsyncSnap<String>(
    name: 'dashboard_api',
    executionGraph: () async {
      await Future.delayed(const Duration(seconds: 2));
      return "SnapState Enterprise Matrix Running Perfectly!";
    },
  );

  void incrementPoints() {
    points.value++;
  }
}

final homeController = HomeController();

void main() => runApp(const MaterialApp(home: EnterpriseScreen()));

class EnterpriseScreen extends StatelessWidget {
  const EnterpriseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    log("❌ SYSTEM CRITICAL: Full Scaffold Shell Built!");

    return Scaffold(
      appBar: AppBar(title: const Text('SnapState Pure Core Engine')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SnapCell(
              builder: (context) {
                log("🔵 SUCCESS: Sirf Text widget rebuild hua!");
                return Text(
                  'Points: ${homeController.points.value}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: homeController.incrementPoints,
              child: const Text('Increment State'),
            ),

            const SizedBox(height: 40),
            const Divider(indent: 40, endIndent: 40),
            const SizedBox(height: 20),

            // 🎯 FIXED TYPE MATCHING: Clean pattern compile structure
            SnapCell(
              builder: (context) {
                log("🟢 SUCCESS: Sirf API View Container rebuild hua!");
                final currentState = homeController.dashboardData.state;

                return switch (currentState) {
                  SnapLoading<String>() => const CircularProgressIndicator(),
                  SnapError<String>(error: final err) => Text('Error: $err'),
                  SnapData<String>(data: final message) => Text(
                    message,
                    style: const TextStyle(fontSize: 18),
                  ),
                };
              },
            ),
          ],
        ),
      ),
    );
  }
}
