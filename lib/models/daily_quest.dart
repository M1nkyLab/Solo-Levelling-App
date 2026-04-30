import 'player_rank.dart';

class DailyQuest {
  final String id;
  final String title; 
  final int baseReps; 
  final int targetDayOfWeek; // 1 = Monday, ..., 7 = Sunday
  final bool isCompleted;

  DailyQuest({
    required this.id,
    required this.title,
    required this.baseReps,
    required this.targetDayOfWeek,
    this.isCompleted = false,
  });

  // Toggles completion status
  DailyQuest copyWith({
    String? id,
    String? title,
    int? baseReps,
    int? targetDayOfWeek,
    bool? isCompleted,
  }) {
    return DailyQuest(
      id: id ?? this.id,
      title: title ?? this.title,
      baseReps: baseReps ?? this.baseReps,
      targetDayOfWeek: targetDayOfWeek ?? this.targetDayOfWeek,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // The System calculates the actual reps needed for the day based on rank
  int getActualReps(PlayerRank currentRank) {
    return (baseReps * currentRank.repMultiplier).round();
  }
}
