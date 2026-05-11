import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo_levelling_app/features/quests/daily_quest.dart';
import 'package:solo_levelling_app/features/player/player_provider.dart';
import 'package:solo_levelling_app/features/quests/quest_service.dart';

// NEW: Expose a loading state to the UI
final questLoadingProvider = StateProvider<bool>((ref) => true);

class QuestNotifier extends Notifier<List<DailyQuest>> {
  final QuestService _questService = QuestService();
  String? _userId;
  bool _mounted = true;
  int _lastFetchId = 0;

  @override
  List<DailyQuest> build() {
    ref.onDispose(() => _mounted = false);
    return [];
  }

  Future<void> fetchQuests(String userId, {DateTime? date, List<int>? localSchedule}) async {
    _userId = userId;
    final int fetchId = ++_lastFetchId;
    
    final effectiveSchedule = localSchedule ?? ref.read(scheduleProvider).days;
    final targetDate = date ?? DateTime.now();
    final int weekday = targetDate.weekday;

    // --- INSTANT ARISE PROTOCOL ---
    // If state is empty and it's a scheduled day, inject local fallbacks IMMEDIATELY
    // before the async fetch starts. This guarantees they appear on screen.
    if (state.isEmpty && effectiveSchedule.contains(weekday) && _mounted) {
      debugPrint('QuestNotifier: [INSTANT ARISE] Injecting protocols before fetch.');
      state = [
        DailyQuest(id: 'pushups', title: 'Push-ups', baseReps: 20, targetDayOfWeek: weekday),
        DailyQuest(id: 'situps', title: 'Sit-ups', baseReps: 20, targetDayOfWeek: weekday),
        DailyQuest(id: 'squats', title: 'Squats', baseReps: 20, targetDayOfWeek: weekday),
        DailyQuest(id: 'run', title: 'Running', baseReps: 20, targetDayOfWeek: weekday),
      ];
    }
    
    // Only lock UI if we are STILL empty (unlikely after injection)
    if (state.isEmpty) {
      ref.read(questLoadingProvider.notifier).state = true;
    }
    
    try {
      debugPrint('QuestNotifier: [FETCH $fetchId] Starting for $userId...');
      
      var quests = await _questService.getDailyQuests(userId, date: date, localSchedule: effectiveSchedule);
      
      // ... rest of the method

  void updateReps(String id, int amount, {DateTime? date}) async {
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
      await _questService.updateQuestProgress(_userId!, id, newReps, isCompleted, date: date);
      
      if (isCompleted) {
        _checkAllDone();
      }
    } catch (e) {
      debugPrint('Error updating reps in Supabase: $e');
    }
  }

  void resetFailedQuests() {
    state = state.map((q) => q.copyWith(currentReps: 0, isCompleted: false)).toList();
  }

  final Set<String> _rewardedDates = {};

  void _checkAllDone() async {
    final quests = state;
    if (quests.isEmpty) return;

    final allDone = quests.every((q) => q.isCompleted);
    if (allDone) {
      final selectedDate = ref.read(selectedDateProvider);
      final dateKey = "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";

      // Ensure we only trigger this once per day (session-based for now)
      if (_rewardedDates.contains(dateKey)) return;
      
      _rewardedDates.add(dateKey);
      
      final player = ref.read(playerProvider);
      // Reward logic: Level * 25 XP
      final rewardXp = player.level * 25;
      
      await ref.read(playerProvider.notifier).addXp(rewardXp);
      
      debugPrint('DAILY QUEST COMPLETE: Reward $rewardXp XP added via SQL schema.');
    }
  }
}

final questProvider = NotifierProvider<QuestNotifier, List<DailyQuest>>(() {
  return QuestNotifier();
});

final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});
