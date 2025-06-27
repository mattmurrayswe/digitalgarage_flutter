import 'package:flutter/material.dart';
import '../tabs/home_tab.dart';
import '../tabs/qr_scanner_tab.dart';
import '../tabs/ticket_list_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<QRScannerTabState> qrScannerKey = GlobalKey<QRScannerTabState>();

  int _selectedIndex = 0;
  List<String> scannedCodes = [];

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

  Widget _getTab() {
    switch (_selectedIndex) {
      case 0:
        return HomeTab(scannedCodes: scannedCodes, onClearLast: _clearLastScan);
      case 1:
        return QRScannerTab(key: qrScannerKey, onScan: _handleQRScan);
      case 2:
        return TicketListTab(scannedCodes: scannedCodes);
      default:
        return const SizedBox();
    }
  }

  Widget _buildNavItem(int index, IconData icon, IconData selectedIcon, double iconSize) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setSelectedIndex(index),
      child: SizedBox(
        width: 60,
        child: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected ? Colors.deepPurple : Colors.white,
          size: iconSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getTab(),
      bottomNavigationBar: Container(
        height: 96,
        decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 32),
              _buildNavItem(1, Icons.qr_code_scanner_outlined, Icons.qr_code_scanner, 28),
              _buildNavItem(2, Icons.list_outlined, Icons.list, 38),
            ],
          ),
        ),
      ),
    );
  }
}
