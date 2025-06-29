import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/ticket.dart';

class SoldTicketsTab extends StatelessWidget {
  const SoldTicketsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Ticket>('tickets');
    final tickets = box.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Sold Tickets')),
      body: ListView.builder(
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return ListTile(
            title: Text(ticket.orderId),
            subtitle: Text(ticket.toString()),
          );
        },
      ),
    );
  }
}