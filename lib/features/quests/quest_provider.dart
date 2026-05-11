import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo_levelling_app/features/quests/daily_quest.dart';
import 'package:solo_levelling_app/features/player/player_rank.dart';
import 'package:solo_levelling_app/features/player/player_provider.dart';
import 'package:solo_levelling_app/features/quests/quest_service.dart';
import 'package:solo_levelling_app/features/quests/schedule_provider.dart';

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
      
      // Guard: discard stale fetches if a newer one started
      if (fetchId != _lastFetchId || !_mounted) return;

      debugPrint('QuestNotifier: [FETCH $fetchId] Completed. Got ${quests.length} quests.');
      state = quests;
    } catch (e, stack) {
      debugPrint('QuestNotifier: [FETCH $fetchId] Error: $e');
      debugPrint('QuestNotifier: StackTrace: $stack');
      // If we had injected instant-arise fallbacks, keep them on error
    } finally {
      if (_mounted && fetchId == _lastFetchId) {
        ref.read(questLoadingProvider.notifier).state = false;
      }
    }
  }

  void updateReps(String id, int amount, {DateTime? date}) async {
    if (_userId == null) return;
    
    final player = ref.read(playerProvider);
    final level = player.level;

    final questIndex = state.indexWhere((q) => q.id == id);
    if (questIndex == -1) return;

    final quest = state[questIndex];
    final target = quest.getActualReps(level);
    
    // System Mandate: Progress is permanent. No regression allowed.
    if (amount < 0) return;

    final newReps = (quest.currentReps + amount).clamp(0, target);
    final isCompleted = newReps >= target;

    // Local update for instant UI feedback
    final newState = [...state];
    newState[questIndex] = quest.copyWith(currentReps: newReps, isCompleted: isCompleted);
    state = newState;

    // Remote update to Supabase
    try {
      await _questService.updateQuestProgress(_userId!, id, newReps.toInt(), isCompleted, date: date);
      
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

  // Called when all quests are done — only shows the popup.
  // Actual XP + HP reward is deferred until the user presses "Continue".
  void _checkAllDone() {
    final quests = state;
    if (quests.isEmpty) return;

    final allDone = quests.every((q) => q.isCompleted);
    if (allDone) {
      final selectedDate = ref.read(selectedDateProvider);
      final dateKey = "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";

      // Guard: only trigger once per day
      if (_rewardedDates.contains(dateKey)) return;
      _rewardedDates.add(dateKey);

      final player = ref.read(playerProvider);

      // System Reward Scaling: level * base * rank multiplier
      const int baseEssence = 25;
      final int rankMultiplier = _getRankMultiplier(player.rank);
      final int rewardXp = player.level * baseEssence * rankMultiplier;

      // Store pending reward and show popup — do NOT award yet
      ref.read(_pendingQuestRewardProvider.notifier).state = rewardXp;
      ref.read(questCompletionOverlayProvider.notifier).state = rewardXp;

      debugPrint('DAILY QUEST: Popup triggered. Pending reward: $rewardXp XP.');
    }
  }

  /// Called by the popup "Continue" button to finalize the reward.
  Future<void> claimQuestReward() async {
    final pendingXp = ref.read(_pendingQuestRewardProvider);
    if (pendingXp == null) return;

    // Clear pending reward immediately to prevent double-claim
    ref.read(_pendingQuestRewardProvider.notifier).state = null;
    ref.read(questCompletionOverlayProvider.notifier).state = null;

    debugPrint('DAILY QUEST CLAIM: Awarding $pendingXp XP + HP heal...');

    // 1. Award XP (triggers level-up logic in Supabase via add_player_xp RPC)
    await ref.read(playerProvider.notifier).addXp(pendingXp);

    // 2. Heal HP based on rank (vitality reward for completing the daily protocol)
    await ref.read(playerProvider.notifier).healOnQuestComplete();

    debugPrint('DAILY QUEST CLAIM: Complete.');
  }

  int _getRankMultiplier(PlayerRank rank) {
    switch (rank) {
      case PlayerRank.S: return 5;
      case PlayerRank.A: return 4;
      case PlayerRank.B: return 3;
      case PlayerRank.C: return 2;
      default: return 1;
    }
  }
}

final questProvider = NotifierProvider<QuestNotifier, List<DailyQuest>>(() {
  return QuestNotifier();
});

final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// Signal for the completion popup.
// Stores the EXP reward amount when triggered, null otherwise.
final questCompletionOverlayProvider = StateProvider<int?>((ref) => null);

// Internal: stores the pending XP until "Continue" is pressed.
final _pendingQuestRewardProvider = StateProvider<int?>((ref) => null);
