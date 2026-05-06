import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:solo_levelling_app/features/quests/daily_quest.dart';

class QuestService {
  final _supabase = Supabase.instance.client;

  Future<List<DailyQuest>> getDailyQuests(String userId) async {
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
        return await _initializeDailyQuests(playerId, today, now.weekday);
      } else {
        // 4. Map the DB response to our DailyQuest model
        return response.map<DailyQuest>((q) {
          return DailyQuest(
            id: q['quest_id'],
            title: q['title'],
            baseReps: 100, // This is a placeholder, actual reps calculated via SystemLogic
            currentReps: q['current_reps'],
            isCompleted: q['is_completed'],
            targetDayOfWeek: now.weekday,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Error fetching quests in QuestService: $e');
      rethrow;
    }
  }

  Future<List<DailyQuest>> _initializeDailyQuests(String playerId, String date, int weekday) async {
    final questsToCreate = [
      {'player_id': playerId, 'quest_id': 'pushups', 'title': 'Push-ups', 'date': date},
      {'player_id': playerId, 'quest_id': 'situps', 'title': 'Sit-ups', 'date': date},
      {'player_id': playerId, 'quest_id': 'squats', 'title': 'Squats', 'date': date},
      {'player_id': playerId, 'quest_id': 'run', 'title': 'Running', 'date': date},
    ];

    try {
      final response = await _supabase
          .from('daily_quests')
          .insert(questsToCreate)
          .select();
          
      return response.map<DailyQuest>((q) {
        return DailyQuest(
          id: q['quest_id'],
          title: q['title'],
          baseReps: 100,
          currentReps: q['current_reps'],
          isCompleted: q['is_completed'],
          targetDayOfWeek: weekday,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error initializing quests in QuestService: $e');
      rethrow;
    }
  }

  Future<void> updateQuestProgress(String userId, String questId, int currentReps, bool isCompleted) async {
    final now = DateTime.now();
    final today = "${now.year}-${now.month}-${now.day}";

    try {
      // Get playerId
      final playerResponse = await _supabase
          .from('players')
          .select('id')
          .eq('user_id', userId)
          .single();
      
      final String playerId = playerResponse['id'];

      await _supabase
          .from('daily_quests')
          .update({
            'current_reps': currentReps,
            'is_completed': isCompleted,
          })
          .eq('player_id', playerId)
          .eq('quest_id', questId)
          .eq('date', today);
    } catch (e) {
      debugPrint('Error updating quest progress in QuestService: $e');
      rethrow;
    }
  }
}
