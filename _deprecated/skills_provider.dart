import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo_levelling_app/features/player/player_provider.dart';
import 'package:solo_levelling_app/features/skills/skill.dart';

class SkillsNotifier extends Notifier<List<Skill>> {
  @override
  List<Skill> build() {
    final player = ref.watch(playerProvider);
    return initialSkills.map((skill) {
      final level = player.unlockedSkills[skill.id] ?? 0;
      return skill.copyWith(level: level);
    }).toList();
  }

  bool canUpgrade(String skillId) {
    final player = ref.read(playerProvider);
    final skill = state.firstWhere((s) => s.id == skillId);
    
    return player.availableStatPoints >= skill.cost && skill.level < skill.maxLevel;
  }

  void upgradeSkill(String skillId) {
    if (!canUpgrade(skillId)) return;

    final player = ref.read(playerProvider);
    final skill = state.firstWhere((s) => s.id == skillId);
    
    final newLevel = skill.level + 1;
    final newUnlockedSkills = Map<String, int>.from(player.unlockedSkills);
    newUnlockedSkills[skillId] = newLevel;

    // Update player state
    ref.read(playerProvider.notifier).state = player.copyWith(
      availableStatPoints: player.availableStatPoints - skill.cost,
      unlockedSkills: newUnlockedSkills,
    );
  }
}

final skillsProvider = NotifierProvider<SkillsNotifier, List<Skill>>(() {
  return SkillsNotifier();
});
