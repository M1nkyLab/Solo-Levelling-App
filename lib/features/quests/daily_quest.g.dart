// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_quest.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyQuestAdapter extends TypeAdapter<DailyQuest> {
  @override
  final int typeId = 1;

  @override
  DailyQuest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyQuest(
      id: fields[0] as String,
      title: fields[1] as String,
      baseReps: fields[2] as int,
      currentReps: fields[3] as int,
      targetDayOfWeek: fields[4] as int,
      isCompleted: fields[5] as bool,
      isPenalty: fields[6] as bool,
      state: fields[7] as WorkoutState,
    );
  }

  @override
  void write(BinaryWriter writer, DailyQuest obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.baseReps)
      ..writeByte(3)
      ..write(obj.currentReps)
      ..writeByte(4)
      ..write(obj.targetDayOfWeek)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.isPenalty)
      ..writeByte(7)
      ..write(obj.state);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyQuestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
