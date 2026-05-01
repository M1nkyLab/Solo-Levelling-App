
import 'dart:ui';
import 'package:flutter/material.dart';

import '../logic/system_logic.dart';
import '../theme/app_theme.dart';
import 'smoky_progress_bar.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  PlayerStatusHeader
//
//  A self-contained header card that displays:
//    • Hunter rank badge  +  level
//    • EXP progress bar
//    • HP progress bar
//    • MP progress bar
//
//  All values are passed in as plain ints so the widget stays pure and
//  can be driven by local state, Riverpod, or a FutureBuilder alike.
// ─────────────────────────────────────────────────────────────────────────────

class PlayerStatusHeader extends StatefulWidget {
  // ── Identity ──────────────────────────────────────────────────────────────
  final int level;
  final String? customTitle; // override auto-computed rank label if desired

  // ── EXP ───────────────────────────────────────────────────────────────────
  final int currentXp;
  final int maxXp; // XP needed to reach next level

  // ── HP ────────────────────────────────────────────────────────────────────
  final int currentHp;
  final int maxHp;

  const PlayerStatusHeader({
    super.key,
    required this.level,
    this.customTitle,
    required this.currentXp,
    required this.maxXp,
    required this.currentHp,
    required this.maxHp,
  });

  @override
  State<PlayerStatusHeader> createState() => _PlayerStatusHeaderState();
}

class _PlayerStatusHeaderState extends State<PlayerStatusHeader>
    with SingleTickerProviderStateMixin {
  // Subtle ambient pulse on the whole card when a rank-up is ready
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _pulse = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // ── PERF: Only run the pulse animation when a rank-up is available.
    // Running it unconditionally wastes CPU+GPU every frame with no
    // visible effect (the glow opacity is constant when not ready).
    if (_rankUpReady) _pulseCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(PlayerStatusHeader old) {
    super.didUpdateWidget(old);
    // Toggle animation when rank-up eligibility changes.
    if (_rankUpReady && !_pulseCtrl.isAnimating) {
      _pulseCtrl.repeat(reverse: true);
    } else if (!_rankUpReady && _pulseCtrl.isAnimating) {
      _pulseCtrl.stop();
      _pulseCtrl.reset();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  bool get _rankUpReady => SystemLogic.isEligibleForRankUp(widget.level);

  String get _rankLabel =>
      widget.customTitle ??
      SystemLogic.determineHunterRankLabel(widget.level);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        // Glow intensity pulses when rank-up is available
        final double glowOpacity =
            _rankUpReady ? 0.20 + 0.20 * _pulse.value : 0.12;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              // Weightless shadows
              ...ShadowColors.weightlessShadow,
              // Ambient purple glow – tighter and crisper
              BoxShadow(
                color: ShadowColors.amethyst.withValues(alpha: glowOpacity),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: ShadowColors.surface.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ShadowColors.glassBorder.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Row 1: Rank badge + level ─────────────────────────────────
            _IdentityRow(
              rankLabel: _rankLabel,
              level: widget.level,
              isRankUpReady: _rankUpReady,
              pulse: _pulse,
            ),

            const SizedBox(height: 16),

            // ── EXP bar ───────────────────────────────────────────────────
            _StatSection(
              label: 'EXP',
              current: widget.currentXp,
              max: widget.maxXp,
              color: ShadowColors.xpGold,
              barHeight: 10,
              particleCount: 22,
            ),

            const SizedBox(height: 10),

            // ── HP bar ────────────────────────────────────────────────────
            _StatSection(
              label: 'HP',
              current: widget.currentHp,
              max: widget.maxHp,
              color: ShadowColors.hpRed,
              barHeight: 8,
              particleCount: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _IdentityRow  —  Rank badge | spacer | LVL display
// ─────────────────────────────────────────────────────────────────────────────

class _IdentityRow extends StatelessWidget {
  final String rankLabel;
  final int level;
  final bool isRankUpReady;
  final Animation<double> pulse;

  const _IdentityRow({
    required this.rankLabel,
    required this.level,
    required this.isRankUpReady,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Rank badge ─────────────────────────────────────────────────────
        AnimatedBuilder(
          animation: pulse,
          builder: (_, __) {
            final glowColor = isRankUpReady
                ? ShadowColors.xpGold.withValues(alpha: 0.35 + 0.25 * pulse.value)
                : ShadowColors.amethyst.withValues(alpha: 0.20);

            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: ShadowColors.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isRankUpReady
                      ? ShadowColors.xpGold
                      : ShadowColors.amethyst,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: glowColor,
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                rankLabel.toUpperCase(),
                style: ShadowTextTheme.headline(13).copyWith(
                  color: isRankUpReady
                      ? ShadowColors.xpGold
                      : ShadowColors.amethystLight,
                  letterSpacing: 2.5,
                ),
              ),
            );
          },
        ),

        // ── Rank-up ready indicator ────────────────────────────────────────
        if (isRankUpReady) ...[
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: pulse,
            builder: (_, __) => Opacity(
              opacity: 0.5 + 0.5 * pulse.value,
              child: Text(
                '⚡ RANK UP',
                style: ShadowTextTheme.mono(10,
                    color: ShadowColors.xpGold,
                    weight: FontWeight.bold),
              ),
            ),
          ),
        ],

        const Spacer(),

        // ── Level display ──────────────────────────────────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'LVL.',
              style: ShadowTextTheme.mono(9,
                  color: ShadowColors.textDisabled),
            ),
            Text(
              level.toString().padLeft(2, '0'),
              style: ShadowTextTheme.headline(28).copyWith(
                color: ShadowColors.textPrimary,
                height: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _StatSection  —  label row + SmokyProgressBar
// ─────────────────────────────────────────────────────────────────────────────

class _StatSection extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  final Color color;
  final double barHeight;
  final int particleCount;

  const _StatSection({
    required this.label,
    required this.current,
    required this.max,
    required this.color,
    required this.barHeight,
    required this.particleCount,
  });

  /// Returns a friendly percentage string, e.g. "68%"
  String get _pctLabel {
    if (max <= 0) return '0%';
    final pct = (current / max * 100).round();
    return '$pct%';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label row ──────────────────────────────────────────────────────
        Row(
          children: [
            // Colour dot
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: color.withValues(alpha: 0.7),
                      blurRadius: 6,
                      spreadRadius: 1),
                ],
              ),
            ),
            const SizedBox(width: 6),

            // e.g.  "HP"
            Text(
              label,
              style: ShadowTextTheme.mono(11,
                  color: color, weight: FontWeight.bold),
            ),

            const SizedBox(width: 6),

            // e.g.  "80 / 100"
            Text(
              '$current / $max',
              style: ShadowTextTheme.mono(11,
                  color: ShadowColors.textSecondary),
            ),

            const Spacer(),

            // e.g.  "80%"
            Text(
              _pctLabel,
              style: ShadowTextTheme.mono(10,
                  color: ShadowColors.textDisabled),
            ),
          ],
        ),

        const SizedBox(height: 5),

        // ── Smoky progress bar ─────────────────────────────────────────────
        SmokyProgressBar(
          currentValue: current,
          maxValue: max,
          color: color,
          height: barHeight,
          particleCount: particleCount,
        ),
      ],
    );
  }
}
