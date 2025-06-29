// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanned_tickets.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScannedTicketsAdapter extends TypeAdapter<ScannedTickets> {
  @override
  final int typeId = 1;

  @override
  ScannedTickets read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScannedTickets(
      tickets: (fields[0] as List).cast<Ticket>(),
    );
  }

  @override
  void write(BinaryWriter writer, ScannedTickets obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.tickets);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScannedTicketsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
