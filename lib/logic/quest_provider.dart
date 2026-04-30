import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_quest.dart';
import '../models/player_rank.dart';
import 'player_provider.dart';

class QuestNotifier extends Notifier<List<DailyQuest>> {
  @override
  List<DailyQuest> build() {
    // Initial quests
    return [
      DailyQuest(id: 'pushups', title: 'Push-ups', baseReps: 100, targetDayOfWeek: DateTime.now().weekday),
      DailyQuest(id: 'situps', title: 'Sit-ups', baseReps: 100, targetDayOfWeek: DateTime.now().weekday),
      DailyQuest(id: 'squats', title: 'Squats', baseReps: 100, targetDayOfWeek: DateTime.now().weekday),
      DailyQuest(id: 'run', title: 'Running', baseReps: 30, targetDayOfWeek: DateTime.now().weekday),
    ];
  }

  void updateReps(String id, int amount) {
    final player = ref.read(playerProvider);
    final rank = player.rank;

    state = [
      for (final quest in state)
        if (quest.id == id)
          _updateQuest(quest, amount, rank)
        else
          quest,
    ];

    _checkAllDone();
  }

  DailyQuest _updateQuest(DailyQuest quest, int amount, PlayerRank rank) {
    final target = quest.getActualReps(rank);
    final newReps = (quest.currentReps + amount).clamp(0, target);
    
    final wasCompleted = quest.isCompleted;
    final isCompleted = newReps >= target;

    if (!wasCompleted && isCompleted) {
      // Grant individual reward
      final xpReward = quest.id == 'run' ? 150 : 100;
      ref.read(playerProvider.notifier).addXp(xpReward);
    }

    return quest.copyWith(currentReps: newReps, isCompleted: isCompleted);
  }

  void _checkAllDone() {
    final allDone = state.every((q) => q.isCompleted);
    // Note: In a real app, you'd want to track if the daily bonus was already claimed today.
    // For this prototype, we'll assume it's a one-time trigger per session or managed elsewhere.
  }
}

final questProvider = NotifierProvider<QuestNotifier, List<DailyQuest>>(() {
  return QuestNotifier();
});
