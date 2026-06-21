import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/features/player/player_rank.dart';

// ─────────────────────────────────────────────
//  Daily Quest Complete Overlay
//  Shown when all daily quests are finished.
//  XP + HP are awarded AFTER the user taps "Continue".
// ─────────────────────────────────────────────
class QuestCompleteOverlay extends StatefulWidget {
  /// Called when user presses "Continue" — triggers XP + HP reward.
  final VoidCallback onContinue;
  final int expReward;
  final int hpHeal;
  final PlayerRank rank;

  const QuestCompleteOverlay({
    super.key,
    required this.onContinue,
    required this.expReward,
    required this.hpHeal,
    required this.rank,
  });

  @override
  State<QuestCompleteOverlay> createState() => _QuestCompleteOverlayState();
}

class _QuestCompleteOverlayState extends State<QuestCompleteOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  bool _claimed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.05)
              .chain(CurveTween(curve: Curves.easeOutBack)),
          weight: 60),
      TweenSequenceItem(
          tween: Tween(begin: 1.05, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 40),
    ]).animate(_controller);

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    _controller.forward();

    HapticFeedback.vibrate();
    Future.delayed(
        const Duration(milliseconds: 300), () => HapticFeedback.heavyImpact());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_claimed) return;
    _claimed = true;
    HapticFeedback.mediumImpact();
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Darkened backdrop
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.9 * _opacity.value),
              ),
            ),

            // Content
            Center(
              child: ScaleTransition(
                scale: _scale,
                child: FadeTransition(
                  opacity: _opacity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: ShadowColors.amethyst.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      padding: const EdgeInsets.all(1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          color: ShadowColors.obsidian,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // System tag
                            Text(
                              '[ SYSTEM REWARD ]',
                              style: ShadowTextTheme.mono(12,
                                  color: ShadowColors.amethystLight,
                                  weight: FontWeight.bold,
                                  letterSpacing: 4),
                            ),
                            const SizedBox(height: 24),

                            // Checkmark icon - Sharp System Indicator
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: ShadowColors.surfaceAlt,
                                border: Border.all(
                                    color: ShadowColors.success,
                                    width: 1.5),
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: ShadowColors.success,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Title
                            Text(
                              'DAILY QUEST COMPLETE',
                              textAlign: TextAlign.center,
                              style: ShadowTextTheme.headline(20,
                                      weight: FontWeight.w900)
                                  .copyWith(
                                color: ShadowColors.textPrimary,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'The System acknowledges your discipline.\nRewards will be applied upon confirmation.',
                              textAlign: TextAlign.center,
                              style: ShadowTextTheme.body(13,
                                  color: ShadowColors.textSecondary),
                            ),

                            const SizedBox(height: 32),

                            // Rewards box
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: ShadowColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(
                                    color: ShadowColors.systemBorder),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'PENDING REWARDS',
                                    style: ShadowTextTheme.mono(10,
                                        color: ShadowColors.xpGold,
                                        weight: FontWeight.bold,
                                        letterSpacing: 1),
                                  ),
                                  const SizedBox(height: 20),
                                  _rewardRow(
                                    icon: Icons.bolt_rounded,
                                    color: ShadowColors.xpGold,
                                    label: 'EXPERIENCE',
                                    value: '+${widget.expReward} EXP',
                                  ),
                                  const SizedBox(height: 12),
                                  _rewardRow(
                                    icon: Icons.favorite_rounded,
                                    color: ShadowColors.hpRed,
                                    label: 'VITALITY',
                                    value: '+${widget.hpHeal} HP',
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Continue button
                            GestureDetector(
                              onTap: _handleContinue,
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                decoration: BoxDecoration(
                                  color: ShadowColors.amethyst.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(color: ShadowColors.amethyst, width: 1.5),
                                ),
                                child: Text(
                                  'CONTINUE',
                                  textAlign: TextAlign.center,
                                  style: ShadowTextTheme.mono(16,
                                      color: ShadowColors.amethystLight,
                                      weight: FontWeight.bold,
                                      letterSpacing: 6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _rewardRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 10),
            Text(
              label,
              style: ShadowTextTheme.mono(10,
                  color: ShadowColors.textDisabled, weight: FontWeight.bold),
            ),
          ],
        ),
        Text(
          value,
          style: ShadowTextTheme.mono(14,
              color: color, weight: FontWeight.bold),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Rank-Up Overlay (used by Trial system)
// ─────────────────────────────────────────────
class RankUpOverlay extends StatefulWidget {
  final VoidCallback onDismiss;
  final PlayerRank oldRank;
  final PlayerRank newRank;

  const RankUpOverlay({
    super.key,
    required this.onDismiss,
    required this.oldRank,
    required this.newRank,
  });

  @override
  State<RankUpOverlay> createState() => _RankUpOverlayState();
}

class _RankUpOverlayState extends State<RankUpOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.1)
              .chain(CurveTween(curve: Curves.easeOutBack)),
          weight: 40),
      TweenSequenceItem(
          tween: Tween(begin: 1.1, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 60),
    ]).animate(_controller);

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.3, curve: Curves.easeIn)),
    );

    _controller.forward();
    HapticFeedback.vibrate();
    Future.delayed(
        const Duration(milliseconds: 400), () => HapticFeedback.heavyImpact());
    Future.delayed(
        const Duration(milliseconds: 800), () => HapticFeedback.heavyImpact());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: widget.onDismiss,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.9 * _opacity.value),
                  ),
                ),
                Center(
                  child: ScaleTransition(
                    scale: _scale,
                    child: FadeTransition(
                      opacity: _opacity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: ShadowColors.portalBlue.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          padding: const EdgeInsets.all(1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                            decoration: BoxDecoration(
                              color: ShadowColors.obsidian,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '[ SYSTEM NOTIFICATION ]',
                                  style: ShadowTextTheme.mono(12,
                                      color: ShadowColors.portalBlue,
                                      weight: FontWeight.bold,
                                      letterSpacing: 4),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  widget.oldRank.rankUpTitle.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: ShadowTextTheme.headline(22,
                                          weight: FontWeight.w900)
                                      .copyWith(
                                    color: ShadowColors.textPrimary,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  widget.oldRank.rankUpMessage,
                                  textAlign: TextAlign.center,
                                  style: ShadowTextTheme.body(14,
                                      color: ShadowColors.textSecondary),
                                ),
                                const SizedBox(height: 40),
                                _buildRankBadge(),
                                const SizedBox(height: 40),
                                _buildRankTransition(),
                                const SizedBox(height: 20),
                                Text(
                                  '*${widget.oldRank.nextRankHint}*',
                                  textAlign: TextAlign.center,
                                  style: ShadowTextTheme.body(13,
                                      color: ShadowColors.amethystLight,
                                      italic: true),
                                ),
                                const SizedBox(height: 40),
                                Text(
                                  'Tap anywhere to continue',
                                  style: ShadowTextTheme.mono(10,
                                      color: ShadowColors.textDisabled,
                                      weight: FontWeight.bold,
                                      letterSpacing: 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRankBadge() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: ShadowColors.surfaceAlt,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
            color: ShadowColors.portalBlue, width: 2),
      ),
      child: Center(
        child: Text(
          widget.newRank.displayName,
          style: ShadowTextTheme.headline(72, weight: FontWeight.w900).copyWith(
            color: ShadowColors.portalBlue,
          ),
        ),
      ),
    );
  }

  Widget _buildRankTransition() {
    return Column(
      children: [
        Text(
          'RANK UP!',
          style: ShadowTextTheme.headline(18,
              color: ShadowColors.success, weight: FontWeight.bold, letterSpacing: 2),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '[${widget.oldRank.displayName}-Class]',
              style: ShadowTextTheme.mono(16,
                  color: ShadowColors.textDisabled, weight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.arrow_forward_rounded,
                color: ShadowColors.portalBlue, size: 20),
            const SizedBox(width: 16),
            Text(
              '[${widget.newRank.displayName}-Class]',
              style: ShadowTextTheme.headline(18,
                  color: ShadowColors.portalBlue, weight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
