import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_levelling_app/features/quests/daily_quest.dart';
import 'package:solo_levelling_app/features/player/player_rank.dart';
import 'package:solo_levelling_app/features/player/player_provider.dart';

class QuestNotifier extends Notifier<List<DailyQuest>> {
  final _supabase = Supabase.instance.client;
  String? _userId;

  @override
  List<DailyQuest> build() {
    // Initial quests (fallback while loading)
    return [
      DailyQuest(id: 'pushups', title: 'Push-ups', baseReps: 100, targetDayOfWeek: DateTime.now().weekday),
      DailyQuest(id: 'situps', title: 'Sit-ups', baseReps: 100, targetDayOfWeek: DateTime.now().weekday),
      DailyQuest(id: 'squats', title: 'Squats', baseReps: 100, targetDayOfWeek: DateTime.now().weekday),
      DailyQuest(id: 'run', title: 'Running', baseReps: 30, targetDayOfWeek: DateTime.now().weekday),
    ];
  }

  Future<void> fetchQuests(String userId) async {
    _userId = userId;
    final now = DateTime.now();
    final today = "${now.year}-${now.month}-${now.day}";

    try {
      // 1. Get the player record first to get the correct player_id
      final playerResponse = await _supabase
          .from('players')
          .select('id')
          .eq('user_id', userId)
          .single();
      
      final String playerId = playerResponse['id'];

      // 2. Fetch today's quests
      final response = await _supabase
          .from('daily_quests')
          .select()
          .eq('player_id', playerId)
          .eq('date', today);

      if (response.isEmpty) {
        // 3. If no quests for today, initialize them
        await _initializeDailyQuests(playerId, today);
      } else {
        // 4. Map the DB response to our DailyQuest model
        state = response.map<DailyQuest>((q) {
          return DailyQuest(
            id: q['quest_id'],
            title: q['title'],
            baseReps: 100, // You can make this dynamic based on level if you want
            currentReps: q['current_reps'],
            isCompleted: q['is_completed'],
            targetDayOfWeek: now.weekday,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Error fetching quests: $e');
    }
  }

  Future<void> _initializeDailyQuests(String playerId, String date) async {
    final questsToCreate = [
      {'player_id': playerId, 'quest_id': 'pushups', 'title': 'Push-ups', 'date': date},
      {'player_id': playerId, 'quest_id': 'situps', 'title': 'Sit-ups', 'date': date},
      {'player_id': playerId, 'quest_id': 'squats', 'title': 'Squats', 'date': date},
      {'player_id': playerId, 'quest_id': 'run', 'title': 'Running', 'date': date},
    ];

    try {
      await _supabase.from('daily_quests').insert(questsToCreate);
      await fetchQuests(_userId!); // Re-fetch after insert
    } catch (e) {
      debugPrint('Error initializing quests: $e');
    }
  }

  void updateReps(String id, int amount) async {
    if (_userId == null) return;
    
    final player = ref.read(playerProvider);
    final level = player.level;

    final quest = state.firstWhere((q) => q.id == id);
    final target = quest.getActualReps(level);
    final newReps = (quest.currentReps + amount).clamp(0, target);
    final isCompleted = newReps >= target;

    // Local update for instant UI feedback
    state = [
      for (final q in state)
        if (q.id == id)
          q.copyWith(currentReps: newReps, isCompleted: isCompleted)
        else
          q,
    ];

    // Remote update to Supabase
    try {
      final now = DateTime.now();
      final today = "${now.year}-${now.month}-${now.day}";
      
      await _supabase
          .from('daily_quests')
          .update({'current_reps': newReps, 'is_completed': isCompleted})
          .eq('quest_id', id)
          .eq('date', today);
          
      _checkAllDone();
    } catch (e) {
      debugPrint('Error updating reps: $e');
    }
  }

  Future<void> _checkAllDone() async {
    final allDone = state.isNotEmpty && state.every((q) => q.isCompleted);
    if (allDone) {
      // Add logic here to reward EXP/HP via the PlayerProvider
      // similar to the original logic but potentially syncing with Supabase
    }
  }
}

final questProvider = NotifierProvider<QuestNotifier, List<DailyQuest>>(() {
  return QuestNotifier();
});
