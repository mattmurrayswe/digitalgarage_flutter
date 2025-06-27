import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:hive/hive.dart';
import '../models/ticket.dart';

class QRScannerTab extends StatefulWidget {
  final void Function(String code) onScan;

  const QRScannerTab({super.key, required this.onScan});

  @override
  State<QRScannerTab> createState() => _QRScannerTabState();
}

class _QRScannerTabState extends State<QRScannerTab> {
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
    return Stack(
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
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    // Pause immediately to avoid premature scan rect setup
    controller.pauseCamera();

    // Delay to allow camera to initialize before scanning
    Future.delayed(const Duration(milliseconds: 500), () {
      controller.resumeCamera();

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
          final scannedId = parsed['order_id'].toString();

          final box = Hive.box<Ticket>('tickets');
          final match = box.values.any((ticket) => ticket.orderId == scannedId);

          if (!mounted) return;

          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(match ? '✅ Ticket Válido' : '❌ Ticket Inválido'),
              content: Icon(
                match ? Icons.check_circle : Icons.cancel,
                color: match ? Colors.green : Colors.red,
                size: 80,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );

          if (match) widget.onScan(code);

          setState(() {
            _hasScanned = false;
            _isNavigating = false;
          });
        } catch (_) {
          setState(() {
            _hasScanned = false;
            _isNavigating = false;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
