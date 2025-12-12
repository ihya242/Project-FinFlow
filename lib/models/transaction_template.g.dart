// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_template.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionTemplateAdapter extends TypeAdapter<TransactionTemplate> {
  @override
  final int typeId = 3;

  @override
  TransactionTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionTemplate(
      title: fields[0] as String,
      type: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionTemplate obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
