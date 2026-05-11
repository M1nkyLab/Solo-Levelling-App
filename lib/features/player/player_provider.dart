import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:solo_levelling_app/features/player/player.dart';
import 'package:solo_levelling_app/features/player/player_rank.dart';
import 'package:solo_levelling_app/features/player/player_service.dart';

class PlayerNotifier extends StateNotifier<Player> {
  final PlayerService _playerService = PlayerService();

  PlayerNotifier() : super(Player(
    id: '',
    userId: '',
    level: 1,
    rank: PlayerRank.E,
    currentExp: 0,
    maxExp: 100,
    currentHp: 100,
    maxHp: 100,
    strength: 10,
    agility: 10,
    vitality: 10,
    intelligence: 10,
    sense: 10,
    availableStatPoints: 0,
    lastPenaltyCheck: null,
  )) {
    _loadLocalState();
  }

  static const String _playerKey = 'player_state';

  Future<void> _loadLocalState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_playerKey);
    if (jsonString != null) {
      try {
        state = Player.fromJson(json.decode(jsonString));
      } catch (e) {
        debugPrint('Error loading player state: $e');
      }
    }
  }

  Future<void> _saveLocalState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playerKey, json.encode(state.toJson()));
  }

  @override
  set state(Player value) {
    super.state = value;
    _saveLocalState();
  }

  /// Synchronize player state from Supabase
  Future<void> fetchFromSupabase() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await _playerService.getPlayerProfile(user.id);
    if (response.success && response.data != null) {
      state = response.data!;
    } else if (response.error == 'PLAYER_NOT_FOUND') {
      // Initialize new player if not found
      debugPrint('Player not found in System. Initializing Arise Protocol...');
      final initResponse = await _playerService.initializePlayer(user.id);
      if (initResponse.success && initResponse.data != null) {
        state = initResponse.data!;
      } else {
        debugPrint('Error initializing player: ${initResponse.error}');
      }
    } else {
      debugPrint('Error fetching player from Supabase: ${response.error}');
    }
  }

  /// Resets the player state to defaults (used on logout)
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playerKey);
    state = Player(
      id: '',
      userId: '',
      level: 1,
      rank: PlayerRank.E,
      currentExp: 0,
      maxExp: 100,
      currentHp: 100,
      maxHp: 100,
      strength: 10,
      agility: 10,
      vitality: 10,
      intelligence: 10,
      sense: 10,
      availableStatPoints: 0,
      lastPenaltyCheck: null,
    );
  }

  /// Checks if a penalty should be applied based on missed scheduled days.
  /// Returns the amount of EXP lost, or 0 if no penalty.
  int checkSchedulePenalty(List<int> scheduledDays) {
    if (state.lastPenaltyCheck == null) {
      state = state.copyWith(lastPenaltyCheck: DateTime.now());
      return 0;
    }

    final now = DateTime.now();
    final lastCheck = state.lastPenaltyCheck!;
    
    // Check if we already checked today
    final isAlreadyChecked = lastCheck.year == now.year && 
                            lastCheck.month == now.month && 
                            lastCheck.day == now.day;

    if (isAlreadyChecked) return 0;

    // For this prototype, we check if "Yesterday" was a scheduled day
    // and if the user skipped it.
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterdayScheduled = scheduledDays.contains(yesterday.weekday);

    if (isYesterdayScheduled) {
      // 100 HP Vitality System: Apply rank-based damage
      final damage = state.rank.hpLossOnMiss;
      final newHp = (state.currentHp - damage).clamp(0, state.maxHp);
      
      state = state.copyWith(
        currentHp: newHp,
        lastPenaltyCheck: now,
      );

      // Check for death / demotion protocol
      if (newHp == 0) {
        _triggerDemotionProtocol();
      }

      return damage;
    }

    state = state.copyWith(lastPenaltyCheck: now);
    return 0;
  }

  void _triggerDemotionProtocol() {
    // 1. Demote to the max level of the PREVIOUS rank (The Rank Floor)
    final floorLevel = state.rank.rankFloorLevel;
    final previousRankIndex = (PlayerRank.values.indexOf(state.rank) - 1).clamp(0, PlayerRank.values.length - 1);
    final previousRank = PlayerRank.values[previousRankIndex];

    state = state.copyWith(
      rank: previousRank,
      level: floorLevel,
      currentExp: 0,
      trialStatus: TrialStatus.penalty, // Mark as penalty state
    );
    
    debugPrint('DEMOTION PROTOCOL: Rank downgraded to ${previousRank.rankLabel}');
    // Sync with Supabase
    _playerService.applyPenalty(state);
  }

  void completeTrial() {
    final newLevel = state.level + 1;
    final nextRank = _determineRankFromLevel(newLevel);

    state = state.copyWith(
      rank: nextRank,
      level: newLevel,
      currentExp: 0,
      maxExp: (state.maxExp * 1.5).toInt(), // Scale difficulty for next rank
      currentHp: (state.trialStatus == TrialStatus.failed) ? 30 : state.maxHp, // Revival: 30 HP
      trialStatus: TrialStatus.idle,
    );
  }

  void startTrial() {
    state = state.copyWith(trialStatus: TrialStatus.active);
  }

  void failTrial() {
    state = state.copyWith(trialStatus: TrialStatus.failed);
  }

  void resetTrial() {
    state = state.copyWith(trialStatus: TrialStatus.idle);
  }

  /// Adds XP via Supabase. Resolves player_id from userId if id is empty.
  Future<void> addXp(int amount) async {
    // If state.id is empty (player not yet fetched from DB), resolve it first
    String playerId = state.id;
    if (playerId.isEmpty) {
      await fetchFromSupabase();
      playerId = state.id;
    }
    if (playerId.isEmpty) {
      debugPrint('addXp: Cannot award XP — player ID still unknown.');
      return;
    }

    final response = await _playerService.addExperience(playerId, amount);

    if (response.success && response.data != null) {
      state = response.data!;
    } else {
      debugPrint('Error adding XP to Supabase: ${response.error}');
    }
  }

  /// Heals HP after completing the daily quest, based on rank vitality reward.
  Future<void> healOnQuestComplete() async {
    final healAmount = state.rank.hpGainOnCompletion;
    final newHp = (state.currentHp + healAmount).clamp(0, state.maxHp);
    if (newHp == state.currentHp) return; // already full

    // Optimistic local update
    state = state.copyWith(currentHp: newHp);

    // Sync to Supabase
    String playerId = state.id;
    if (playerId.isEmpty) return;
    try {
      await _playerService.updateHp(playerId, newHp);
    } catch (e) {
      debugPrint('healOnQuestComplete: Supabase sync failed: $e');
    }
  }

  /// Executes penalty via Supabase.
  Future<void> executePenalty() async {
    final response = await _playerService.applyPenalty(state);

    if (response.success && response.data != null) {
      state = response.data!;
    } else {
      debugPrint('Error applying penalty to Supabase: ${response.error}');
    }
  }

  PlayerRank _determineRankFromLevel(int level) {
    if (level >= 91) return PlayerRank.S;
    if (level >= 71) return PlayerRank.A;
    if (level >= 46) return PlayerRank.B;
    if (level >= 26) return PlayerRank.C;
    if (level >= 11) return PlayerRank.D;
    return PlayerRank.E;
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, Player>((ref) {
  return PlayerNotifier();
});
