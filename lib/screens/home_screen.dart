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
  int _selectedIndex = 0;
  List<String> scannedCodes = [];
  String? scannedCode;

  void _onItemTapped(int index) async {
    if (index == 0) {
      // Home - do nothing or reset
      setState(() => _selectedIndex = index);
    } else if (index == 1) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const QRScannerScreen()),
      );

      if (result != null) {
        final parsed = tryParseJson(result);
        setState(() {
          scannedCode = result;
          if (!scannedCodes.contains(result)) {
            scannedCodes.add(result);
          }
        });
      }
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TicketListScreen(scannedCodes: scannedCodes),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LogoAppBar(),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF070707), Colors.black],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to digitalgarage.com.br App',
              style: TextStyle(color: Colors.white),
            ),
            if (scannedCode != null) ...[
              const SizedBox(height: 20),
              Text(
                'Scanned: $scannedCode',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tickets',
          ),
        ],
      ),
    );
  }
}
