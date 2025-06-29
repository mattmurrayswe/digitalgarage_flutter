import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/scanned_tickets.dart';
import '../models/ticket.dart';

class ScannedTicketsTab extends StatefulWidget {
  const ScannedTicketsTab({super.key});

  @override
  State<ScannedTicketsTab> createState() => _ScannedTicketsTabState();
}

class _ScannedTicketsTabState extends State<ScannedTicketsTab> {
  late final Box<ScannedTickets> scannedBox;

  @override
  void initState() {
    super.initState();
    scannedBox = Hive.box<ScannedTickets>('scanned_tickets');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanned Tickets'),
        // The back button appears automatically if this page is pushed
      ),
      body: ValueListenableBuilder(
        valueListenable: scannedBox.listenable(),
        builder: (context, Box<ScannedTickets> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No scanned tickets.'));
          }
          final scannedTickets = box.getAt(0);
          final tickets = scannedTickets?.tickets ?? [];
          if (tickets.isEmpty) {
            return const Center(child: Text('No scanned tickets.'));
          }
          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return ListTile(
                title: Text(ticket.eventName),
                subtitle: Text('Order ID: ${ticket.orderId}\nCustomer: ${ticket.customerName}'),
              );
            },
          );
        },
      ),
    );
  }
}