import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:solo_levelling_app/core/models/workout_state.dart';
import 'package:solo_levelling_app/features/quests/daily_quest.dart';

final syncServiceProvider = Provider((ref) => SyncService(ref));

class SyncService {
  final Ref ref;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  SyncService(this.ref) {
    _init();
    ref.onDispose(dispose);
  }

  void _init() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        _processGhostSync();
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }

  /// Called when a quest completes locally. Saves to Hive and triggers sync if online.
  Future<void> markQuestCompleted(DailyQuest quest) async {
    final box = Hive.box<DailyQuest>('questsBox');
    
    // Update local state to pending sync
    final pendingQuest = quest.copyWith(state: WorkoutState.completedPendingSync);
    await box.put(pendingQuest.id, pendingQuest);
    
    final result = await _connectivity.checkConnectivity();
    if (result.any((r) => r != ConnectivityResult.none)) {
      _processGhostSync();
    }
  }

  Future<void> _processGhostSync() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final box = Hive.box<DailyQuest>('questsBox');
    final pendingQuests = box.values
        .where((q) => q.state == WorkoutState.completedPendingSync)
        .toList();

    if (pendingQuests.isEmpty) return;

    debugPrint('SyncService: Processing ${pendingQuests.length} ghost syncs...');

    final targetDate = DateTime.now();
    final dateStr = "${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";

    for (final quest in pendingQuests) {
      try {
        // Attempt to push to Supabase
        // Get player id
        final playerResponse = await Supabase.instance.client
            .from('players')
            .select('id')
            .eq('user_id', user.id)
            .maybeSingle();

        if (playerResponse == null) continue;
        final String playerId = playerResponse['id'];

        await Supabase.instance.client
            .from('daily_quests')
            .update({
              'current_reps': quest.getActualReps(1), // Assume maxed out or current reps
              'is_completed': true,
            })
            .eq('player_id', playerId)
            .eq('quest_id', quest.id)
            .eq('date', dateStr);

        // Update local state to synced
        final syncedQuest = quest.copyWith(state: WorkoutState.synced, isCompleted: true);
        await box.put(quest.id, syncedQuest);
      } catch (e) {
        debugPrint('Ghost sync failed for quest ${quest.id}: $e');
        // It stays in completedPendingSync state and will retry later
      }
    }
  }
}
