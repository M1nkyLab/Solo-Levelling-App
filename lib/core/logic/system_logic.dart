import 'package:solo_levelling_app/features/player/player_rank.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Rank definitions (kept in one place so the thresholds never drift)
// ─────────────────────────────────────────────────────────────────────────────

/// All possible Hunter ranks in ascending order of power.
/// Now mapped to PlayerRank for consistency.
enum HunterRank {
  eRank,
  dRank,
  cRank,
  bRank,
  aRank,
  sRank;

  /// Human-readable label shown in the UI (e.g. "S-Rank").
  String get label => toPlayerRank().rankLabel;

  /// The inclusive level range [min, max] that defines this rank's daily workouts.
  ({int min, int max}) get levelRange => toPlayerRank().levelRange;

  /// The exact level at which a boss-raid Rank-Up Exam is triggered.
  int? get rankUpExamLevel => toPlayerRank().capstoneLevel;
  
  /// Converts this HunterRank to the corresponding PlayerRank model.
  PlayerRank toPlayerRank() => PlayerRank.values[index];
}

// ─────────────────────────────────────────────────────────────────────────────
//  SystemLogic
// ─────────────────────────────────────────────────────────────────────────────

/// Stateless utility class containing all core RPG scaling rules.
abstract final class SystemLogic {
  // ── HP ───────────────────────────────────────────────────────────────────

  /// Base Max HP is always 100 for this system.
  static const int baseMaxHp = 100;

  static int calculateMaxHp({required int vitality}) {
    return baseMaxHp; // Fixed at 100 for this vitality system
  }

  // ── Rank ─────────────────────────────────────────────────────────────────

  /// Returns the [HunterRank] enum value for the given [totalLevel].
  static HunterRank determineHunterRank(int totalLevel) {
    final int level = totalLevel.clamp(1, 100);

    if (level >= 91) return HunterRank.sRank;
    if (level >= 71) return HunterRank.aRank;
    if (level >= 46) return HunterRank.bRank;
    if (level >= 26) return HunterRank.cRank;
    if (level >= 11) return HunterRank.dRank;
    return HunterRank.eRank;
  }

  static String determineHunterRankLabel(int totalLevel) =>
      determineHunterRank(totalLevel).label;

  // ── Rank-Up Exam ─────────────────────────────────────────────────────────

  static bool isEligibleForRankUp(int totalLevel) {
    final HunterRank currentRank = determineHunterRank(totalLevel);
    final int? examLevel = currentRank.rankUpExamLevel;
    return examLevel != null && totalLevel == examLevel;
  }

  // ── XP ───────────────────────────────────────────────────────────────────

  static int xpToNextLevel(int currentLevel) {
    final int level = currentLevel.clamp(1, 9999);
    return (100 * (level * level * 0.4 + level * 0.6)).round();
  }

  // ── Stat point rewards ───────────────────────────────────────────────────

  static int statPointsForLevel(int newLevel) {
    const int base = 3;
    const int rankUpBonus = 3;
    return isEligibleForRankUp(newLevel) ? base + rankUpBonus : base;
  }
  
  // ── Quest Requirements Scaling ───────────────────────────────────────────

  /// Calculates the required reps/km for a quest based on player level (Rank).
  static int calculateRequirement(String questId, int level) {
    final HunterRank rank = determineHunterRank(level);
    
    // Scale daily requirements strictly based on Hunter Rank
    // E: 20, D: 40, C: 60, B: 80, A: 90, S: 100
    int baseReps;
    switch (rank) {
      case HunterRank.eRank: baseReps = 20; break;
      case HunterRank.dRank: baseReps = 40; break;
      case HunterRank.cRank: baseReps = 60; break;
      case HunterRank.bRank: baseReps = 80; break;
      case HunterRank.aRank: baseReps = 90; break;
      case HunterRank.sRank: baseReps = 100; break;
    }
    
    switch (questId) {
      case 'pushups':
        return baseReps;
      case 'situps':
      case 'squats':
        // Situps and Squats are slightly higher for variety in lower ranks
        return (rank == HunterRank.eRank) ? baseReps + 5 : baseReps;
      case 'run':
        // 2km to 10km scaling
        final double km = baseReps / 10.0;
        return (km * 10).round(); // Stored as decimeters/10th of km
      default:
        return baseReps;
    }
  }

  /// Returns specific trial requirements for the current rank.
  static ({int pushups, int situps, int squats, int running}) getTrialRequirements(PlayerRank rank) {
    final reqs = rank.trialRequirements;
    if (reqs == null) {
      // Fallback for S rank or undefined
      return (pushups: 100, situps: 100, squats: 100, running: 100);
    }
    return (
      pushups: reqs.pushups,
      situps: reqs.situps,
      squats: reqs.squats,
      running: (reqs.running * 10).round(),
    );
  }
}
