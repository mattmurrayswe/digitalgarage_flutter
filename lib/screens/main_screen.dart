import 'package:flutter/material.dart';
import '../tabs/home_tab.dart';
import '../tabs/qr_scanner_tab.dart';
import '../tabs/ticket_list_tab.dart';
import '../tabs/scanned_tickets_tab.dart'; // <-- Import the new tab
import '../tabs/sold_tickets_tab.dart'; // <-- Import the new tab
import '../tabs/car_expo_tab.dart'; // <-- Import the new tab

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<QRScannerTabState> qrScannerKey = GlobalKey<QRScannerTabState>();

  int _selectedIndex = 0;
  List<String> scannedCodes = [];

  late final List<Widget> _tabs;

  void _handleQRScan(String code) {
    if (!scannedCodes.contains(code)) {
      setState(() => scannedCodes.add(code));
    }
  }

  void _clearLastScan() {
    if (scannedCodes.isNotEmpty) {
      setState(() => scannedCodes.removeLast());
    }
  }

  Future<void> setSelectedIndex(int newIndex) async {
    if (_selectedIndex == newIndex) return;

    if (_selectedIndex == 1) {
      await qrScannerKey.currentState?.pauseCamera();
    }

    setState(() => _selectedIndex = newIndex);

    if (newIndex == 1) {
      await qrScannerKey.currentState?.resumeCamera();
    }
  }

  @override
  void initState() {
    super.initState();
    _tabs = [
      HomeTab(
        scannedCodes: scannedCodes,
        onClearLast: _clearLastScan,
      ),
      QRScannerTab(
        key: qrScannerKey,
        onScan: _handleQRScan,
      ),
      Navigator(
        key: GlobalKey<NavigatorState>(), // Unique key for the nested navigator
        onGenerateRoute: (settings) {
          Widget page = TicketListTab(scannedCodes: scannedCodes);
          if (settings.name == '/scanned') {
            page = const ScannedTicketsTab();
          }
          if (settings.name == '/sold') {
            page = const SoldTicketsTab();
          }
          return MaterialPageRoute(builder: (_) => page, settings: settings);
        },
      ),
      const CarExpoTab(), // <-- Add this line
    ];
  }

  Widget _buildNavItem(int index, IconData icon, IconData selectedIcon, double iconSize) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => setSelectedIndex(index),
      borderRadius: BorderRadius.circular(100),
      splashColor: Colors.deepPurple.withOpacity(0.2),
      child: SizedBox(
        width: 80, // narrower than Expanded
        height: 60,
        child: Center(
          child: Icon(
            isSelected ? selectedIcon : icon,
            color: isSelected ? Colors.deepPurple : Colors.white,
            size: iconSize,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        height: 96,
        decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 32),
              const SizedBox(width: 13),
              _buildNavItem(1, Icons.qr_code_scanner_outlined, Icons.qr_code_scanner, 30),
              const SizedBox(width: 13),
              _buildNavItem(2, Icons.confirmation_num_outlined, Icons.confirmation_num_outlined, 32),
              const SizedBox(width: 13),
              _buildNavItem(3, Icons.style_outlined, Icons.style_outlined, 32), // Car Expo tab
            ],
          ),
        ),
      ),
    );
  }
}
