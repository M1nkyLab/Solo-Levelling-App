import 'dart:ui';
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatingCtrl,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -5 * _floatingCtrl.value),
          child: child,
        );
      },
      child: Container(
        key: ValueKey(widget.rank),
        height: 350,
        width: double.infinity,
        color: const Color(0xFF000000), // Background color from Aura Section
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Aura Glow
            Positioned(
              top: 25,
              child: Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  color: Color(0xFF8A2BE2),
                  shape: BoxShape.circle,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
            // Character Graphic
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person, size: 80, color: Colors.white54),
                    const SizedBox(height: 16),
                    Text(
                      'CHARACTER GRAPHIC',
                      style: ShadowTextTheme.mono(12, color: Colors.white54, weight: FontWeight.bold, letterSpacing: 2),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

