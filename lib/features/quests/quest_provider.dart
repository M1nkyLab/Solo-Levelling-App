import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_levelling_app/features/quests/daily_quest.dart';
import 'package:solo_levelling_app/features/player/player_rank.dart';
import 'package:solo_levelling_app/features/player/player_provider.dart';

class QuestNotifier extends Notifier<List<DailyQuest>> {
  static const String _questKey = 'quest_state';
  static const String _lastResetKey = 'last_reset_date';
  static const String _lastRewardKey = 'last_reward_date';

  @override
  List<DailyQuest> build() {
    _init();
    // Initial quests (fallback)
    return [
      DailyQuest(id: 'pushups', title: 'Push-ups', baseReps: 100, targetDayOfWeek: DateTime.now().weekday),
      DailyQuest(id: 'situps', title: 'Sit-ups', baseReps: 100, targetDayOfWeek: DateTime.now().weekday),
      DailyQuest(id: 'squats', title: 'Squats', baseReps: 100, targetDayOfWeek: DateTime.now().weekday),
      DailyQuest(id: 'run', title: 'Running', baseReps: 30, targetDayOfWeek: DateTime.now().weekday),
    ];
  }

  Future<void> _init() async {
    await _loadState();
    await _checkDailyReset();
  }

  Future<void> _checkDailyReset() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReset = prefs.getString(_lastResetKey);
    final now = DateTime.now();
    final today = "${now.year}-${now.month}-${now.day}";

    if (lastReset != today) {
      // It's a new day, reset quests
      state = [
        for (final q in state)
          q.copyWith(
            currentReps: 0,
            isCompleted: false,
          ),
      ];
      await prefs.setString(_lastResetKey, today);
      await _saveState();
    }
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_questKey);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = json.decode(jsonString);
        state = decoded.map((item) => DailyQuest.fromJson(item)).toList();
      } catch (e) {
        debugPrint('Error loading quest state: $e');
      }
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_questKey, json.encode(state.map((q) => q.toJson()).toList()));
  }

  void updateReps(String id, int amount) {
    final player = ref.read(playerProvider);
    final level = player.level;

    state = [
      for (final quest in state)
        if (quest.id == id)
          _updateQuest(quest, amount, level)
        else
          quest,
    ];

    _saveState();
    _checkAllDone();
  }

  DailyQuest _updateQuest(DailyQuest quest, int amount, int level) {
    final target = quest.getActualReps(level);
    final newReps = (quest.currentReps + amount).clamp(0, target);
    final isCompleted = newReps >= target;

    return quest.copyWith(currentReps: newReps, isCompleted: isCompleted);
  }

  Future<void> _checkAllDone() async {
    final allDone = state.isNotEmpty && state.every((q) => q.isCompleted);
    if (allDone) {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final today = "${now.year}-${now.month}-${now.day}";
      final lastReward = prefs.getString(_lastRewardKey);

      if (lastReward == today) return; // Already rewarded today

      // ── Reward only when EVERYTHING is complete ──
      final player = ref.read(playerProvider);
      
      // Calculate dynamic EXP: Level x 25
      final expReward = player.level * 25;
      
      // Grant dynamic EXP reward
      ref.read(playerProvider.notifier).addXp(expReward);
      
      // 100 HP Vitality System: Apply rank-based healing
      final healAmount = player.rank.hpGainOnCompletion;
      final newHp = (player.currentHp + healAmount).clamp(0, player.maxHp);
      ref.read(playerProvider.notifier).state = player.copyWith(currentHp: newHp);
      
      await prefs.setString(_lastRewardKey, today);
      _saveState();
    }
  }

  void resetFailedQuests() {
    state = [
      for (final q in state)
        q.copyWith(
          currentReps: 0,
          isCompleted: false,
        ),
    ];
    _saveState();
  }
}

final questProvider = NotifierProvider<QuestNotifier, List<DailyQuest>>(() {
  return QuestNotifier();
});
