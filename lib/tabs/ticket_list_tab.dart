// lib/tabs/ticket_list_tab.dart

import 'package:digitalgarage_futter/models/ticket.dart';
import 'package:digitalgarage_futter/models/scanned_tickets.dart';
import 'package:digitalgarage_futter/tabs/scanned_tickets_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TicketListTab extends StatefulWidget {
  final List<String> scannedCodes;

  const TicketListTab({super.key, required this.scannedCodes});

  @override
  State<TicketListTab> createState() => _TicketListTabState();
}

class _TicketListTabState extends State<TicketListTab> {
  int totalTickets = 0;
  int scannedTickets = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTicketsFromHive();
  }

  Future<void> _loadTicketsFromHive() async {
    final box = Hive.box<Ticket>('tickets');
    final tickets = box.values.toList();
    final boxScannedTickets = Hive.box<ScannedTickets>('scanned_tickets');

    ScannedTickets? scannedTicketsObj;
    if (boxScannedTickets.isNotEmpty) {
      scannedTicketsObj = boxScannedTickets.getAt(0);
    }

    setState(() {
      totalTickets = tickets.length;
      scannedTickets = scannedTicketsObj?.tickets.length ?? 0;
    });
  }

  Future<void> fetchValidTickets() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('https://digitalgarage.com.br/api/ingressos'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        final box = Hive.box<Ticket>('tickets');
        await box.clear();

        final tickets = jsonData.map((json) => Ticket.fromJson(json)).toList();

        for (var ticket in tickets) {
          await box.add(ticket);
        }

        setState(() {
          totalTickets = tickets.length;
        });
      } else {
        _showErrorDialog('Failed to fetch tickets from the server.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred while fetching tickets.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _exportHiveTicketsToJson() {
    final box = Hive.box<Ticket>('tickets');
    final jsonList = box.values.map((ticket) => ticket.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    Clipboard.setData(ClipboardData(text: jsonString));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tickets JSON copied to clipboard')),
    );
  }

  Widget _infoCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          // gradient: const LinearGradient(
          //   colors: [Color(0xFF18181B), Colors.black], // gray950 to black
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          // ),
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Color(0xFF18181B), // gray950
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonWidth = 200.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Ticket Status')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- FIX: Wrap info cards in ValueListenableBuilder ---
            ValueListenableBuilder(
              valueListenable: Hive.box<ScannedTickets>('scanned_tickets').listenable(),
              builder: (context, Box<ScannedTickets> scannedBox, _) {
                int scanned = 0;
                if (scannedBox.isNotEmpty) {
                  final scannedTicketsObj = scannedBox.getAt(0);
                  scanned = scannedTicketsObj?.tickets.length ?? 0;
                }
                final total = totalTickets;
                final remaining = total - scanned;
                return Row(
                  children: [
                    _infoCard(
                      label: 'Total',
                      value: '$total',
                      icon: Icons.confirmation_number_outlined,
                      color: Colors.orange
                    ),
                    const SizedBox(width: 10),
                    _infoCard(
                      label: 'Scanned',
                      value: '$scanned',
                      icon: Icons.qr_code_scanner,
                      color: Colors.indigoAccent
                    ),
                    const SizedBox(width: 10),
                    _infoCard(
                      label: 'Remaining',
                      value: '$remaining',
                      icon: Icons.hourglass_bottom,
                      color: Colors.cyan
                    ),
                  ],
                );
              },
            ),
            // --- END FIX ---
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: buttonWidth,
                  child: GradientButton(
                    onPressed: isLoading ? null : fetchValidTickets,
                    icon: const Icon(Icons.sync, color: Colors.white),
                    label: Text(
                      isLoading ? 'Loading...' : 'Fetch Valid Tickets',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    gradientColors: const [
                      Color(0xFF18181B), // gray950
                      Colors.black,
                    ],
                    disabled: isLoading,
                  ),
                ),
                SizedBox(
                  width: buttonWidth,
                  child: GradientButton(
                    onPressed: isLoading ? null : _exportHiveTicketsToJson,
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: const Text(
                      'Export to JSON',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    gradientColors: const [
                      Color(0xFF18181B), // gray950
                      Colors.black,
                    ],
                    disabled: isLoading,
                  ),
                ),
                SizedBox(
                  width: buttonWidth,
                  child: GradientButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.of(context).pushNamed('/sold');
                          },
                    icon: const Icon(Icons.list_alt, color: Colors.white),
                    label: const Text(
                      'Sold Tickets',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    gradientColors: const [
                      Color(0xFF18181B), // gray950
                      Colors.black,
                    ],
                    disabled: isLoading,
                  ),
                ),
                SizedBox(
                  width: buttonWidth,
                  child: GradientButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.of(context).pushNamed('/scanned');
                          },
                    icon: const Icon(Icons.list_alt, color: Colors.white),
                    label: const Text(
                      'Scanned Tickets',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    gradientColors: const [
                      Color(0xFF18181B), // gray950
                      Colors.black,
                    ],
                    disabled: isLoading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (totalTickets == 0)
              const Text('No tickets available. Please fetch.', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

// Place this widget in your file or in a separate file for reuse.
class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final Widget label;
  final List<Color> gradientColors;
  final bool disabled;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.gradientColors,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: GestureDetector(
        onTap: disabled ? null : onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF18181B), // gray950
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors.first.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 8),
              label,
            ],
          ),
        ),
      ),
    );
  }
}
