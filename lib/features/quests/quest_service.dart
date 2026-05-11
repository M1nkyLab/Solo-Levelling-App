import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:solo_levelling_app/features/quests/daily_quest.dart';

class QuestService {
  final _supabase = Supabase.instance.client;

  Future<List<DailyQuest>> getDailyQuests(String userId, {DateTime? date, List<int>? localSchedule}) async {
    final targetDate = date ?? DateTime.now();
    final String dateStr = "${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";
    final int weekday = targetDate.weekday;

    try {
      debugPrint('QuestService: [DIAGNOSTIC] userId: $userId, date: $dateStr, weekday: $weekday');

      // 1. Get Player ID with extreme caution
      var playerResponse = await _supabase
          .from('players')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (playerResponse == null) {
        debugPrint('QuestService: [REPAIR] Player not found. Attempting emergency initialization...');
        try {
          final initRes = await _supabase.from('players').insert({'user_id': userId}).select('id').single();
          playerResponse = initRes;
        } catch (e) {
          debugPrint('QuestService: [ARISE ERROR] Could not initialize player in DB: $e');
        }
      }

      final String? playerId = playerResponse?['id'];
      debugPrint('QuestService: [DIAGNOSTIC] Resolved playerId: $playerId');

      // 2. Fetch Schedule and Quests
      Map<String, dynamic>? scheduleResponse;
      List<dynamic> questsResponse = [];
      
      if (playerId != null) {
        final results = await Future.wait<dynamic>([
          _supabase.from('workout_schedules').select('days_of_week').eq('player_id', playerId).maybeSingle(),
          _supabase.from('daily_quests').select('quest_id, title, current_reps, is_completed').eq('player_id', playerId).eq('date', dateStr)
        ]);
        scheduleResponse = results[0] as Map<String, dynamic>?;
        questsResponse = results[1] as List<dynamic>;
      }
      
      // 3. Resolve Schedule
      List<int> scheduledDays;
      if (localSchedule != null && localSchedule.isNotEmpty) {
        scheduledDays = localSchedule;
      } else if (scheduleResponse != null) {
        List<dynamic> rawDays = scheduleResponse['days_of_week'] ?? [];
        scheduledDays = rawDays.map((e) => e as int).toList();
      } else {
        scheduledDays = [1, 3, 5];
      }

      // 4. Return existing quests if found
      if (questsResponse.isNotEmpty) {
        debugPrint('QuestService: Found ${questsResponse.length} existing quests.');
        return questsResponse.map<DailyQuest>((q) => DailyQuest(
          id: q['quest_id'],
          title: q['title'],
          baseReps: 20,
          currentReps: q['current_reps'] ?? 0,
          isCompleted: q['is_completed'] ?? false,
          targetDayOfWeek: weekday,
        )).toList();
      }

      // 5. Initialize if Scheduled or Forced
      final bool isScheduled = scheduledDays.contains(weekday);
      final bool isForced = localSchedule != null && localSchedule.contains(weekday);

      if (isScheduled || isForced) {
        debugPrint('QuestService: [ARISE] Triggering initialization. Scheduled: $isScheduled, Forced: $isForced');
        
        if (playerId != null) {
          try {
            final quests = await _initializeDailyQuests(playerId, dateStr, weekday);
            if (quests.isNotEmpty) {
              debugPrint('QuestService: [ARISE] Successfully initialized ${quests.length} quests in DB.');
              return quests;
            }
          } catch (e) {
            debugPrint('QuestService: [ARISE ERROR] Initialization failed: $e. Falling back to local.');
          }
        } else {
          debugPrint('QuestService: [ARISE] PlayerID is null. Cannot initialize in DB. Using local fallback.');
        }

        // --- ARISE PROTOCOL: LOCAL FALLBACK ---
        debugPrint('QuestService: [ARISE PROTOCOL] DB flow failed or empty. Generating local fallback protocols.');
        return [
          DailyQuest(id: 'pushups', title: 'Push-ups', baseReps: 20, targetDayOfWeek: weekday),
          DailyQuest(id: 'situps', title: 'Sit-ups', baseReps: 20, targetDayOfWeek: weekday),
          DailyQuest(id: 'squats', title: 'Squats', baseReps: 20, targetDayOfWeek: weekday),
          DailyQuest(id: 'run', title: 'Running', baseReps: 20, targetDayOfWeek: weekday),
        ];
      }

      debugPrint('QuestService: [INFO] Weekday $weekday not in schedule $scheduledDays. Rest Day.');
      return [];
    } catch (e, stack) {
      debugPrint('QuestService: [CRITICAL ERROR] $e');
      debugPrint('QuestService: StackTrace: $stack');
      
      // Even on total crash, if we have a local schedule hint, try to return fallback
      if (localSchedule != null && localSchedule.contains(weekday)) {
        debugPrint('QuestService: [EMERGENCY FALLBACK] Total crash recovery triggered.');
        return [
          DailyQuest(id: 'pushups', title: 'Push-ups', baseReps: 20, targetDayOfWeek: weekday),
          DailyQuest(id: 'situps', title: 'Sit-ups', baseReps: 20, targetDayOfWeek: weekday),
          DailyQuest(id: 'squats', title: 'Squats', baseReps: 20, targetDayOfWeek: weekday),
          DailyQuest(id: 'run', title: 'Running', baseReps: 20, targetDayOfWeek: weekday),
        ];
      }
      return [];
    }
  }

  Future<List<DailyQuest>> _initializeDailyQuests(String playerId, String date, int weekday) async {
    final questsToCreate = [
      {'player_id': playerId, 'quest_id': 'pushups', 'title': 'Push-ups', 'date': date, 'current_reps': 0, 'is_completed': false},
      {'player_id': playerId, 'quest_id': 'situps', 'title': 'Sit-ups', 'date': date, 'current_reps': 0, 'is_completed': false},
      {'player_id': playerId, 'quest_id': 'squats', 'title': 'Squats', 'date': date, 'current_reps': 0, 'is_completed': false},
      {'player_id': playerId, 'quest_id': 'run', 'title': 'Running', 'date': date, 'current_reps': 0, 'is_completed': false},
    ];

    try {
      debugPrint('QuestService: Upserting quests for playerId: $playerId, date: $date');
      debugPrint('QuestService: Payload: $questsToCreate');
      
      final response = await _supabase
          .from('daily_quests')
          .upsert(
            questsToCreate, 
            onConflict: 'player_id, quest_id, date'
          )
          .select('quest_id, title, current_reps, is_completed');
      
      if (response.isEmpty) {
        debugPrint('QuestService: Upsert returned empty response. Retrying fetch...');
        return await _fetchQuestsOnly(playerId, date, weekday);
      }
      
      debugPrint('QuestService: Successfully initialized ${response.length} quests via upsert.');
          
      return response.map<DailyQuest>((q) {
        return DailyQuest(
          id: q['quest_id'],
          title: q['title'],
          baseReps: 20,
          currentReps: q['current_reps'] ?? 0,
          isCompleted: q['is_completed'] ?? false,
          targetDayOfWeek: weekday,
        );
      }).toList();
    } catch (e, stack) {
      debugPrint('QuestService: Error during quest initialization (upsert): $e');
      debugPrint('QuestService: StackTrace: $stack');
      // Final fallback
      return await _fetchQuestsOnly(playerId, date, weekday);
    }
  }

  Future<List<DailyQuest>> _fetchQuestsOnly(String playerId, String date, int weekday) async {
    final response = await _supabase
        .from('daily_quests')
        .select('quest_id, title, current_reps, is_completed')
        .eq('player_id', playerId)
        .eq('date', date);
        
    return response.map<DailyQuest>((q) {
      return DailyQuest(
        id: q['quest_id'],
        title: q['title'],
        baseReps: 20,
        currentReps: q['current_reps'] ?? 0,
        isCompleted: q['is_completed'] ?? false,
        targetDayOfWeek: weekday,
      );
    }).toList();
  }

  Future<void> updateQuestProgress(String userId, String questId, int currentReps, bool isCompleted, {DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final dateStr = "${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";

    try {
      // Get playerId
      final playerResponse = await _supabase
          .from('players')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();
      
      if (playerResponse == null) return;
      final String playerId = playerResponse['id'];

      await _supabase
          .from('daily_quests')
          .update({
            'current_reps': currentReps,
            'is_completed': isCompleted,
          })
          .eq('player_id', playerId)
          .eq('quest_id', questId)
          .eq('date', dateStr);
    } catch (e) {
      debugPrint('Error updating quest progress in QuestService: $e');
      rethrow;
    }
  }
}
