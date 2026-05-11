import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';

class DailyQuestCompletedOverlay extends StatefulWidget {
  final int expReward;
  final VoidCallback onDismiss;

  const DailyQuestCompletedOverlay({
    super.key,
    required this.expReward,
    required this.onDismiss,
  });

  @override
  State<DailyQuestCompletedOverlay> createState() => _DailyQuestCompletedOverlayState();
}

class _DailyQuestCompletedOverlayState extends State<DailyQuestCompletedOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<double> _blur;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.05).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_controller);

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    _blur = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _controller.forward();
    HapticFeedback.heavyImpact();
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
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // ── Blurred Backdrop ──────────────────────────────────────────
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: _blur.value, sigmaY: _blur.value),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.85 * _opacity.value),
                  ),
                ),
              ),

              // ── Content ───────────────────────────────────────────────────
              Center(
                child: FadeTransition(
                  opacity: _opacity,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ShadowColors.success.withValues(alpha: 0.5),
                            ShadowColors.success.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: ShadowColors.success.withValues(alpha: 0.2),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          color: ShadowColors.obsidian,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ── Header ─────────────────────────────────────────────
                            Text(
                              '[ SYSTEM ALERT ]',
                              style: ShadowTextTheme.mono(14, 
                                color: ShadowColors.success, 
                                weight: FontWeight.bold,
                                letterSpacing: 3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'DAILY QUEST COMPLETED',
                              textAlign: TextAlign.center,
                              style: ShadowTextTheme.headline(24, weight: FontWeight.w900).copyWith(
                                color: ShadowColors.textPrimary,
                                height: 1.1,
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // ── Status Info ────────────────────────────────────────
                            _buildInfoRow('STATUS', 'VERIFIED', ShadowColors.success),
                            const SizedBox(height: 12),
                            _buildInfoRow('REWARD', '+${widget.expReward} EXP', ShadowColors.xpGold),
                            
                            const SizedBox(height: 40),
                            
                            // ── Continue Button ────────────────────────────────────
                            _ContinueButton(onPressed: widget.onDismiss),
                          ],
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
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ShadowColors.surfaceAlt.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ShadowColors.glassBorder.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: ShadowTextTheme.mono(10, color: ShadowColors.textDisabled)),
          Text(
            value, 
            style: ShadowTextTheme.mono(14, color: color, weight: FontWeight.bold).copyWith(
              shadows: [
                Shadow(color: color.withValues(alpha: 0.5), blurRadius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _ContinueButton({required this.onPressed});

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onPressed();
      },
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (context, child) {
          final glowColor = ShadowColors.success.withValues(alpha: 0.3 + (0.3 * _pulseCtrl.value));
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: ShadowColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ShadowColors.success.withValues(alpha: 0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: glowColor,
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Text(
                'CONTINUE',
                style: ShadowTextTheme.mono(16, color: ShadowColors.success, weight: FontWeight.bold).copyWith(
                  letterSpacing: 4,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
