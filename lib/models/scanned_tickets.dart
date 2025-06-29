import 'package:hive/hive.dart';
import 'ticket.dart';

part 'scanned_tickets.g.dart';

@HiveType(typeId: 1)
class ScannedTickets extends HiveObject {
  @HiveField(0)
  List<Ticket> tickets;

  ScannedTickets({required this.tickets});
}