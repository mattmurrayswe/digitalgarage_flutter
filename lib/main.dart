import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/scanned_tickets.dart';
import 'models/ticket.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);

  Hive.registerAdapter(TicketAdapter());
  Hive.registerAdapter(ScannedTicketsAdapter());

  await Hive.openBox<Ticket>('tickets');
  await Hive.openBox<ScannedTickets>('scanned_tickets');

  runApp(const MyApp());
}
