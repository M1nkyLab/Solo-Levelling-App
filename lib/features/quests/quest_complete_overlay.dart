import 'dart:ui';
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
  late Animation<double> _blur;
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

    _blur = Tween<double>(begin: 0.0, end: 18.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );

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
            // Blurred backdrop
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: _blur.value, sigmaY: _blur.value),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.75 * _opacity.value),
                ),
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
                        color: ShadowColors.surfaceAlt.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: ShadowColors.amethyst.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ShadowColors.amethyst.withValues(alpha: 0.25),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // System tag
                            Text(
                              '[SYSTEM ALERT]',
                              style: ShadowTextTheme.mono(11,
                                  color: ShadowColors.amethystLight,
                                  weight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),

                            // Checkmark icon
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ShadowColors.success
                                    .withValues(alpha: 0.12),
                                border: Border.all(
                                    color: ShadowColors.success
                                        .withValues(alpha: 0.5),
                                    width: 2),
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: ShadowColors.success,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Title
                            Text(
                              'DAILY QUEST COMPLETE',
                              textAlign: TextAlign.center,
                              style: ShadowTextTheme.headline(20,
                                      weight: FontWeight.w900)
                                  .copyWith(
                                color: ShadowColors.textPrimary,
                                shadows: [
                                  Shadow(
                                    color: ShadowColors.amethyst
                                        .withValues(alpha: 0.6),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'The System acknowledges your discipline.\nRewards will be applied upon confirmation.',
                              textAlign: TextAlign.center,
                              style: ShadowTextTheme.body(13,
                                  color: ShadowColors.textSecondary),
                            ),

                            const SizedBox(height: 28),

                            // Rewards box
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: ShadowColors.voidDark
                                    .withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: ShadowColors.xpGold
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'PENDING REWARDS',
                                    style: ShadowTextTheme.mono(10,
                                        color: ShadowColors.xpGold,
                                        weight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 14),
                                  _rewardRow(
                                    icon: Icons.bolt_rounded,
                                    color: ShadowColors.xpGold,
                                    label: 'Experience',
                                    value: '+${widget.expReward} EXP',
                                  ),
                                  const SizedBox(height: 10),
                                  _rewardRow(
                                    icon: Icons.favorite_rounded,
                                    color: ShadowColors.hpRed,
                                    label: 'Vitality Restored',
                                    value: '+${widget.hpHeal} HP',
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Continue button
                            GestureDetector(
                              onTap: _handleContinue,
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      ShadowColors.amethyst,
                                      ShadowColors.amethyst
                                          .withValues(alpha: 0.7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: ShadowColors.amethyst
                                          .withValues(alpha: 0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'CONTINUE',
                                  textAlign: TextAlign.center,
                                  style: ShadowTextTheme.mono(15,
                                      color: Colors.white,
                                      weight: FontWeight.bold),
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
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: ShadowTextTheme.mono(12,
                  color: ShadowColors.textSecondary),
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
  late Animation<double> _blur;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.2)
              .chain(CurveTween(curve: Curves.easeOutBack)),
          weight: 40),
      TweenSequenceItem(
          tween: Tween(begin: 1.2, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 60),
    ]).animate(_controller);

    _blur = Tween<double>(begin: 0.0, end: 20.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );

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
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                        sigmaX: _blur.value, sigmaY: _blur.value),
                    child: Container(
                      color:
                          Colors.black.withValues(alpha: 0.8 * _opacity.value),
                    ),
                  ),
                ),
                Center(
                  child: ScaleTransition(
                    scale: _scale,
                    child: FadeTransition(
                      opacity: _opacity,
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '[SYSTEM ALERT]',
                              style: ShadowTextTheme.mono(14,
                                  color: ShadowColors.portalBlue,
                                  weight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.oldRank.rankUpTitle.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: ShadowTextTheme.headline(24,
                                      weight: FontWeight.w900)
                                  .copyWith(
                                color: ShadowColors.textPrimary,
                                shadows: [
                                  Shadow(
                                    color: ShadowColors.portalBlue
                                        .withValues(alpha: 0.8),
                                    blurRadius: 30,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              widget.oldRank.rankUpMessage,
                              textAlign: TextAlign.center,
                              style: ShadowTextTheme.body(16,
                                  color: ShadowColors.textSecondary),
                            ),
                            const SizedBox(height: 40),
                            _buildRankBadge(),
                            const SizedBox(height: 40),
                            _buildRankTransition(),
                            const SizedBox(height: 12),
                            Text(
                              '*${widget.oldRank.nextRankHint}*',
                              style: ShadowTextTheme.body(14,
                                  color: ShadowColors.amethystLight,
                                  italic: true),
                            ),
                            const SizedBox(height: 40),
                            Text(
                              'Tap anywhere to continue',
                              style: ShadowTextTheme.mono(11,
                                  color: ShadowColors.textDisabled),
                            ),
                          ],
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
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: ShadowColors.portalBlue.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: ShadowColors.portalBlue.withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Text(
        widget.newRank.displayName,
        style: ShadowTextTheme.headline(64, weight: FontWeight.w900).copyWith(
          color: ShadowColors.portalBlue,
        ),
      ),
    );
  }

  Widget _buildRankTransition() {
    return Column(
      children: [
        Text(
          'RANK UP!',
          style: ShadowTextTheme.headline(20,
              color: ShadowColors.success, weight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '[${widget.oldRank.displayName}-Class]',
              style: ShadowTextTheme.mono(18,
                  color: ShadowColors.textDisabled),
            ),
            const SizedBox(width: 20),
            const Icon(Icons.arrow_forward_rounded,
                color: ShadowColors.portalBlue, size: 24),
            const SizedBox(width: 20),
            Text(
              '[${widget.newRank.displayName}-Class]',
              style: ShadowTextTheme.mono(24,
                  color: ShadowColors.portalBlue, weight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
