import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class CarExpoTab extends StatefulWidget {
  const CarExpoTab({super.key});

  @override
  State<CarExpoTab> createState() => _CarExpoTabState();
}

class _CarExpoTabState extends State<CarExpoTab> {
  late Future<List<Map<String, String>>> _futureCars;

  @override
  void initState() {
    super.initState();
    _futureCars = fetchCars();
  }

  Future<List<Map<String, String>>> fetchCars() async {
    final response = await http.get(
      Uri.parse('https://digitalgarage.com.br/api/digital-expo'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List projects = data['projects'];
      return projects.map<Map<String, String>>((json) {
        return {
          'brand': json['marca'] ?? '',
          'model': json['modelo'] ?? '',
          'year': json['ano']?.toString() ?? '',
          // Prefer webp if available, fallback to jpg
          'image':
              (json['image_project_webp'] != null &&
                  json['image_project_webp'].toString().isNotEmpty)
              ? 'https://digitalgarage.com.br/storage/webp/${json['image_project_webp']}'
              : 'https://digitalgarage.com.br/storage/${json['image_project']}',
          'instagram': json['arroba_projeto'] ?? json['nome_projeto'] ?? '',
          'rarity': json['rarity'] ?? 'uncommon',
        };
      }).toList();
    } else {
      throw Exception('Failed to load cars');
    }
  }

  List<BoxShadow> getNeonShadow(String? rarity) {
    switch (rarity) {
      case 'rare':
        return [BoxShadow(color: Colors.blue, blurRadius: 14, spreadRadius: 1)];
      case 'epic':
        return [
          BoxShadow(color: Colors.purple, blurRadius: 14, spreadRadius: 1),
        ];
      case 'legendary':
        return [
          BoxShadow(color: Colors.orange, blurRadius: 14, spreadRadius: 1),
        ];
      case 'uncommon':
      default:
        return [
          BoxShadow(color: Colors.white, blurRadius: 14, spreadRadius: 1),
        ];
    }
  }

  void _showExpandedCard(BuildContext context, Map<String, String> car) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: 340,
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
              top: -36,
              right: -8,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 32, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.only(
            left: 12.0,
            right: 12.0,
            top: 22.0,
            bottom: 22.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Digital Expo',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Righteous',
                ),
              ),
              Icon(
                Icons.storefront,
                size: 32,
              ), // Replace with any icon you want
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     IconButton(
          //       icon: Icon(
          //         isLandscape
          //             ? Icons.screen_lock_rotation
          //             : Icons.screen_rotation_alt,
          //       ),
          //       tooltip: isLandscape
          //           ? 'Rotate to vertical'
          //           : 'Rotate to horizontal',
          //       onPressed: () {
          //         if (isLandscape) {
          //           SystemChrome.setPreferredOrientations([
          //             DeviceOrientation.portraitUp,
          //             DeviceOrientation.portraitDown,
          //           ]);
          //         } else {
          //           SystemChrome.setPreferredOrientations([
          //             DeviceOrientation.landscapeLeft,
          //             DeviceOrientation.landscapeRight,
          //           ]);
          //         }
          //       },
          //     ),
          //     const SizedBox(width: 12),
          //   ],
          // ),
          Expanded(
            child: FutureBuilder<List<Map<String, String>>>(
              future: _futureCars,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No cars found.'));
                }
                final cars = snapshot.data!;
                // Create pairs of cars for each row (2 per row)
                final List<List<Map<String, String>>> carRows = [];
                for (int i = 0; i < cars.length; i += 2) {
                  if (i + 1 < cars.length) {
                    carRows.add([cars[i], cars[i + 1]]);
                  } else {
                    carRows.add([cars[i]]);
                  }
                }
                return ListView.builder(
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
                          child: SizedBox(
                            width: 169,
                            child: _CarCard(
                              car: row[0],
                              getNeonShadow: getNeonShadow,
                            ),
                          ),
                        ),
                        const SizedBox(width: 22),
                        if (row.length > 1)
                          GestureDetector(
                            onTap: () => _showExpandedCard(context, row[1]),
                            child: SizedBox(
                              width: 169,
                              child: _CarCard(
                                car: row[1],
                                getNeonShadow: getNeonShadow,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
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
        borderRadius: BorderRadius.circular(expanded ? 6 : 6),
        boxShadow: getNeonShadow(rarity),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 13, 13, 14),
            Color.fromARGB(255, 8, 8, 8),
          ],
        ),
      ),
      child: Card(
        color: Colors.transparent, // Make Card background transparent to show gradient
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(expanded ? 8 : 6),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: expanded ? 20.0 : 10.0,
            right: expanded ? 20.0 : 10.0,
            top: expanded ? 24.0 : 8.0,
            bottom: expanded ? 26.0 : 8.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (car['instagram'] != null && car['instagram']!.isNotEmpty) ...[
                Text(
                  'Instagram',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: expanded ? 12 : 8,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '@${car['instagram']}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: expanded ? 16 : 10,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 4),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(expanded ? 4 : 2),
                  child: car['image'] != null
                      ? CachedNetworkImage(
                          imageUrl: car['image']!,
                          width: expanded ? 320 : 200,
                          height: expanded ? 350 : 160,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: expanded ? 320 : 200,
                            height: expanded ? 350 : 160,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color.fromARGB(255, 13, 13, 14),
                                  Color.fromARGB(255, 8, 8, 8),
                                ],
                              ),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/car.png',
                            width: expanded ? 320 : 200,
                            height: expanded ? 350 : 160,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/car.png',
                          width: expanded ? 320 : 200,
                          height: expanded ? 340 : 160,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                car['model'] ?? '',
                style: TextStyle(
                  fontSize: expanded ? 22 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    car['brand'] ?? '',
                    style: TextStyle(
                      fontSize: expanded ? 16 : 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    car['year'] ?? '',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: expanded ? 16 : 11,
                    ),
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
