import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        // High-intensity portal pulse
        final borderOpacity = 0.4 + (0.4 * _pulseController.value);

        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            widget.onTap();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: ShadowColors.surface,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: ShadowColors.portalBlue.withValues(alpha: borderOpacity),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.auto_awesome_mosaic_rounded,
                  color: ShadowColors.portalBlue,
                  size: 40,
                ),
                const SizedBox(height: 20),
                Text(
                  'RANK UP TRIAL',
                  style: ShadowTextTheme.headline(24, weight: FontWeight.bold).copyWith(
                    letterSpacing: 4,
                    color: ShadowColors.portalBlue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'INITIALIZE PORTAL ACCESS',
                  style: ShadowTextTheme.mono(10, color: ShadowColors.textPrimary, weight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 1,
                  width: 40,
                  color: ShadowColors.portalBlue.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 24),
                Text(
                  'The System has judged you worthy of evaluation. Enter the gate to ascend.',
                  style: ShadowTextTheme.body(13, color: ShadowColors.textSecondary),
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
