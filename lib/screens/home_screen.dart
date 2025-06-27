import 'package:flutter/material.dart';
import 'qr_scanner_screen.dart';
import 'ticket_list_screen.dart';
import '../widgets/logo_app_bar.dart';
import '../utils/qr_parser.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});
  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? scannedCode;

  void _navigateToScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (result != null) {
      print('Raw scanned QR code: $result');

      final parsed = tryParseJson(result);
      if (parsed != null) {
        print('Parsed QR data: $parsed');
      } else {
        print('Not a JSON QR code');
      }

      setState(() {
        scannedCode = result;
        if (!scannedCodes.contains(result)) {
          scannedCodes.add(result);
        }
      });
    }
  }

  List<String> scannedCodes = [];

  void _navigateToTicketList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketListScreen(
          scannedCodes: scannedCodes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            children: <Widget>[
              const Text('Welcome to digitalgarage.com.br App'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _navigateToTicketList,
                child: const Text('Ticket List'),
              ),
              ElevatedButton(
                onPressed: _navigateToScanner,
                child: const Text('Scan QR Code'),
              ),
              if (scannedCode != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Scanned: $scannedCode',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => setState(() => scannedCode = null),
                  child: const Text('Clear Scanned Code'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
