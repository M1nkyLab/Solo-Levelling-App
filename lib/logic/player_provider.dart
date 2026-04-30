import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../models/player_rank.dart';
import 'system_logic.dart';

class PlayerNotifier extends StateNotifier<Player> {
  PlayerNotifier() : super(Player(
    level: 9,
    rank: PlayerRank.E,
    currentExp: 340,
    maxExp: 480,
    currentHp: 80,
    maxHp: 100,
  ));

  void addXp(int amount) {
    int newExp = state.currentExp + amount;
    int newLevel = state.level;
    int newMaxXp = state.maxExp;
    int newMaxHp = state.maxHp;
    int newCurrentHp = state.currentHp;

    while (newExp >= newMaxXp) {
      newExp -= newMaxXp;
      newLevel++;
      newMaxXp = SystemLogic.xpToNextLevel(newLevel);
      // Scaling stats on level up
      newMaxHp = SystemLogic.calculateMaxHp(vitality: newLevel);
      newCurrentHp = newMaxHp;
    }

    // Determine rank based on level
    final newRank = _determineRankFromLevel(newLevel);

    state = state.copyWith(
      level: newLevel,
      currentExp: newExp,
      maxExp: newMaxXp,
      currentHp: newCurrentHp,
      maxHp: newMaxHp,
      rank: newRank,
    );
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
