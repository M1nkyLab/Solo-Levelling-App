/// system_logic.dart
///
/// Core game-rule engine for the Shadow Monarch fitness app.
///
/// All methods are pure functions (no side-effects, no async) so they can be
/// called freely from UI widgets, Riverpod providers, or Supabase edge
/// functions alike.
///
/// Integration note:
///   Import this wherever you need to compute derived stats from the raw
///   values stored in the `users` / `user_stats` Supabase tables.
///
///   ```dart
///   import 'package:solo_levelling_app/logic/system_logic.dart';
///
///   final maxHp = SystemLogic.calculateMaxHp(vitality: userStats.vitality);
///   final rank  = SystemLogic.determineHunterRank(level);
///   ```

library system_logic;

// ─────────────────────────────────────────────────────────────────────────────
//  Rank definitions (kept in one place so the thresholds never drift)
// ─────────────────────────────────────────────────────────────────────────────

/// All possible Hunter ranks in ascending order of power.
enum HunterRank {
  eRank,
  dRank,
  cRank,
  bRank,
  aRank,
  sRank,
  monarch;

  /// Human-readable label shown in the UI (e.g. "S-Rank", "Monarch").
  String get label {
    switch (this) {
      case HunterRank.eRank:
        return 'E-Rank';
      case HunterRank.dRank:
        return 'D-Rank';
      case HunterRank.cRank:
        return 'C-Rank';
      case HunterRank.bRank:
        return 'B-Rank';
      case HunterRank.aRank:
        return 'A-Rank';
      case HunterRank.sRank:
        return 'S-Rank';
      case HunterRank.monarch:
        return 'Monarch';
    }
  }

  /// The inclusive level range [min, max] that defines this rank.
  /// [max] is `null` for [HunterRank.monarch] (no ceiling).
  ({int min, int? max}) get levelRange {
    switch (this) {
      case HunterRank.eRank:
        return (min: 1, max: 9);
      case HunterRank.dRank:
        return (min: 10, max: 19);
      case HunterRank.cRank:
        return (min: 20, max: 39);
      case HunterRank.bRank:
        return (min: 40, max: 59);
      case HunterRank.aRank:
        return (min: 60, max: 79);
      case HunterRank.sRank:
        return (min: 80, max: 99);
      case HunterRank.monarch:
        return (min: 100, max: null);
    }
  }

  /// The exact level at which a boss-raid Rank-Up Exam is triggered.
  /// Returns `null` for [HunterRank.monarch] (already at the peak).
  int? get rankUpExamLevel => levelRange.max;
}

// ─────────────────────────────────────────────────────────────────────────────
//  SystemLogic
// ─────────────────────────────────────────────────────────────────────────────

/// Stateless utility class containing all core RPG scaling rules.
///
/// Every method is `static` — no instantiation required.
abstract final class SystemLogic {
  // ── HP ───────────────────────────────────────────────────────────────────

  /// Base Max HP before any Vitality bonus.
  static const int baseMaxHp = 100;

  /// HP gained per point of Vitality.
  static const int hpPerVitality = 5;

  /// Calculates the hunter's maximum HP from their Vitality stat.
  ///
  /// Formula: `baseMaxHp + (vitality × hpPerVitality)`
  ///
  /// Example:
  /// ```dart
  /// SystemLogic.calculateMaxHp(vitality: 20); // → 200
  /// ```
  ///
  /// [vitality] must be ≥ 0; negative values are clamped to 0.
  static int calculateMaxHp({required int vitality}) {
    final int safeVit = vitality.clamp(0, 9999);
    return baseMaxHp + (safeVit * hpPerVitality);
  }

  // ── Rank ─────────────────────────────────────────────────────────────────

  /// Returns the [HunterRank] enum value for the given [totalLevel].
  ///
  /// Level thresholds:
  /// | Range   | Rank     |
  /// |---------|----------|
  /// | 1 – 9   | E-Rank   |
  /// | 10 – 19 | D-Rank   |
  /// | 20 – 39 | C-Rank   |
  /// | 40 – 59 | B-Rank   |
  /// | 60 – 79 | A-Rank   |
  /// | 80 – 99 | S-Rank   |
  /// | 100+    | Monarch  |
  ///
  /// [totalLevel] is clamped to a minimum of 1.
  static HunterRank determineHunterRank(int totalLevel) {
    final int level = totalLevel.clamp(1, 9999);

    if (level >= 100) return HunterRank.monarch;
    if (level >= 80) return HunterRank.sRank;
    if (level >= 60) return HunterRank.aRank;
    if (level >= 40) return HunterRank.bRank;
    if (level >= 20) return HunterRank.cRank;
    if (level >= 10) return HunterRank.dRank;
    return HunterRank.eRank;
  }

  /// Convenience method — returns the rank label string directly.
  ///
  /// Equivalent to `SystemLogic.determineHunterRank(level).label`.
  ///
  /// Example:
  /// ```dart
  /// SystemLogic.determineHunterRankLabel(9);   // → "E-Rank"
  /// SystemLogic.determineHunterRankLabel(100); // → "Monarch"
  /// ```
  static String determineHunterRankLabel(int totalLevel) =>
      determineHunterRank(totalLevel).label;

  // ── Rank-Up Exam ─────────────────────────────────────────────────────────

  /// Returns `true` when [totalLevel] is exactly at the cap of the hunter's
  /// current rank, indicating they should face a Boss Raid / Rank-Up Exam.
  ///
  /// Trigger levels:  9 · 19 · 39 · 59 · 79 · 99
  ///
  /// Returns `false` for Monarch-tier hunters (level ≥ 100) because there
  /// is no rank above Monarch to ascend to.
  ///
  /// Example:
  /// ```dart
  /// SystemLogic.isEligibleForRankUp(9);   // → true  (E→D exam)
  /// SystemLogic.isEligibleForRankUp(10);  // → false (just ranked up)
  /// SystemLogic.isEligibleForRankUp(100); // → false (already Monarch)
  /// ```
  static bool isEligibleForRankUp(int totalLevel) {
    final HunterRank currentRank = determineHunterRank(totalLevel);
    final int? examLevel = currentRank.rankUpExamLevel;

    // Monarch has no ceiling → no exam
    if (examLevel == null) return false;

    return totalLevel == examLevel;
  }

  // ── XP ───────────────────────────────────────────────────────────────────

  /// XP required to reach the next level from [currentLevel].
  ///
  /// Formula: `100 × currentLevel^1.4`  (gentle exponential curve)
  ///
  /// This keeps early levels fast and later levels progressively harder
  /// without becoming impossible.
  static int xpToNextLevel(int currentLevel) {
    final int level = currentLevel.clamp(1, 9999);
    return (100 * (level * level * 0.4 + level * 0.6)).round();
  }

  // ── Stat point rewards ───────────────────────────────────────────────────

  /// Stat points awarded upon reaching [newLevel].
  ///
  /// Rank-up levels (9, 19, 39, 59, 79, 99) grant a bonus of **+3** extra
  /// points to celebrate the milestone.
  static int statPointsForLevel(int newLevel) {
    const int base = 3;
    const int rankUpBonus = 3;
    return isEligibleForRankUp(newLevel) ? base + rankUpBonus : base;
  }
}
