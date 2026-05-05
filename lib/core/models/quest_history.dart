class QuestHistory {
  final String id;
  final String playerId;
  final String questId;
  final int repsCompleted;
  final DateTime completedDate;

  QuestHistory({
    required this.id,
    required this.playerId,
    required this.questId,
    required this.repsCompleted,
    required this.completedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player_id': playerId,
      'quest_id': questId,
      'reps_completed': repsCompleted,
      'completed_date': completedDate.toIso8601String(),
    };
  }

  factory QuestHistory.fromJson(Map<String, dynamic> json) {
    return QuestHistory(
      id: json['id'],
      playerId: json['player_id'],
      questId: json['quest_id'],
      repsCompleted: json['reps_completed'],
      completedDate: DateTime.parse(json['completed_date']),
    );
  }
}
