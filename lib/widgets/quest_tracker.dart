import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'smoky_progress_bar.dart';

/// A single exercise tracker row used inside the Daily Quest section.
/// Updated with Antigravity Design: Glassmorphism & Weightlessness.
class QuestTracker extends StatelessWidget {
  final String label;
  final IconData icon;
  final int completed;
  final int target;
  final String unit;          // e.g. 'reps' or 'km'
  final bool isDecimal;       // true for run (0.5 km steps)
  final VoidCallback onAdd;
  final VoidCallback onSubtract;
  final VoidCallback? onLongAdd;
  final VoidCallback? onLongSubtract;

  const QuestTracker({
    super.key,
    required this.label,
    required this.icon,
    required this.completed,
    required this.target,
    required this.onAdd,
    required this.onSubtract,
    this.onLongAdd,
    this.onLongSubtract,
    this.unit = 'reps',
    this.isDecimal = false,
  });

  double get _progress =>
      target == 0 ? 0 : (completed / target).clamp(0.0, 1.0);

  bool get _isDone => completed >= target;

  Color get _accentColor {
    if (_isDone) return ShadowColors.success;
    if (_progress > 0.6) return ShadowColors.amethystLight;
    return ShadowColors.amethyst;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: ShadowColors.weightlessShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: ShadowColors.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isDone
                    ? ShadowColors.success.withValues(alpha: 0.4)
                    : ShadowColors.glassBorder.withValues(alpha: 0.2),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: icon + label + count + buttons ──
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: ShadowColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: _accentColor.withValues(alpha: 0.4), width: 1),
                      ),
                      child: Icon(icon, color: _accentColor, size: 20),
                    ),
                    const SizedBox(width: 12),

                    // Label + unit
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label.toUpperCase(),
                            style: ShadowTextTheme.mono(
                              11,
                              color: ShadowColors.textSecondary,
                              weight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Progress fraction
                          Text(
                            isDecimal
                                ? '${(completed / 10).toStringAsFixed(1)} / ${(target / 10).toStringAsFixed(1)} $unit'
                                : '$completed / $target $unit',
                            style: ShadowTextTheme.mono(
                              15,
                              color: _isDone
                                  ? ShadowColors.success
                                  : ShadowColors.textPrimary,
                              weight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Subtract button
                    _ControlButton(
                      icon: Icons.remove,
                      onTap: onSubtract,
                      onLongPress: onLongSubtract,
                      enabled: completed > 0,
                      color: ShadowColors.textSecondary,
                    ),
                    const SizedBox(width: 8),

                    // Add Rep button
                    _ControlButton(
                      icon: _isDone ? Icons.check_rounded : Icons.add_rounded,
                      onTap: _isDone ? () {} : onAdd,
                      onLongPress: _isDone ? null : onLongAdd,
                      enabled: !_isDone,
                      isDone: _isDone,
                      color: _isDone ? ShadowColors.success : ShadowColors.amethyst,
                      isPrimary: true,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Smoky progress bar ──
                SmokyProgressBar(
                  currentValue: completed,
                  maxValue: target,
                  color: _accentColor,
                  height: 8,
                  particleCount: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final bool isDone;
  final Color color;
  final bool isPrimary;

  const _ControlButton({
    required this.icon,
    required this.onTap,
    this.onLongPress,
    required this.color,
    this.enabled = true,
    this.isDone = false,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = enabled || isDone;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      onLongPress: enabled ? onLongPress : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: ShadowColors.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? (isPrimary ? color : color.withValues(alpha: 0.4))
                : ShadowColors.textDisabled.withValues(alpha: 0.2),
            width: isPrimary ? 1.5 : 1,
          ),
          boxShadow: isPrimary && active
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 6,
                    spreadRadius: 0,
                  )
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 18,
          color: active ? color : ShadowColors.textDisabled,
        ),
      ),
    );
  }
}
