import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:solo_levelling_app/features/player/player.dart';
import 'package:solo_levelling_app/features/player/player_rank.dart';
import 'package:solo_levelling_app/features/player/player_service.dart';
import 'package:solo_levelling_app/core/logic/system_logic.dart';

class PlayerNotifier extends StateNotifier<Player> {
  final PlayerService _playerService = PlayerService();
  final Ref ref;

  PlayerNotifier(this.ref)
      : super(Player(
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

  Timer? _saveTimer;

  @override
  set state(Player value) {
    super.state = value;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 1), () {
      _saveLocalState();
    });
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }

  /// Synchronize player state from Supabase
  Future<void> fetchFromSupabase() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      state = state.copyWith(isLoaded: true);
      return;
    }

    final response = await _playerService.getPlayerProfile(user.id);
    if (response.success && response.data != null) {
      state = response.data!.copyWith(isLoaded: true);
    } else if (response.error == 'PLAYER_NOT_FOUND') {
      // Initialize new player if not found
      debugPrint('Player not found in System. Initializing Arise Protocol...');
      final initResponse = await _playerService.initializePlayer(user.id);
      if (initResponse.success && initResponse.data != null) {
        state = initResponse.data!.copyWith(isLoaded: true);
      } else {
        debugPrint('Error initializing player: ${initResponse.error}');
        state = state.copyWith(
            isLoaded: true); // Prevent lockout on initialization error
      }
    } else {
      debugPrint('Error fetching player from Supabase: ${response.error}');
      state = state.copyWith(isLoaded: true); // Prevent lockout on fetch error
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
      isLoaded: false,
    );
  }

  /// Checks if a penalty should be applied based on missed scheduled days.
  /// Returns the amount of damage taken, or 0 if no penalty.
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

    // Calculate missed scheduled days since lastCheck (excluding today)
    int missedCount = 0;
    DateTime checkDate =
        DateTime(lastCheck.year, lastCheck.month, lastCheck.day)
            .add(const Duration(days: 1));
    final today = DateTime(now.year, now.month, now.day);

    while (checkDate.isBefore(today)) {
      if (scheduledDays.contains(checkDate.weekday)) {
        missedCount++;
      }
      checkDate = checkDate.add(const Duration(days: 1));
    }

    if (missedCount > 0) {
      // 100 HP Vitality System: -33% per missed day as per PRD
      final damage = missedCount * 33;
      final newHp = (state.currentHp - damage).clamp(0, state.maxHp);
      final newConsecutiveMissed = state.consecutiveMissedDays + missedCount;

      state = state.copyWith(
        currentHp: newHp,
        consecutiveMissedDays: newConsecutiveMissed,
        lastPenaltyCheck: now,
        trialStatus: TrialStatus.penalty, // Enter locked state
      );

      // System Voice Alert removed

      // Check for death / demotion protocol (3 missed days = 99 or 100 damage)
      if (newHp == 0 || newConsecutiveMissed >= 3) {
        _triggerDemotionProtocol();
      }

      // Sync to Supabase
      _playerService.updateHp(state.id, state.currentHp);

      return damage;
    }

    state = state.copyWith(lastPenaltyCheck: now);
    return 0;
  }

  void _triggerDemotionProtocol() {
    // 1. Demote to the max level of the PREVIOUS rank (The Rank Floor)
    final previousRankIndex = (PlayerRank.values.indexOf(state.rank) - 1)
        .clamp(0, PlayerRank.values.length - 1);
    final previousRank = PlayerRank.values[previousRankIndex];
    final floorLevel = previousRank.rankFloorLevel;

    state = state.copyWith(
      rank: previousRank,
      level: floorLevel,
      currentExp: 0,
      currentHp: 100, // Reset HP after demotion
      consecutiveMissedDays: 0, // Reset streak
      trialStatus: TrialStatus.idle, // Clear penalty state on demotion
    );

    debugPrint(
        'DEMOTION PROTOCOL: Rank downgraded to ${previousRank.rankLabel}');
    // Sync with Supabase
    _playerService.applyPenalty(state);
  }

  /// Clears the penalty state and refills HP as per PRD.
  void clearPenalty() {
    state = state.copyWith(
      currentHp: 100,
      consecutiveMissedDays: 0,
      trialStatus: TrialStatus.idle,
    );
    _playerService.updateHp(state.id, 100);
  }

  void completeTrial() {
    final newLevel = state.level + 1;
    final nextRank = _determineRankFromLevel(newLevel);

    state = state.copyWith(
      rank: nextRank,
      level: newLevel,
      currentExp: 0,
      maxExp: (state.maxExp * 1.5).toInt(), // Scale difficulty for next rank
      currentHp: (state.trialStatus == TrialStatus.failed)
          ? 30
          : state.maxHp, // Revival: 30 HP
      trialStatus: TrialStatus.idle,
    );
  }

  void startTrial() {
    state = state.copyWith(trialStatus: TrialStatus.active);
  }

  void failTrial() {
    // PRD: 50% HP loss on failure
    final damage = (state.maxHp * 0.5).round();
    final newHp = (state.currentHp - damage).clamp(0, state.maxHp);

    state = state.copyWith(
      currentHp: newHp,
      trialStatus: TrialStatus.failed,
    );

    // Sync to Supabase
    _playerService.updateHp(state.id, newHp);
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
    // Optimistic UI update
    int newExp = state.currentExp + amount;
    int newTotalExp = state.totalExp + amount;
    int newLevel = state.level;
    int newMaxExp = state.maxExp;
    PlayerRank newRank = state.rank;

    // Simulate level ups locally while waiting for backend
    while (newExp >= newMaxExp && newLevel < 100) {
      newExp -= newMaxExp;
      newLevel++;
      newMaxExp = SystemLogic.xpToNextLevel(newLevel);
      newRank = _determineRankFromLevel(newLevel);
    }

    state = state.copyWith(
      currentExp: newExp,
      maxExp: newMaxExp,
      totalExp: newTotalExp,
      level: newLevel,
      rank: newRank,
    );

    final response = await _playerService.addExperience(playerId, amount);

    if (response.success && response.data != null) {
      final newState = response.data!;
      state = newState;
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
  return PlayerNotifier(ref);
});
