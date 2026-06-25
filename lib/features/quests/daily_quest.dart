import 'package:hive/hive.dart';
import 'package:solo_levelling_app/core/logic/system_logic.dart';
import 'package:solo_levelling_app/core/models/workout_state.dart';

part 'daily_quest.g.dart';

@HiveType(typeId: 1)
class DailyQuest {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final int baseReps;

  @HiveField(3)
  final int currentReps;

  @HiveField(4)
  final int targetDayOfWeek; // 1 = Monday, ..., 7 = Sunday

  @HiveField(5)
  final bool isCompleted;

  @HiveField(6)
  final bool isPenalty;

  @HiveField(7)
  final WorkoutState state;

  DailyQuest({
    required this.id,
    required this.title,
    required this.baseReps,
    this.currentReps = 0,
    required this.targetDayOfWeek,
    this.isCompleted = false,
    this.isPenalty = false,
    this.state = WorkoutState.inProgress,
  });

  // Toggles completion status
  DailyQuest copyWith({
    String? id,
    String? title,
    int? baseReps,
    int? currentReps,
    int? targetDayOfWeek,
    bool? isCompleted,
    bool? isPenalty,
    WorkoutState? state,
  }) {
    return DailyQuest(
      id: id ?? this.id,
      title: title ?? this.title,
      baseReps: baseReps ?? this.baseReps,
      currentReps: currentReps ?? this.currentReps,
      targetDayOfWeek: targetDayOfWeek ?? this.targetDayOfWeek,
      isCompleted: isCompleted ?? this.isCompleted,
      isPenalty: isPenalty ?? this.isPenalty,
      state: state ?? this.state,
    );
  }

  // The System calculates the actual reps needed for the day based on level
  int getActualReps(int level) {
    final int target = SystemLogic.calculateRequirement(id, level);
    return isPenalty ? (target * 1.5).round() : target;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'baseReps': baseReps,
      'currentReps': currentReps,
      'targetDayOfWeek': targetDayOfWeek,
      'isCompleted': isCompleted,
      'state': state.name,
    };
  }

  factory DailyQuest.fromJson(Map<String, dynamic> json) {
    WorkoutState parsedState = WorkoutState.inProgress;
    if (json['state'] != null) {
      parsedState = WorkoutState.values.firstWhere(
        (e) => e.name == json['state'],
        orElse: () => WorkoutState.inProgress,
      );
    } else if (json['isCompleted'] == true) {
      parsedState = WorkoutState.synced; // Default backwards compatibility
    }

    return DailyQuest(
      id: json['id'],
      title: json['title'],
      baseReps: json['baseReps'],
      currentReps: json['currentReps'] ?? 0,
      targetDayOfWeek: json['targetDayOfWeek'],
      isCompleted: json['isCompleted'] ?? false,
      state: parsedState,
    );
  }
}
