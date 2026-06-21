import 'player_rank.dart';

enum TrialStatus { idle, active, failed, penalty }

class Player {
  final String id;
  final String userId;
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
  final bool isDead;
  final DateTime? lastPenaltyCheck;
  final DateTime? lastWorkoutDate;
  final int consecutiveMissedDays;
  final bool isLoaded;

  final Map<String, int> unlockedSkills;
  final List<String> extractedShadows;

  Player({
    required this.id,
    required this.userId,
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
    this.isDead = false,
    this.lastPenaltyCheck,
    this.lastWorkoutDate,
    this.consecutiveMissedDays = 0,
    this.isLoaded = false,
    this.unlockedSkills = const {},
    this.extractedShadows = const [],
  });

  bool get isTrialAvailable => currentExp >= maxExp;

  Player copyWith({
    String? id,
    String? userId,
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
    bool? isDead,
    DateTime? lastPenaltyCheck,
    DateTime? lastWorkoutDate,
    int? consecutiveMissedDays,
    bool? isLoaded,
    Map<String, int>? unlockedSkills,
    List<String>? extractedShadows,
  }) {
    return Player(
      id: id ?? this.id,
      userId: userId ?? this.userId,
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
      isDead: isDead ?? this.isDead,
      lastPenaltyCheck: lastPenaltyCheck ?? this.lastPenaltyCheck,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      consecutiveMissedDays: consecutiveMissedDays ?? this.consecutiveMissedDays,
      isLoaded: isLoaded ?? this.isLoaded,
      unlockedSkills: unlockedSkills ?? this.unlockedSkills,
      extractedShadows: extractedShadows ?? this.extractedShadows,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'level': level,
      'rank': rank.name,
      'current_exp': currentExp,
      'max_exp': maxExp,
      'current_hp': currentHp,
      'max_hp': maxHp,
      'strength': strength,
      'agility': agility,
      'vitality': vitality,
      'intelligence': intelligence,
      'sense': sense,
      'available_stat_points': availableStatPoints,
      'trial_status': trialStatus.name,
      'is_dead': isDead,
      'last_penalty_check': lastPenaltyCheck?.toIso8601String(),
      'last_workout_date': lastWorkoutDate?.toIso8601String(),
      'consecutive_missed_days': consecutiveMissedDays,
      'unlocked_skills': unlockedSkills,
      'extracted_shadows': extractedShadows,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      userId: json['user_id'],
      level: json['level'] ?? 1,
      rank: PlayerRank.values.firstWhere(
        (e) => e.name == (json['rank'] ?? 'E'),
        orElse: () => PlayerRank.E,
      ),
      currentExp: json['current_exp'] ?? 0,
      maxExp: json['max_exp'] ?? 100,
      currentHp: json['current_hp'] ?? 100,
      maxHp: json['max_hp'] ?? 100,
      strength: json['strength'] ?? 10,
      agility: json['agility'] ?? 10,
      vitality: json['vitality'] ?? 10,
      intelligence: json['intelligence'] ?? 10,
      sense: json['sense'] ?? 10,
      availableStatPoints: json['available_stat_points'] ?? 0,
      trialStatus: TrialStatus.values.firstWhere(
        (e) => e.name == (json['trial_status'] ?? 'idle'),
        orElse: () => TrialStatus.idle,
      ),
      isDead: json['is_dead'] ?? false,
      lastPenaltyCheck: json['last_penalty_check'] != null
          ? DateTime.parse(json['last_penalty_check'])
          : null,
      lastWorkoutDate: json['last_workout_date'] != null
          ? DateTime.parse(json['last_workout_date'])
          : null,
      consecutiveMissedDays: json['consecutive_missed_days'] ?? 0,
      unlockedSkills: Map<String, int>.from(json['unlocked_skills'] ?? {}),
      extractedShadows: List<String>.from(json['extracted_shadows'] ?? []),
    );
  }
}

