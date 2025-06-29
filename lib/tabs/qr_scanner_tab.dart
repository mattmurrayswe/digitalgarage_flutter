import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:hive/hive.dart';
import '../models/scanned_tickets.dart';
import '../models/ticket.dart';

class QRScannerTab extends StatefulWidget {
  final void Function(String code) onScan;

  const QRScannerTab({super.key, required this.onScan});

  @override
  State<QRScannerTab> createState() => QRScannerTabState();
}

class QRScannerTabState extends State<QRScannerTab> {
  final MobileScannerController cameraController = MobileScannerController();
  bool _hasScanned = false;
  bool _isNavigating = false;

  Future<void> pauseCamera() async {
    await cameraController.pause();
  }

  Future<void> resumeCamera() async {
    await cameraController.start();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _resetScan() {
    setState(() {
      _hasScanned = false;
      _isNavigating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    const navBarHeight = 96.0;

    return SizedBox(
      height: screenHeight - navBarHeight,
      child: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) async {
              if (_hasScanned || _isNavigating) return;
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;
              final Barcode barcode = barcodes.first;
              final String? code = barcode.rawValue;

              if (code == null) return;

              _hasScanned = true;
              _isNavigating = true;

              try {
                await cameraController.pause();

                final parsed = jsonDecode(code);
                final scannedId = parsed['order_id'].toString();

                final box = Hive.box<Ticket>('tickets');
                final match = box.values.any((ticket) => ticket.orderId == scannedId);

                if (match) {
                  final scannedBox = Hive.box<ScannedTickets>('scanned_tickets');
                  final ticket = Ticket.fromJson(parsed);
                  // Prevent duplicates in scanned_tickets
                  if (scannedBox.isEmpty) {
                    await scannedBox.add(ScannedTickets(tickets: [ticket]));
                  } else {
                    final scannedTickets = scannedBox.getAt(0)!;
                    // Prevent duplicates
                    if (!scannedTickets.tickets.any((t) => t.orderId == ticket.orderId)) {
                      scannedTickets.tickets.add(ticket);
                      await scannedTickets.save();
                    }
                  }
                  print('Ticket saved: ${ticket.orderId}');
                  widget.onScan(code);
                }

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
              } catch (e, stack) {
                print('Error saving ticket: $e');
                print(stack);
                // Ignore errors
              } finally {
                await cameraController.start();
                _resetScan();
              }
            },
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _ScannerOverlayPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.5);
    final clearPaint = Paint()..blendMode = BlendMode.clear;

    final cutOutSize = 270.0;
    final borderRadius = Radius.circular(6); // adjust for roundness

    final cutOutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );

    final cutOutRRect = RRect.fromRectAndRadius(cutOutRect, borderRadius);

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // Draw dark overlay
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), overlayPaint);

    // Clear rounded cutout area
    canvas.drawRRect(cutOutRRect, clearPaint);

    canvas.restore();

    // Border removed as requested
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

