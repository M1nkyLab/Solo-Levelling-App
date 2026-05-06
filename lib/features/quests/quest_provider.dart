import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo_levelling_app/features/quests/daily_quest.dart';
import 'package:solo_levelling_app/features/player/player_provider.dart';
import 'package:solo_levelling_app/features/quests/quest_service.dart';

class QuestNotifier extends Notifier<List<DailyQuest>> {
  final QuestService _questService = QuestService();
  String? _userId;

  @override
  List<DailyQuest> build() {
    // Initial empty state
    return [];
  }

  Future<void> fetchQuests(String userId) async {
    _userId = userId;
    try {
      final quests = await _questService.getDailyQuests(userId);
      state = quests;
    } catch (e) {
      debugPrint('Error fetching quests: $e');
    }
  }

  void updateReps(String id, int amount) async {
    if (_userId == null) return;
    
    final player = ref.read(playerProvider);
    final level = player.level;

    final questIndex = state.indexWhere((q) => q.id == id);
    if (questIndex == -1) return;

    final quest = state[questIndex];
    final target = quest.getActualReps(level);
    final newReps = (quest.currentReps + amount).clamp(0, target);
    final isCompleted = newReps >= target;

    // Local update for instant UI feedback
    final newState = [...state];
    newState[questIndex] = quest.copyWith(currentReps: newReps, isCompleted: isCompleted);
    state = newState;

    // Remote update to Supabase
    try {
      await _questService.updateQuestProgress(_userId!, id, newReps, isCompleted);
      
      if (isCompleted) {
        _checkAllDone();
      }
    } catch (e) {
      debugPrint('Error updating reps in Supabase: $e');
    }
  }

  void resetFailedQuests() {
    state = state.map((q) => q.copyWith(currentReps: 0, isCompleted: false)).toList();
    // Note: We don't sync this to Supabase immediately as the penalty
    // already updated the DB state. This is just for local UI reset.
  }

  void _checkAllDone() async {
    final allDone = state.isNotEmpty && state.every((q) => q.isCompleted);
    if (allDone) {
      final player = ref.read(playerProvider);
      // Reward logic: Level * 25 XP
      final rewardXp = player.level * 25;
      
      // We can use playerProvider to add XP, which is now synced with Supabase
      ref.read(playerProvider.notifier).addXp(rewardXp);
      
      debugPrint('DAILY QUEST COMPLETE: Reward $rewardXp XP');
    }
  }
}

final questProvider = NotifierProvider<QuestNotifier, List<DailyQuest>>(() {
  return QuestNotifier();
});
