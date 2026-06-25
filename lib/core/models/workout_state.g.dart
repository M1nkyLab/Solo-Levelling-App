// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutStateAdapter extends TypeAdapter<WorkoutState> {
  @override
  final int typeId = 0;

  @override
  WorkoutState read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WorkoutState.inProgress;
      case 1:
        return WorkoutState.completedPendingSync;
      case 2:
        return WorkoutState.synced;
      default:
        return WorkoutState.inProgress;
    }
  }

  @override
  void write(BinaryWriter writer, WorkoutState obj) {
    switch (obj) {
      case WorkoutState.inProgress:
        writer.writeByte(0);
        break;
      case WorkoutState.completedPendingSync:
        writer.writeByte(1);
        break;
      case WorkoutState.synced:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
