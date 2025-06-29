import 'package:flutter/material.dart';

class CarExpoTab extends StatelessWidget {
  const CarExpoTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace this with your real-time car list logic
    return Scaffold(
      appBar: AppBar(title: const Text('Digital Car Exposition')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car_filled, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 16),
            const Text(
              'All cars from the expo will appear here in real time!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            // TODO: Add your real-time car list widget here
          ],
        ),
      ),
    );
  }
}