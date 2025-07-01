import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CarExpoTab extends StatelessWidget {
  const CarExpoTab({super.key});

  final List<Map<String, String>> cars = const [
    {
      'brand': 'Toyota',
      'model': 'Corolla',
      'year': '2022',
      'image': 'https://example.com/toyota.jpg',
      'instagram': '@toyota_official',
      'rarity': 'uncommon',
    },
    {
      'brand': 'Honda',
      'model': 'Civic',
      'year': '2021',
      'image': 'https://example.com/honda.jpg',
      'instagram': '@honda_cars',
      'rarity': 'rare',
    },
    {
      'brand': 'Ford',
      'model': 'Mustang',
      'year': '2023',
      'image': 'https://example.com/ford.jpg',
      'instagram': '@fordperformance',
      'rarity': 'epic',
    },
    {
      'brand': 'Lamborghini',
      'model': 'Aventador',
      'year': '2024',
      'image': 'https://example.com/lamborghini.jpg',
      'instagram': '@lamborghini',
      'rarity': 'legendary',
    },
    {
      'brand': 'Ford',
      'model': 'Mustang',
      'year': '2023',
      'image': 'https://example.com/ford.jpg',
      'instagram': '@fordperformance',
      'rarity': 'epic',
    },
    {
      'brand': 'Lamborghini',
      'model': 'Aventador',
      'year': '2024',
      'image': 'https://example.com/lamborghini.jpg',
      'instagram': '@lamborghini',
      'rarity': 'legendary',
    },
    // ...more cars...
  ];

  List<BoxShadow> getNeonShadow(String? rarity) {
    switch (rarity) {
      case 'rare':
        return [
          BoxShadow(
            color: Colors.blue,
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ];
      case 'epic':
        return [
          BoxShadow(
            color: Colors.purple,
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ];
      case 'legendary':
        return [
          BoxShadow(
            color: Colors.orange,
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ];
      case 'uncommon':
      default:
        return [
          BoxShadow(
            color: Colors.white,
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // Create pairs of cars for each row (2 per row)
    final List<List<Map<String, String>>> carRows = [];
    for (int i = 0; i < cars.length; i += 2) {
      if (i + 1 < cars.length) {
        carRows.add([cars[i], cars[i + 1]]);
      } else {
        carRows.add([cars[i]]);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Digital Car Exposition',
        ),
        // Removed actions with orientation button
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(isLandscape ? Icons.screen_lock_rotation : Icons.screen_rotation_alt),
                tooltip: isLandscape ? 'Rotate to vertical' : 'Rotate to horizontal',
                onPressed: () {
                  if (isLandscape) {
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitUp,
                      DeviceOrientation.portraitDown,
                    ]);
                  } else {
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.landscapeLeft,
                      DeviceOrientation.landscapeRight,
                    ]);
                  }
                },
              ),
              const SizedBox(width: 12),
            ],
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16),
              itemCount: carRows.length,
              itemBuilder: (context, rowIndex) {
                final row = carRows[rowIndex];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 160,
                      child: _CarCard(car: row[0], getNeonShadow: getNeonShadow),
                    ),
                    const SizedBox(width: 22),
                    if (row.length > 1)
                      Container(
                        width: 160,
                        child: _CarCard(car: row[1], getNeonShadow: getNeonShadow),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CarCard extends StatelessWidget {
  final Map<String, String> car;
  final List<BoxShadow> Function(String?) getNeonShadow;

  const _CarCard({required this.car, required this.getNeonShadow});

  @override
  Widget build(BuildContext context) {
    final rarity = car['rarity'];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: getNeonShadow(rarity),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (car['instagram'] != null)
                Row(
                  children: [
                    Text(car['instagram']!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              const SizedBox(height: 4),
              Center(
                child: car['image'] != null
                    ? Image.network(
                        car['image']!,
                        width: 200,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/car.png', width: 200, height: 160, fit: BoxFit.cover);
                        },
                      )
                    : Image.asset('assets/car.png', width: 200, height: 160, fit: BoxFit.cover),
              ),
              const SizedBox(height: 8),
              Text(car['model']!, style: const TextStyle(fontSize: 13)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(car['brand']!, style: const TextStyle(fontSize: 11)),
                  Text(
                    car['year']!,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
