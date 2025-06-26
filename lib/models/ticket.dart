import 'package:hive/hive.dart';

part 'ticket.g.dart';

@HiveType(typeId: 0)
class Ticket extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String eventName;
  @HiveField(2)
  String customerName;
  @HiveField(3)
  String email;
  @HiveField(4)
  String orderId;
  @HiveField(5)
  String amount;
  @HiveField(6)
  String ticketName;
  @HiveField(7)
  String location;
  @HiveField(8)
  String address;
  @HiveField(9)
  String orderDate;

  Ticket({
    required this.id,
    required this.eventName,
    required this.customerName,
    required this.email,
    required this.orderId,
    required this.amount,
    required this.ticketName,
    required this.location,
    required this.address,
    required this.orderDate,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'].toString(),
      eventName: json['event_name'],
      customerName: json['customer_name'],
      email: json['email'],
      orderId: json['order_id'],
      amount: json['amount'],
      ticketName: json['ticket_name'],
      location: json['location'],
      address: json['address'],
      orderDate: json['order_date'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'event_name': eventName,
    'customer_name': customerName,
    'email': email,
    'order_id': orderId,
    'amount': amount,
    'ticket_name': ticketName,
    'location': location,
    'address': address,
    'order_date': orderDate,
  };
}
