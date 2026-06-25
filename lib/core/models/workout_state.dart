import 'package:hive/hive.dart';

part 'workout_state.g.dart';

@HiveType(typeId: 0)
enum WorkoutState {
  @HiveField(0)
  inProgress,

  @HiveField(1)
  completedPendingSync,

  @HiveField(2)
  synced,
}
