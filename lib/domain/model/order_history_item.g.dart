// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_history_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderHistoryItemAdapter extends TypeAdapter<OrderHistoryItem> {
  @override
  final int typeId = 3;

  @override
  OrderHistoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderHistoryItem(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      items: (fields[2] as List).cast<OrderItem>(),
      totalAmount: fields[3] as int,
      deliveredItems: (fields[4] as Map?)?.cast<String, bool>(),
    );
  }

  @override
  void write(BinaryWriter writer, OrderHistoryItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.items)
      ..writeByte(3)
      ..write(obj.totalAmount)
      ..writeByte(4)
      ..write(obj.deliveredItems);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderHistoryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
