import 'package:flutter/material.dart';
import 'package:snap_state/snap_state.dart';

// ==========================================================================
// 🏢 CONTROLLER LAYER (Pure Declarative Syntax)
// ==========================================================================
class WeatherController {
  final city = Snap<String>('current_city', 'Mumbai');

  late final weatherApi = SnapComputedAsync('weather_service', city, () async {
    // 🎯 NO BRACKETS! Just string interpolate or use it directly as '$city'
    final activeCity = '$city'; 
    await Future.delayed(const Duration(seconds: 1)); 
    return "Weather in $activeCity: 32°C - Windy";
  });

  void updateCity(String newCity) {
    city.set(newCity); // Pure Mutation
  }
}

final weatherController = WeatherController();

// ==========================================================================
// 🎨 UI PRESENTATION LAYER
// ==========================================================================
void main() => runApp(const MaterialApp(home: PurePropertyDashboard()));

class PurePropertyDashboard extends StatelessWidget {
  const PurePropertyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SnapState Pure Properties')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            // 1. Sync Text: Directly referencing the object in interpolation!
            SnapCell(
              builder: (context) => Text(
                'City: ${weatherController.city}', // <--- 🎯 EXACTLY AS YOU WANTED! No value, no ()
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
            
            const SizedBox(height: 20),

            // 2. Async Block: Clean state evaluation matching types
            SnapCell(
              builder: (context) {
                return switch (weatherController.weatherApi.state) { // <--- 🎯 Clean state property
                  SnapLoading<String>() => const CircularProgressIndicator(),
                  SnapError<String>(error: final err) => Text('Error: $err'),
                  SnapData<String>(data: final climate) => Text(
                      climate,
                      style: const TextStyle(fontSize: 20, color: Colors.deepOrange, fontWeight: FontWeight.bold),
                    ),
                };
              },
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () => weatherController.updateCity('Delhi'),
              child: const Text('Switch to Delhi'),
            ),
          ],
        ),
      ),
    );
  }
}