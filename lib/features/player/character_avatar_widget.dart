import 'package:flutter/material.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/features/player/player_rank.dart';

class CharacterAvatarWidget extends StatefulWidget {
  final PlayerRank rank;
  final int level;

  const CharacterAvatarWidget({
    super.key,
    required this.rank,
    required this.level,
  });

  @override
  State<CharacterAvatarWidget> createState() => _CharacterAvatarWidgetState();
}

class _CharacterAvatarWidgetState extends State<CharacterAvatarWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _floatingCtrl;

  @override
  void initState() {
    super.initState();
    _floatingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingCtrl.dispose();
    super.dispose();
  }

  Color _getRankColor(PlayerRank rank) {
    switch (rank) {
      case PlayerRank.E: return Colors.grey.shade400;
      case PlayerRank.D: return Colors.green.shade400;
      case PlayerRank.C: return Colors.blue.shade400;
      case PlayerRank.B: return ShadowColors.amethyst;
      case PlayerRank.A: return ShadowColors.hpRed;
      case PlayerRank.S: return ShadowColors.xpGold;
    }
  }

  IconData _getRankIcon(PlayerRank rank) {
    switch (rank) {
      case PlayerRank.E: return Icons.person_outline_rounded;
      case PlayerRank.D: return Icons.person_rounded;
      case PlayerRank.C: return Icons.directions_run_rounded;
      case PlayerRank.B: return Icons.sports_martial_arts_rounded;
      case PlayerRank.A: return Icons.whatshot_rounded;
      case PlayerRank.S: return Icons.local_fire_department_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRankColor(widget.rank);
    final icon = _getRankIcon(widget.rank);

    return AnimatedBuilder(
      animation: _floatingCtrl,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -5 * _floatingCtrl.value),
          child: child,
        );
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Container(
          key: ValueKey(widget.rank),
          height: 480,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.3),
                ShadowColors.obsidian,
              ],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Placeholder for the actual image/video
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 80, color: color),
                    const SizedBox(height: 16),
                    Text(
                      'PLACEHOLDER',
                      style: ShadowTextTheme.mono(12, color: color, weight: FontWeight.bold, letterSpacing: 2),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Replace with Character Art/Video for Rank ${widget.rank.displayName}',
                        textAlign: TextAlign.center,
                        style: ShadowTextTheme.mono(10, color: ShadowColors.textDisabled),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
