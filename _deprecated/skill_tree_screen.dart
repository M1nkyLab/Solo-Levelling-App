import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/features/player/player_provider.dart';
import 'package:solo_levelling_app/features/skills/skill.dart';
import 'package:solo_levelling_app/features/skills/skills_provider.dart';
import 'package:solo_levelling_app/core/widgets/shadow_card.dart';

class SkillTreeScreen extends ConsumerWidget {
  const SkillTreeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skills = ref.watch(skillsProvider);
    final player = ref.watch(playerProvider);

    return Scaffold(
      backgroundColor: ShadowColors.obsidian,
      appBar: AppBar(
        backgroundColor: ShadowColors.obsidian,
        title: Text('SKILL TREE', style: ShadowTextTheme.headline(18, letterSpacing: 2)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ShadowColors.amethyst),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildStatHeader(player),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: skills.length,
              itemBuilder: (context, index) {
                final skill = skills[index];
                return _buildSkillCard(context, ref, skill);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatHeader(dynamic player) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: const BoxDecoration(
        color: ShadowColors.surfaceAlt,
        border: Border(
          bottom: BorderSide(color: ShadowColors.systemBorder, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'AVAILABLE POINTS:',
            style: ShadowTextTheme.mono(14, color: ShadowColors.textSecondary),
          ),
          Text(
            '${player.availableStatPoints}',
            style: ShadowTextTheme.headline(20, color: ShadowColors.amethyst),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillCard(BuildContext context, WidgetRef ref, Skill skill) {
    final canUpgrade = ref.read(skillsProvider.notifier).canUpgrade(skill.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ShadowCard(
        accentColor: skill.isUnlocked ? ShadowColors.amethyst : ShadowColors.textDisabled,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildSkillIcon(skill),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skill.name.toUpperCase(),
                          style: ShadowTextTheme.headline(16, 
                            color: skill.isUnlocked ? ShadowColors.textPrimary : ShadowColors.textDisabled
                          ),
                        ),
                        Text(
                          'Level ${skill.level} / ${skill.maxLevel}',
                          style: ShadowTextTheme.mono(12, color: ShadowColors.amethystLight),
                        ),
                      ],
                    ),
                  ),
                  if (canUpgrade)
                    ElevatedButton(
                      onPressed: () => ref.read(skillsProvider.notifier).upgradeSkill(skill.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ShadowColors.amethyst,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(0, 32),
                      ),
                      child: Text('UPGRADE', style: ShadowTextTheme.mono(10, weight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                skill.description,
                style: ShadowTextTheme.body(14, color: ShadowColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillIcon(Skill skill) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: ShadowColors.surfaceAlt,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: skill.isUnlocked ? ShadowColors.amethyst : ShadowColors.systemBorder,
          width: 1,
        ),
      ),
      child: Icon(
        _getSkillIconData(skill.id),
        color: skill.isUnlocked ? ShadowColors.amethyst : ShadowColors.textDisabled,
      ),
    );
  }

  IconData _getSkillIconData(String id) {
    switch (id) {
      case 'tenacity': return Icons.shield_rounded;
      case 'dash': return Icons.bolt_rounded;
      case 'mana_flow': return Icons.auto_fix_high_rounded;
      case 'indomitable_spirit': return Icons.favorite_rounded;
      default: return Icons.star_rounded;
    }
  }
}
