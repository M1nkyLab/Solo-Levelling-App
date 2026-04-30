import 'player_rank.dart';

class Player {
  final int level;
  final PlayerRank rank;
  final int currentExp;
  final int maxExp;

  Player({
    this.level = 1,
    this.rank = PlayerRank.E,
    this.currentExp = 0,
    this.maxExp = 100, // Default EXP needed for Level 2
  });

  // copyWith allows us to update specific fields easily without mutating the original object
  Player copyWith({
    int? level,
    PlayerRank? rank,
    int? currentExp,
    int? maxExp,
  }) {
    return Player(
      level: level ?? this.level,
      rank: rank ?? this.rank,
      currentExp: currentExp ?? this.currentExp,
      maxExp: maxExp ?? this.maxExp,
    );
  }
}
