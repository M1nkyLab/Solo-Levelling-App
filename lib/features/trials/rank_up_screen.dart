import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/features/player/player_provider.dart';
import 'package:solo_levelling_app/features/player/player.dart';
import 'package:solo_levelling_app/features/player/player_rank.dart';
import 'package:solo_levelling_app/features/trials/trial_portal_card.dart';
import 'package:solo_levelling_app/features/trials/trial_screen.dart';

class RankUpScreen extends ConsumerWidget {
  const RankUpScreen({super.key});

  void _enterTrial(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    ref.read(playerProvider.notifier).startTrial();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TrialScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final bool showTrialPortal = player.isTrialAvailable && player.trialStatus != TrialStatus.failed;

    return Scaffold(
      backgroundColor: ShadowColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'RANK ADVANCEMENT',
          style: ShadowTextTheme.headline(20, letterSpacing: 2),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showTrialPortal) ...[
                Text(
                  'EVALUATION AVAILABLE',
                  style: ShadowTextTheme.mono(14, color: ShadowColors.portalBlue, weight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 24),
                TrialPortalCard(onTap: () => _enterTrial(context, ref)),
              ] else ...[
                Icon(
                  Icons.lock_outline_rounded,
                  size: 64,
                  color: ShadowColors.textDisabled,
                ),
                const SizedBox(height: 24),
                Text(
                  'ACCESS DENIED',
                  style: ShadowTextTheme.headline(24, color: ShadowColors.textDisabled, letterSpacing: 2),
                ),
                const SizedBox(height: 16),
                Text(
                  player.rank == PlayerRank.S 
                      ? 'You have reached the maximum rank.'
                      : 'Reach Level ${player.rank.capstoneLevel} to unlock the next Rank-Up Trial.',
                  textAlign: TextAlign.center,
                  style: ShadowTextTheme.body(14, color: ShadowColors.textSecondary),
                ),
                const SizedBox(height: 48),
                LinearProgressIndicator(
                  value: player.rank == PlayerRank.S 
                      ? 1.0 
                      : (player.level / player.rank.capstoneLevel!).clamp(0.0, 1.0),
                  backgroundColor: ShadowColors.surfaceAlt,
                  color: ShadowColors.amethyst,
                  minHeight: 4,
                ),
                const SizedBox(height: 16),
                Text(
                  player.rank == PlayerRank.S 
                      ? 'MAX LEVEL'
                      : 'CURRENT LEVEL: ${player.level} / ${player.rank.capstoneLevel}',
                  style: ShadowTextTheme.mono(12, color: ShadowColors.amethystLight, weight: FontWeight.bold),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
