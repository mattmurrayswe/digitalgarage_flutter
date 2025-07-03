import 'package:flutter/material.dart';
import '../widgets/logo_app_bar.dart';

class HomeTab extends StatelessWidget {
  final List<String> scannedCodes;
  final VoidCallback onClearLast;

  const HomeTab({
    super.key,
    required this.scannedCodes,
    required this.onClearLast,
  });

  @override
  Widget build(BuildContext context) {
    final lastCode = scannedCodes.isNotEmpty ? scannedCodes.last : null;

    return Scaffold(
      appBar: const LogoAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          // gradient: LinearGradient(
          //   begin: Alignment.centerLeft,
          //   end: Alignment.centerRight,
          //   colors: [Color(0xFF070707), Colors.black],
          // ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(left: 35, right: 35),
                child: Container(
                  padding: const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [
                        Color.fromARGB(255, 255, 209, 71),
                        const Color.fromARGB(255, 222, 6, 193),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.festival_outlined,
                        size: 30,
                        color: Colors.white,
                      ),
                      Text(
                        'Eventos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Righteous',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
