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

  void _showExpandedCard(BuildContext context, Map<String, String> car) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          children: [
            Stack(
              children: [
                Container(
                  width: 340,
                  // Remove fixed padding here, let the card control its own padding
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: _CarCard(
                    car: car,
                    getNeonShadow: getNeonShadow,
                    expanded: true,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
                    GestureDetector(
                      onTap: () => _showExpandedCard(context, row[0]),
                      child: Container(
                        width: 160,
                        child: _CarCard(car: row[0], getNeonShadow: getNeonShadow),
                      ),
                    ),
                    const SizedBox(width: 22),
                    if (row.length > 1)
                      GestureDetector(
                        onTap: () => _showExpandedCard(context, row[1]),
                        child: Container(
                          width: 160,
                          child: _CarCard(car: row[1], getNeonShadow: getNeonShadow),
                        ),
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
  final bool expanded;

  const _CarCard({
    required this.car,
    required this.getNeonShadow,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final rarity = car['rarity'];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(expanded ? 6 : 12),
        boxShadow: getNeonShadow(rarity),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(expanded ? 8 : 12)),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: expanded ? 24.0 : 10.0,
            vertical: expanded ? 20.0 : 8.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // <-- Only as tall as content
            children: [
              if (car['instagram'] != null)
                Row(
                  children: [
                    Text(car['instagram']!, style: TextStyle(color: Colors.white, fontSize: expanded ? 18 : 12)),
                  ],
                ),
              const SizedBox(height: 4),
              Center(
                child: car['image'] != null
                    ? Image.network(
                        car['image']!,
                        width: expanded ? 320 : 200,
                        height: expanded ? 340 : 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/car.png',
                            width: expanded ? 320 : 200,
                            height: expanded ? 340 : 160,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        'assets/car.png',
                        width: expanded ? 320 : 200,
                        height: expanded ? 340 : 160,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 8),
              Text(car['model']!, style: TextStyle(fontSize: expanded ? 22 : 13, fontWeight: expanded ? FontWeight.bold : FontWeight.normal)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(car['brand']!, style: TextStyle(fontSize: expanded ? 16 : 11)),
                  Text(
                    car['year']!,
                    style: TextStyle(color: Colors.grey, fontSize: expanded ? 16 : 11),
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
