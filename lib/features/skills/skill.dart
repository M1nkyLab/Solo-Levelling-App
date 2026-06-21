enum SkillType { passive, active }

class Skill {
  final String id;
  final String name;
  final String description;
  final SkillType type;
  final int level;
  final int maxLevel;
  final int cost;
  final String iconPath;
  final Map<String, dynamic> effects;

  const Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.level = 0,
    this.maxLevel = 5,
    this.cost = 1,
    required this.iconPath,
    this.effects = const {},
  });

  bool get isUnlocked => level > 0;

  Skill copyWith({
    int? level,
  }) {
    return Skill(
      id: id,
      name: name,
      description: description,
      type: type,
      level: level ?? this.level,
      maxLevel: maxLevel,
      cost: cost,
      iconPath: iconPath,
      effects: effects,
    );
  }
}

final List<Skill> initialSkills = [
  const Skill(
    id: 'tenacity',
    name: 'Tenacity',
    description: 'Reduces HP loss from missed daily quests.',
    type: SkillType.passive,
    iconPath: 'assets/icons/tenacity.svg',
    effects: {'hp_loss_reduction': 0.1}, // 10% reduction per level
  ),
  const Skill(
    id: 'dash',
    name: 'Dash',
    description: 'Increases XP gained from Running quests.',
    type: SkillType.passive,
    iconPath: 'assets/icons/dash.svg',
    effects: {'cardio_xp_boost': 0.15}, // 15% boost per level
  ),
  const Skill(
    id: 'mana_flow',
    name: 'Mana Flow',
    description: 'Increases overall XP gained from all sources.',
    type: SkillType.passive,
    iconPath: 'assets/icons/mana_flow.svg',
    effects: {'global_xp_boost': 0.05}, // 5% boost per level
  ),
  const Skill(
    id: 'indomitable_spirit',
    name: 'Indomitable Spirit',
    description: 'Increases maximum HP.',
    type: SkillType.passive,
    iconPath: 'assets/icons/spirit.svg',
    effects: {'max_hp_increase': 10}, // +10 HP per level
  ),
];
