import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo_levelling_app/features/quests/daily_quest.dart';
import 'package:solo_levelling_app/features/player/player.dart';
import 'package:solo_levelling_app/features/player/player_rank.dart';
import 'package:solo_levelling_app/features/player/player_provider.dart';
import 'package:solo_levelling_app/features/quests/quest_service.dart';
import 'package:solo_levelling_app/features/quests/schedule_provider.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// NEW: Expose a loading state to the UI
final questLoadingProvider = StateProvider<bool>((ref) => true);

class QuestNotifier extends Notifier<List<DailyQuest>> {
  final QuestService _questService = QuestService();
  String? _userId;
  bool _mounted = true;
  int _lastFetchId = 0;
  static const String _questsKey = 'daily_quests_state';

  @override
  List<DailyQuest> build() {
    ref.onDispose(() => _mounted = false);
    _loadLocalQuests();
    return [];
  }

  Future<void> _loadLocalQuests() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_questsKey);
    if (jsonString != null && _mounted) {
      try {
        final List<dynamic> jsonList = json.decode(jsonString);
        state = jsonList.map((j) => DailyQuest.fromJson(j)).toList();
      } catch (e) {
        debugPrint('Error loading local quests: $e');
      }
    }
  }

  Future<void> _saveLocalQuests() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(state.map((q) => q.toJson()).toList());
    await prefs.setString(_questsKey, jsonString);
  }

  Future<void> fetchQuests(String userId, {DateTime? date, List<int>? localSchedule}) async {
    _userId = userId;
    final int fetchId = ++_lastFetchId;
    
    final effectiveSchedule = localSchedule ?? ref.read(scheduleProvider).days;
    final targetDate = date ?? DateTime.now();
    final int weekday = targetDate.weekday;
    final player = ref.read(playerProvider);
    final isPenalty = player.trialStatus == TrialStatus.penalty;

    // --- INSTANT ARISE PROTOCOL ---
    // If state is empty and it's a scheduled day (or penalty state), inject local fallbacks
    if (state.isEmpty && (effectiveSchedule.contains(weekday) || isPenalty) && _mounted) {
      debugPrint('QuestNotifier: [INSTANT ARISE] Injecting protocols before fetch. Penalty: $isPenalty');
      state = [
        DailyQuest(id: 'pushups', title: 'Push-ups', baseReps: 20, targetDayOfWeek: weekday, isPenalty: isPenalty),
        DailyQuest(id: 'situps', title: 'Sit-ups', baseReps: 20, targetDayOfWeek: weekday, isPenalty: isPenalty),
        DailyQuest(id: 'squats', title: 'Squats', baseReps: 20, targetDayOfWeek: weekday, isPenalty: isPenalty),
        DailyQuest(id: 'run', title: 'Running', baseReps: 20, targetDayOfWeek: weekday, isPenalty: isPenalty),
      ];
    }
    
    // Only lock UI if we are STILL empty
    if (state.isEmpty) {
      ref.read(questLoadingProvider.notifier).state = true;
    }
    
    try {
      debugPrint('QuestNotifier: [FETCH $fetchId] Starting for $userId...');
      
      var quests = await _questService.getDailyQuests(userId, date: date, localSchedule: effectiveSchedule);
      
      // Guard: discard stale fetches
      if (fetchId != _lastFetchId || !_mounted) return;

      // Map quests to penalty state if needed
      if (isPenalty) {
        quests = quests.map((q) => q.copyWith(isPenalty: true)).toList();
      }

      debugPrint('QuestNotifier: [FETCH $fetchId] Completed. Got ${quests.length} quests.');
      state = quests;
    } catch (e, stack) {
      debugPrint('QuestNotifier: [FETCH $fetchId] Error: $e');
      debugPrint('QuestNotifier: StackTrace: $stack');
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
    
    // System Mandate: Progress is permanent.
    if (amount < 0) return;

    final newReps = (quest.currentReps + amount).clamp(0, target);
    final isCompleted = newReps >= target;

    // Local update for instant UI feedback
    final newState = [...state];
    newState[questIndex] = quest.copyWith(currentReps: newReps, isCompleted: isCompleted);
    state = newState;
    _saveLocalQuests();

    // Remote update
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

  void _checkAllDone() {
    final quests = state;
    if (quests.isEmpty) return;

    final allDone = quests.every((q) => q.isCompleted);
    if (allDone) {
      final selectedDate = ref.read(selectedDateProvider);
      final dateKey = "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";

      // Guard: only trigger once per day (unless it's a penalty)
      final player = ref.read(playerProvider);
      final isPenalty = player.trialStatus == TrialStatus.penalty;
      
      if (!isPenalty && _rewardedDates.contains(dateKey)) return;
      if (!isPenalty) _rewardedDates.add(dateKey);

      // System Reward Scaling: 0 XP for penalty, else scaled XP
      int rewardXp = 0;
      if (!isPenalty) {
        const int baseEssence = 25;
        final int rankMultiplier = _getRankMultiplier(player.rank);
        rewardXp = player.level * baseEssence * rankMultiplier;
      }

      // Store pending reward and show popup
      ref.read(_pendingQuestRewardProvider.notifier).state = rewardXp;
      ref.read(questCompletionOverlayProvider.notifier).state = rewardXp;

      // System Voice Alert removed

      debugPrint('DAILY QUEST: Popup triggered. Penalty: $isPenalty. Reward: $rewardXp XP.');
    }
  }

  /// Called by the popup "Continue" button to finalize the reward.
  Future<void> claimQuestReward() async {
    final pendingXp = ref.read(_pendingQuestRewardProvider);
    final player = ref.read(playerProvider);
    final isPenalty = player.trialStatus == TrialStatus.penalty;

    // Clear pending reward
    ref.read(_pendingQuestRewardProvider.notifier).state = null;
    ref.read(questCompletionOverlayProvider.notifier).state = null;

    if (isPenalty) {
      debugPrint('PENALTY QUEST CLAIM: Restoring active status...');
      ref.read(playerProvider.notifier).clearPenalty();
    } else if (pendingXp != null) {
      debugPrint('DAILY QUEST CLAIM: Awarding $pendingXp XP + HP heal...');
      await ref.read(playerProvider.notifier).addXp(pendingXp);
      await ref.read(playerProvider.notifier).healOnQuestComplete();
    }

    debugPrint('QUEST CLAIM: Complete.');
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
