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
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF070707), Colors.black],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Welcome to digitalgarage.com.br App'),
              const SizedBox(height: 20),
              if (lastCode != null) ...[
                Text(
                  'Last scanned: $lastCode',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: onClearLast,
                  child: const Text('Clear Last Scanned'),
                ),
              ] else
                const Text('No QR code scanned yet'),
            ],
          ),
        ),
      ),
    );
  }
}
