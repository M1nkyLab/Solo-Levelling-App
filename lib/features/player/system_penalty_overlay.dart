import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';

class SystemPenaltyOverlay extends StatefulWidget {
  final int expLost;
  final VoidCallback onDismiss;

  const SystemPenaltyOverlay({
    super.key,
    required this.expLost,
    required this.onDismiss,
  });

  @override
  State<SystemPenaltyOverlay> createState() => _SystemPenaltyOverlayState();
}

class _SystemPenaltyOverlayState extends State<SystemPenaltyOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shake = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticIn));

    _controller.repeat(period: const Duration(milliseconds: 2000));
    
    // Harsh Haptics
    HapticFeedback.vibrate();
    Future.delayed(const Duration(milliseconds: 200), () => HapticFeedback.vibrate());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Darkened blurred background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: Colors.black.withValues(alpha: 0.9),
              ),
            ),
          ),
          
          Center(
            child: AnimatedBuilder(
              animation: _shake,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shake.value, 0),
                  child: child,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: ShadowColors.hpRed,
                      size: 80,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'PENALTY IMPOSED',
                      style: ShadowTextTheme.headline(28, weight: FontWeight.w900).copyWith(
                        color: ShadowColors.hpRed,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 1,
                      width: double.infinity,
                      color: ShadowColors.hpRed.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Scheduled protocol breached. The System does not tolerate weakness.',
                      style: ShadowTextTheme.body(16, color: ShadowColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    Text(
                      '-${widget.expLost} EXP',
                      style: ShadowTextTheme.mono(48, weight: FontWeight.bold).copyWith(
                        color: ShadowColors.hpRed,
                      ),
                    ),
                    const SizedBox(height: 60),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onDismiss,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ShadowColors.hpRed,
                          foregroundColor: ShadowColors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('I WILL MAINTAIN THE CYCLE'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
