import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/features/player/player_rank.dart';

class QuestCompleteOverlay extends StatefulWidget {
  final VoidCallback onDismiss;
  final PlayerRank oldRank;
  final PlayerRank newRank;

  const QuestCompleteOverlay({
    super.key,
    required this.onDismiss,
    required this.oldRank,
    required this.newRank,
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2).chain(CurveTween(curve: Curves.easeOutBack)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 60),
    ]).animate(_controller);

    _blur = Tween<double>(begin: 0.0, end: 20.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.easeIn)),
    );

    _controller.forward();
    
    // Impact Haptics
    HapticFeedback.vibrate();
    Future.delayed(const Duration(milliseconds: 400), () => HapticFeedback.heavyImpact());
    Future.delayed(const Duration(milliseconds: 800), () => HapticFeedback.heavyImpact());
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
                    filter: ImageFilter.blur(sigmaX: _blur.value, sigmaY: _blur.value),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.8 * _opacity.value),
                    ),
                  ),
                ),
                
                Center(
                  child: ScaleTransition(
                    scale: _scale,
                    child: FadeTransition(
                      opacity: _opacity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '[SYSTEM ALERT]',
                              style: ShadowTextTheme.mono(14, color: ShadowColors.portalBlue, weight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.oldRank.rankUpTitle.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: ShadowTextTheme.headline(24, weight: FontWeight.w900).copyWith(
                                color: ShadowColors.textPrimary,
                                shadows: [
                                  Shadow(
                                    color: ShadowColors.portalBlue.withValues(alpha: 0.8),
                                    blurRadius: 30,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              widget.oldRank.rankUpMessage,
                              textAlign: TextAlign.center,
                              style: ShadowTextTheme.body(16, color: ShadowColors.textSecondary),
                            ),
                            const SizedBox(height: 40),
                            _buildRankBadge(),
                            const SizedBox(height: 40),
                            _buildRankTransition(),
                            const SizedBox(height: 12),
                            Text(
                              '*${widget.oldRank.nextRankHint}*',
                              style: ShadowTextTheme.body(14, color: ShadowColors.amethystLight, italic: true),
                            ),
                            const SizedBox(height: 60),
                            _buildRewards(),
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
        border: Border.all(color: ShadowColors.portalBlue.withValues(alpha: 0.5), width: 2),
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
          'LEVEL UP!',
          style: ShadowTextTheme.headline(20, color: ShadowColors.success, weight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '[${widget.oldRank.displayName}-Class]',
              style: ShadowTextTheme.mono(18, color: ShadowColors.textDisabled),
            ),
            const SizedBox(width: 20),
            const Icon(Icons.arrow_forward_rounded, color: ShadowColors.portalBlue, size: 24),
            const SizedBox(width: 20),
            Text(
              '[${widget.newRank.displayName}-Class]',
              style: ShadowTextTheme.mono(24, color: ShadowColors.portalBlue, weight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRewards() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: ShadowColors.surfaceAlt.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ShadowColors.xpGold.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            'SYSTEM REWARDS',
            style: ShadowTextTheme.mono(10, color: ShadowColors.xpGold, weight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            '+1 LEVEL   +5000 XP   +10 STATUS POINTS',
            style: ShadowTextTheme.mono(14, color: ShadowColors.textPrimary, weight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
