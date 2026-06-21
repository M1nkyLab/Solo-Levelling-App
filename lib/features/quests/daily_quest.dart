import 'package:solo_levelling_app/core/logic/system_logic.dart';

class DailyQuest {
  final String id;
  final String title; 
  final int baseReps; 
  final int currentReps;
  final int targetDayOfWeek; // 1 = Monday, ..., 7 = Sunday
  final bool isCompleted;
  final bool isPenalty;

  DailyQuest({
    required this.id,
    required this.title,
    required this.baseReps,
    this.currentReps = 0,
    required this.targetDayOfWeek,
    this.isCompleted = false,
    this.isPenalty = false,
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
  }) {
    return DailyQuest(
      id: id ?? this.id,
      title: title ?? this.title,
      baseReps: baseReps ?? this.baseReps,
      currentReps: currentReps ?? this.currentReps,
      targetDayOfWeek: targetDayOfWeek ?? this.targetDayOfWeek,
      isCompleted: isCompleted ?? this.isCompleted,
      isPenalty: isPenalty ?? this.isPenalty,
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
    };
  }

  factory DailyQuest.fromJson(Map<String, dynamic> json) {
    return DailyQuest(
      id: json['id'],
      title: json['title'],
      baseReps: json['baseReps'],
      currentReps: json['currentReps'] ?? 0,
      targetDayOfWeek: json['targetDayOfWeek'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
