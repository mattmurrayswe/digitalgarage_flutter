import 'package:digitalgarage_futter/models/ticket.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TicketListScreen extends StatefulWidget {
  final List<String> scannedCodes;

  const TicketListScreen({super.key, required this.scannedCodes});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  List<String> validTickets = [];
  bool isLoading = false;
  int totalTickets = 0;

  @override
  void initState() {
    super.initState();
    _loadTicketsFromHive();
  }

  Future<void> _loadTicketsFromHive() async {
    final box = Hive.box<Ticket>('tickets');
    final tickets = box.values.toList();

    setState(() {
      totalTickets = tickets.length;
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
        print('Fetch tickets response: ${response.body}');

        final box = Hive.box<Ticket>('tickets');
        await box.clear(); // optional: clear old data

        final tickets = jsonData.map((json) => Ticket.fromJson(json)).toList();

        for (var ticket in tickets) {
          await box.add(ticket); // Save each ticket
        }

        setState(() {
          totalTickets = tickets.length; // ✅ Update totalTickets
        });
      } else {
        print('Failed to fetch tickets: ${response.statusCode}');
        _showErrorDialog('Failed to fetch tickets from the server.');
      }
    } catch (e) {
      print('Error fetching tickets: $e');
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

    print(jsonString); // prints JSON to debug console

    // Optional: Copy JSON string to clipboard
    Clipboard.setData(ClipboardData(text: jsonString));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tickets JSON copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = totalTickets - widget.scannedCodes.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Ticket Status')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (totalTickets > 0) ...[
              Text('Total Tickets: $totalTickets'),
              Text('Scanned: ${widget.scannedCodes.length}'),
              Text('Remaining: $remaining'),
            ] else ...[
              const Text('No tickets available. Please fetch.'),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : fetchValidTickets,
              child: Text(isLoading ? 'Loading...' : 'Fetch Valid Tickets'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : _exportHiveTicketsToJson,
              child: const Text('Export to JSON'),
            ),
            if (validTickets.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Valid Tickets:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView(
                  children: validTickets
                      .map((ticket) => Text('✔ $ticket'))
                      .toList(),
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Text(
              'Scanned Codes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.scannedCodes.length,
                itemBuilder: (context, index) {
                  final code = widget.scannedCodes[index];
                  final isValid = validTickets.contains(code);

                  return Text(
                    '• $code ${validTickets.isEmpty
                        ? ""
                        : isValid
                        ? "✅"
                        : "❌"}',
                    style: TextStyle(
                      color: isValid ? Colors.green : Colors.red,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
