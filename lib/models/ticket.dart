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
  @HiveField(10)
  String customerId; // Added field

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
    required this.customerId, // Added parameter
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'].toString(),
      eventName: json['event_name'].toString(),
      customerName: json['customer_name'].toString(),
      email: json['email'].toString(),
      orderId: json['order_id'].toString(),
      amount: json['amount'].toString(),
      ticketName: json['ticket_name'].toString(),
      location: json['location'].toString(),
      address: json['address'].toString(),
      orderDate: json['order_date'].toString(),
      customerId: json['customer_id'].toString(),
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
    'customer_id': customerId, // Added field
  };
}
