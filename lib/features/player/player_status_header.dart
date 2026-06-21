
import 'package:flutter/material.dart';

import 'package:solo_levelling_app/core/logic/system_logic.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';

class PlayerStatusHeader extends StatefulWidget {
  final int level;
  final String? customTitle; 
  final int currentXp;
  final int maxXp; 
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

    if (_rankUpReady) _pulseCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(PlayerStatusHeader old) {
    super.didUpdateWidget(old);
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
      SystemLogic.determineHunterRankLabel(widget.level).replaceAll(RegExp(r'-Class|-Rank', caseSensitive: false), '');

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final glowOpacity = 0.15 + 0.15 * _pulse.value;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: ShadowColors.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ShadowColors.amethyst.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: ShadowColors.amethyst.withValues(alpha: glowOpacity),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 80, // roughly screen width minus paddings
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'RANK',
                          style: ShadowTextTheme.mono(10, color: ShadowColors.textDisabled, weight: FontWeight.bold, letterSpacing: 2),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _rankLabel.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Cinzel',
                            fontSize: 32,
                            color: ShadowColors.xpGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'LEVEL',
                          style: ShadowTextTheme.mono(10, color: ShadowColors.textDisabled, weight: FontWeight.bold, letterSpacing: 2),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.level.toString(),
                          style: TextStyle(
                            fontFamily: 'Cinzel',
                            fontSize: 32,
                            color: ShadowColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            _StatBar(
              label: 'HP',
              current: widget.currentHp,
              max: widget.maxHp,
              color: ShadowColors.hpRed,
            ),


            const SizedBox(height: 16),

            _StatBar(
              label: 'EXP',
              current: widget.currentXp,
              max: widget.maxXp,
              color: ShadowColors.xpGold,
              isMax: widget.currentXp >= widget.maxXp,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  final Color color;
  final bool isMax;

  const _StatBar({
    required this.label,
    required this.current,
    required this.max,
    required this.color,
    this.isMax = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: ShadowTextTheme.mono(12, color: ShadowColors.textDisabled, weight: FontWeight.bold, letterSpacing: 1),
            ),
            Text(
              isMax ? 'MAX' : '${current.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}/${max.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
              style: ShadowTextTheme.mono(14, color: isMax ? color : ShadowColors.textPrimary, weight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 4,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: max > 0 ? (current / max).clamp(0.0, 1.0) : 0,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
