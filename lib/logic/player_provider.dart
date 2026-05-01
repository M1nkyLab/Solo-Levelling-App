import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../models/player_rank.dart';
import '../services/player_service.dart';

class PlayerNotifier extends StateNotifier<Player> {
  final PlayerService _playerService = PlayerService();

  PlayerNotifier() : super(Player(
    level: 9,
    rank: PlayerRank.E,
    currentExp: 340,
    maxExp: 480,
    currentHp: 80,
    maxHp: 100,
  ));

  /// Adds XP by calling the "API endpoint" in PlayerService.
  /// Demonstrates consistent response handling.
  Future<void> addXp(int amount) async {
    final response = await _playerService.addExperience(state, amount);

    if (response.success && response.data != null) {
      // 1. Success path: update state with new data
      state = response.data!;
      
      // Determine rank based on level (UI specific logic)
      final newRank = _determineRankFromLevel(state.level);
      state = state.copyWith(rank: newRank);
    } else {
      // 2. Error path: handle error (e.g., log it, or show a notification)
      // In a real app, you might have an 'errorProvider' or use a SnackBar
      debugPrint('API Error adding XP: ${response.error}');
    }
  }

  /// Executes penalty via PlayerService.
  Future<void> executePenalty() async {
    final response = await _playerService.applyPenalty(state);

    if (response.success && response.data != null) {
      state = response.data!;
    } else {
      debugPrint('API Error applying penalty: ${response.error}');
    }
  }

  PlayerRank _determineRankFromLevel(int level) {
    if (level >= 80) return PlayerRank.S;
    if (level >= 60) return PlayerRank.A;
    if (level >= 40) return PlayerRank.B;
    if (level >= 20) return PlayerRank.C;
    if (level >= 10) return PlayerRank.D;
    return PlayerRank.E;
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, Player>((ref) {
  return PlayerNotifier();
});
