import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';

/// A custom "Mana Bar" Slider for rapid, smooth rep logging.
/// Features: Glassmorphism, Neon Glow, Haptic Ticks, and Pulse Animation.
class RepSlider extends StatefulWidget {
  final int initialValue;
  final int maxValue;
  final String label;
  final ValueChanged<int> onChanged;

  const RepSlider({
    super.key,
    required this.initialValue,
    required this.maxValue,
    required this.label,
    required this.onChanged,
  });

  @override
  State<RepSlider> createState() => _RepSliderState();
}

class _RepSliderState extends State<RepSlider> with SingleTickerProviderStateMixin {
  late double _currentValue;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue.toDouble();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.05), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleUpdate(double detailsX, double maxWidth) {
    final double newValue = (detailsX / maxWidth * widget.maxValue)
        .clamp(0.0, widget.maxValue.toDouble());
    
    final int oldInt = _currentValue.round();
    final int newInt = newValue.round();

    if (oldInt != newInt) {
      setState(() {
        _currentValue = newValue;
      });
      widget.onChanged(newInt);

      // Haptic tick every 10 reps
      if (newInt % 10 == 0 && newInt != 0 && newInt != oldInt) {
        HapticFeedback.selectionClick();
      }

      // Completion pulse
      if (newInt == widget.maxValue && oldInt != widget.maxValue) {
        _pulseController.forward(from: 0);
        HapticFeedback.heavyImpact();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Real-time Feedback Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label.toUpperCase(),
              style: ShadowTextTheme.mono(12, color: ShadowColors.textSecondary, weight: FontWeight.bold),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${_currentValue.round()}',
                    style: ShadowTextTheme.headline(18, weight: FontWeight.bold).copyWith(
                      color: _currentValue.round() == widget.maxValue 
                          ? ShadowColors.portalBlue 
                          : ShadowColors.amethystLight,
                    ),
                  ),
                  TextSpan(
                    text: ' / ${widget.maxValue} REPS',
                    style: ShadowTextTheme.mono(12, color: ShadowColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // The Slider Bar
        ScaleTransition(
          scale: _pulseAnimation,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onPanUpdate: (details) => _handleUpdate(details.localPosition.dx, constraints.maxWidth),
                onTapDown: (details) => _handleUpdate(details.localPosition.dx, constraints.maxWidth),
                child: Container(
                  height: 32,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF1E1E1E).withValues(alpha: 0.6),
                    border: Border.all(
                      color: ShadowColors.glassBorder.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // Glassmorphic Track Blur
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(color: Colors.transparent),
                        ),
                        
                        // Active Fill (Neon Gradient)
                        FractionallySizedBox(
                          widthFactor: _currentValue / widget.maxValue,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  ShadowColors.amethyst,
                                  ShadowColors.portalBlue,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: ShadowColors.portalBlue.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Interaction Thumb (Visual Only)
                        Positioned(
                          left: (constraints.maxWidth * (_currentValue / widget.maxValue)) - 16,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ShadowColors.textPrimary,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  blurRadius: 12,
                                ),
                              ],
                              border: Border.all(color: ShadowColors.obsidian, width: 4),
                            ),
                            child: const Center(
                              child: Icon(Icons.drag_indicator_rounded, size: 14, color: ShadowColors.obsidian),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
