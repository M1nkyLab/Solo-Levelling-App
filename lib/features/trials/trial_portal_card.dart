import 'package:flutter/material.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';

class TrialPortalCard extends StatefulWidget {
  final VoidCallback onTap;

  const TrialPortalCard({super.key, required this.onTap});

  @override
  State<TrialPortalCard> createState() => _TrialPortalCardState();
}

class _TrialPortalCardState extends State<TrialPortalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ShadowColors.glassAmethystCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: ShadowColors.portalBlue.withValues(
                  alpha: 0.2 + (0.2 * _pulseController.value),
                ),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: ShadowColors.portalBlue.withValues(
                    alpha: 0.1 + (0.1 * _pulseController.value),
                  ),
                  blurRadius: 20 + (10 * _pulseController.value),
                  spreadRadius: 2 * _pulseController.value,
                ),
                ...ShadowColors.weightlessShadow,
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.auto_awesome_mosaic_rounded,
                  color: ShadowColors.portalBlue,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'RANK UP TRIAL',
                  style: ShadowTextTheme.headline(22, weight: FontWeight.bold).copyWith(
                    letterSpacing: 4,
                    color: ShadowColors.portalBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ENTER DUNGEON',
                  style: ShadowTextTheme.mono(14, color: ShadowColors.textPrimary),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  width: 60,
                  color: ShadowColors.portalBlue.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'The System has judged you worthy.',
                  style: ShadowTextTheme.body(14, color: ShadowColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
