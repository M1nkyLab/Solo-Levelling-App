enum PlayerRank { E, D, C, B, A, S }

extension PlayerRankExtension on PlayerRank {
  // The system's difficulty multiplier
  double get repMultiplier {
    switch (this) {
      case PlayerRank.E:
        return 1.0; // Baseline
      case PlayerRank.D:
        return 1.2; // 20% increase
      case PlayerRank.C:
        return 1.5; // 50% increase
      case PlayerRank.B:
        return 2.0; // Double reps
      case PlayerRank.A:
        return 2.5;
      case PlayerRank.S:
        return 3.0; // Triple reps for the highest rank
    }
  }

  // Helper to display the rank cleanly in your UI
  String get displayName {
    return toString().split('.').last;
  }
}
