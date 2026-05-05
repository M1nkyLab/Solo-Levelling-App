import 'player_rank.dart';

enum TrialStatus { idle, active, failed }

class Player {
  final int level;
  final PlayerRank rank;
  final int currentExp;
  final int maxExp;
  final int currentHp;
  final int maxHp;
  
  // RPG Stats
  final int strength;
  final int agility;
  final int vitality;
  final int intelligence;
  final int sense;
  final int availableStatPoints;

  final TrialStatus trialStatus;
  final bool hasFailedTrial;
  final DateTime? lastPenaltyCheck;

  Player({
    this.level = 1,
    this.rank = PlayerRank.E,
    this.currentExp = 0,
    this.maxExp = 100,
    this.currentHp = 100,
    this.maxHp = 100,
    this.strength = 10,
    this.agility = 10,
    this.vitality = 10,
    this.intelligence = 10,
    this.sense = 10,
    this.availableStatPoints = 0,
    this.trialStatus = TrialStatus.idle,
    this.hasFailedTrial = false,
    this.lastPenaltyCheck,
  });

  bool get isTrialAvailable => currentExp >= maxExp;

  Player copyWith({
    int? level,
    PlayerRank? rank,
    int? currentExp,
    int? maxExp,
    int? currentHp,
    int? maxHp,
    int? strength,
    int? agility,
    int? vitality,
    int? intelligence,
    int? sense,
    int? availableStatPoints,
    TrialStatus? trialStatus,
    bool? hasFailedTrial,
    DateTime? lastPenaltyCheck,
  }) {
    return Player(
      level: level ?? this.level,
      rank: rank ?? this.rank,
      currentExp: currentExp ?? this.currentExp,
      maxExp: maxExp ?? this.maxExp,
      currentHp: currentHp ?? this.currentHp,
      maxHp: maxHp ?? this.maxHp,
      strength: strength ?? this.strength,
      agility: agility ?? this.agility,
      vitality: vitality ?? this.vitality,
      intelligence: intelligence ?? this.intelligence,
      sense: sense ?? this.sense,
      availableStatPoints: availableStatPoints ?? this.availableStatPoints,
      trialStatus: trialStatus ?? this.trialStatus,
      hasFailedTrial: hasFailedTrial ?? this.hasFailedTrial,
      lastPenaltyCheck: lastPenaltyCheck ?? this.lastPenaltyCheck,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'rank': rank.index,
      'currentExp': currentExp,
      'maxExp': maxExp,
      'currentHp': currentHp,
      'maxHp': maxHp,
      'strength': strength,
      'agility': agility,
      'vitality': vitality,
      'intelligence': intelligence,
      'sense': sense,
      'availableStatPoints': availableStatPoints,
      'trialStatus': trialStatus.index,
      'hasFailedTrial': hasFailedTrial,
      'lastPenaltyCheck': lastPenaltyCheck?.toIso8601String(),
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      level: json['level'] ?? 1,
      rank: PlayerRank.values[json['rank'] ?? 0],
      currentExp: json['currentExp'] ?? 0,
      maxExp: json['maxExp'] ?? 100,
      currentHp: json['currentHp'] ?? 100,
      maxHp: json['maxHp'] ?? 100,
      strength: json['strength'] ?? 10,
      agility: json['agility'] ?? 10,
      vitality: json['vitality'] ?? 10,
      intelligence: json['intelligence'] ?? 10,
      sense: json['sense'] ?? 10,
      availableStatPoints: json['availableStatPoints'] ?? 0,
      trialStatus: TrialStatus.values[json['trialStatus'] ?? 0],
      hasFailedTrial: json['hasFailedTrial'] ?? false,
      lastPenaltyCheck: json['lastPenaltyCheck'] != null
          ? DateTime.parse(json['lastPenaltyCheck'])
          : null,
    );
  }
}
