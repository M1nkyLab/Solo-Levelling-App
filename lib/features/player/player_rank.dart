enum PlayerRank { E, D, C, B, A, S }

extension PlayerRankExtension on PlayerRank {
  // HP Vitality System values
  int get hpLossOnMiss {
    switch (this) {
      case PlayerRank.E: return 15;
      case PlayerRank.D: return 20;
      case PlayerRank.C: return 25;
      case PlayerRank.B: return 30;
      case PlayerRank.A: return 40;
      case PlayerRank.S: return 50;
    }
  }

  int get hpGainOnCompletion {
    switch (this) {
      case PlayerRank.E: return 20;
      case PlayerRank.D: return 15;
      case PlayerRank.C: return 15;
      case PlayerRank.B: return 10;
      case PlayerRank.A: return 10;
      case PlayerRank.S: return 5;
    }
  }

  // The floor level after rank demotion
  int get rankFloorLevel {
    switch (this) {
      case PlayerRank.E: return 1;
      case PlayerRank.D: return 10;
      case PlayerRank.C: return 25;
      case PlayerRank.B: return 45;
      case PlayerRank.A: return 70;
      case PlayerRank.S: return 90;
    }
  }

  // Rank name display
  String get rankLabel => '${toString().split('.').last}-Class';

  // The level range [min, max] for DAILY WORKOUTS.
  ({int min, int max}) get levelRange {
    switch (this) {
      case PlayerRank.E: return (min: 1, max: 9);
      case PlayerRank.D: return (min: 11, max: 24);
      case PlayerRank.C: return (min: 26, max: 44);
      case PlayerRank.B: return (min: 46, max: 69);
      case PlayerRank.A: return (min: 71, max: 89);
      case PlayerRank.S: return (min: 91, max: 100);
    }
  }

  // The level at which the Rank-Up Trial is triggered.
  int? get capstoneLevel {
    switch (this) {
      case PlayerRank.E: return 10;
      case PlayerRank.D: return 25;
      case PlayerRank.C: return 45;
      case PlayerRank.B: return 70;
      case PlayerRank.A: return 90;
      case PlayerRank.S: return null;
    }
  }

  // Trial requirements to ASCEND from this rank to the next
  ({int pushups, int situps, int squats, double running})? get trialRequirements {
    switch (this) {
      case PlayerRank.E:
        return (pushups: 30, situps: 40, squats: 40, running: 3.0);
      case PlayerRank.D:
        return (pushups: 50, situps: 60, squats: 60, running: 5.0);
      case PlayerRank.C:
        return (pushups: 75, situps: 80, squats: 80, running: 7.5);
      case PlayerRank.B:
        return (pushups: 90, situps: 95, squats: 95, running: 9.0);
      case PlayerRank.A:
        return (pushups: 100, situps: 100, squats: 100, running: 10.0);
      case PlayerRank.S:
        return null;
    }
  }

  // System Messages for Rank Advancement
  String get rankUpTitle {
    switch (this) {
      case PlayerRank.E: return 'Novice Trial: CLEARED';
      case PlayerRank.D: return 'Iron Trial: CLEARED';
      case PlayerRank.C: return 'The Wall Trial: CLEARED';
      case PlayerRank.B: return 'Elite Trial: CLEARED';
      case PlayerRank.A: return 'S-Class Evaluation: CLEARED';
      case PlayerRank.S: return 'Absolute Mastery';
    }
  }

  String get rankUpMessage {
    switch (this) {
      case PlayerRank.E: return 'Your muscles have adapted to the awakening. You are no longer at the bottom.';
      case PlayerRank.D: return 'The System acknowledges your steel endurance. Your physical limits are expanding.';
      case PlayerRank.C: return 'Most give up here. You broke through the wall. The System is impressed by your discipline.';
      case PlayerRank.B: return 'Weakness has left your body. Only the elite reach this realm.';
      case PlayerRank.A: return 'Flawless execution. You have achieved absolute mastery over your physical vessel.';
      case PlayerRank.S: return 'You have become the Hunter.';
    }
  }

  String get nextRankHint {
    switch (this) {
      case PlayerRank.E: return 'Keep pushing the limit.';
      case PlayerRank.D: return 'The real workout begins now.';
      case PlayerRank.C: return 'You are now entering advanced territory.';
      case PlayerRank.B: return 'Prepare for the final evaluation.';
      case PlayerRank.A: return 'You have become the Hunter.';
      case PlayerRank.S: return 'Peak status maintained.';
    }
  }

  // Helper to display the rank cleanly in your UI
  String get displayName => toString().split('.').last;
}
