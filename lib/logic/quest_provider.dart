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
    final isCompleted = newReps >= target;

    return quest.copyWith(currentReps: newReps, isCompleted: isCompleted);
  }

  void _checkAllDone() {
    final allDone = state.every((q) => q.isCompleted);
    if (allDone) {
      // ── Reward only when EVERYTHING is complete ──
      // Grant a large EXP reward
      ref.read(playerProvider.notifier).addXp(500);
      
      // ── Difficulty Scaling & Reset ──
      // In this system, we reset the reps and increase the baseline difficulty
      // to simulate the "Next Day" or "Rank Progression" feel.
      state = [
        for (final q in state)
          q.copyWith(
            currentReps: 0,
            isCompleted: false,
            // Increase base difficulty slightly for next time
            baseReps: (q.baseReps * 1.05).round(), 
          ),
      ];
    }
  }
}

final questProvider = NotifierProvider<QuestNotifier, List<DailyQuest>>(() {
  return QuestNotifier();
});
