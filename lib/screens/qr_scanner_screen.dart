import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';
import 'package:digitalgarage_futter/models/ticket.dart';
import 'package:hive/hive.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  bool _hasScanned = false;
  bool _isNavigating = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.blueAccent,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 250,
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ),
        ],
      ),
    );
  }

void _onQRViewCreated(QRViewController controller) {
  this.controller = controller;
  controller.scannedDataStream.listen((scanData) async {
    if (_hasScanned || _isNavigating) return;

    _hasScanned = true;
    _isNavigating = true;

    await Future.delayed(const Duration(milliseconds: 700));

    try {
      final code = scanData.code;

      if (code == null) {
        setState(() {
          _hasScanned = false;
          _isNavigating = false;
        });
        return;
      }

      final parsed = jsonDecode(code);
      print('Scanned QR code: $parsed');
      final scannedId = parsed['order_id'].toString(); // Adjust based on your QR structure
      print('scannedId: $scannedId');

      final box = Hive.box<Ticket>('tickets');
      final match = box.values.any((ticket) => ticket.orderId == scannedId);

      if (!mounted) return;

      if (match) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('✅ Ticket Válido'),
            content: const Icon(Icons.check_circle, color: Colors.green, size: 80),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        Navigator.of(context).pop(code); // Return code after alert
      } else {
        print('Ticket inválido: $scannedId');
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('❌ Ticket Inválido'),
            content: const Icon(Icons.cancel, color: Colors.red, size: 80),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        setState(() {
          _hasScanned = false;
          _isNavigating = false;
        });
      }
    } catch (e) {
      print('Erro ao validar QR: $e');
      setState(() {
        _hasScanned = false;
        _isNavigating = false;
      });
    }
  });
}


  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
