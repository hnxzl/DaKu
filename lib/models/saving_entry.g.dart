// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saving_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavingEntryAdapter extends TypeAdapter<SavingEntry> {
  @override
  final int typeId = 1;

  @override
  SavingEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavingEntry(
      id: fields[0] as String,
      goalId: fields[1] as String,
      amount: fields[2] as double,
      note: fields[3] as String?,
      date: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SavingEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.goalId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
