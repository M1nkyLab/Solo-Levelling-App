import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';

/// A massive, full-screen trigger zone for "Nose Tap" rep logging.
/// Optimized for floor-based exercises like Push-ups.
class NoseTapTracker extends StatefulWidget {
  final int targetReps;
  final int initialReps;
  final Color accentColor;
  final Function(int) onRepRegistered;
  final VoidCallback? onComplete;

  const NoseTapTracker({
    super.key,
    required this.targetReps,
    this.initialReps = 0,
    this.accentColor = ShadowColors.hpRed, // Default to Crimson for Trial feel
    required this.onRepRegistered,
    this.onComplete,
  });

  @override
  State<NoseTapTracker> createState() => _NoseTapTrackerState();
}

class _NoseTapTrackerState extends State<NoseTapTracker>
    with SingleTickerProviderStateMixin {
  late int _currentReps;
  DateTime _lastTapTime = DateTime.now();
  
  late AnimationController _flashController;
  late Animation<Color?> _flashAnimation;

  @override
  void initState() {
    super.initState();
    _currentReps = widget.initialReps;

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _flashAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.accentColor.withValues(alpha: 0.4),
    ).animate(CurvedAnimation(
      parent: _flashController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  void _handleTap() {
    final now = DateTime.now();
    
    // 300ms Debounce Logic to prevent accidental double-counts
    if (now.difference(_lastTapTime).inMilliseconds < 300) return;
    
    _lastTapTime = now;

    if (_currentReps < widget.targetReps) {
      setState(() {
        _currentReps++;
      });

      // Visceral Feedback: Haptics
      HapticFeedback.heavyImpact();

      // Visceral Feedback: Visual Flash
      _flashController.forward(from: 0).then((_) => _flashController.reverse());

      // Callback
      widget.onRepRegistered(_currentReps);

      // Completion Check
      if (_currentReps == widget.targetReps) {
        widget.onComplete?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _handleTap(),
      child: AnimatedBuilder(
        animation: _flashAnimation,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A), // Deep obsidian resting state
              border: Border.all(
                color: _flashAnimation.value ?? widget.accentColor.withValues(alpha: 0.1),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_flashAnimation.value ?? Colors.transparent).withValues(alpha: 0.2),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Glassmorphic background texture
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.0,
                        colors: [
                          widget.accentColor.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Active Flash Overlay
                Positioned.fill(
                  child: Container(color: _flashAnimation.value),
                ),

                // Content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'TAP SCREEN WITH NOSE',
                        style: ShadowTextTheme.mono(12, 
                          color: ShadowColors.textSecondary, 
                          weight: FontWeight.bold
                        ).copyWith(letterSpacing: 4),
                      ),
                      const SizedBox(height: 40),
                      
                      // Massive Rep Counter
                      Text(
                        '$_currentReps',
                        style: ShadowTextTheme.headline(120, weight: FontWeight.w900).copyWith(
                          color: _currentReps == widget.targetReps 
                              ? ShadowColors.portalBlue 
                              : ShadowColors.textPrimary,
                          height: 1,
                        ),
                      ),
                      
                      Text(
                        '/ ${widget.targetReps}',
                        style: ShadowTextTheme.mono(24, 
                          color: ShadowColors.textSecondary, 
                          weight: FontWeight.bold
                        ),
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Status Instruction
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: widget.accentColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app_rounded, 
                              color: widget.accentColor, 
                              size: 18
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'TRIGGER ZONE ACTIVE',
                              style: ShadowTextTheme.mono(10, 
                                color: widget.accentColor, 
                                weight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
