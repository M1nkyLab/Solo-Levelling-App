
import 'package:flutter/material.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';

class QuestTracker extends StatelessWidget {
  final String label;
  final IconData icon;
  final num completed;
  final num target;
  final String unit;          
  final bool isDecimal;       
  final Color? accentColor;    
  final VoidCallback onAdd;
  final VoidCallback? onLongAdd;
  final int index; // Added to show MODULE_0X

  const QuestTracker({
    super.key,
    required this.label,
    required this.icon,
    required this.completed,
    required this.target,
    required this.onAdd,
    this.onLongAdd,
    this.unit = 'reps',
    this.isDecimal = false,
    this.accentColor,
    this.index = 0,
  });

  bool get _isDone => completed >= target;

  @override
  Widget build(BuildContext context) {
    final statusColor = _isDone ? ShadowColors.xpGold : ShadowColors.amethyst;
    final moduleIndex = (index + 1).toString().padLeft(2, '0');
    final statusText = _isDone ? 'DONE' : 'ACTIVE';

    return GestureDetector(
      onTap: onAdd,
      onLongPress: onLongAdd,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: ShadowColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.2),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            // Checkmark Icon
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: statusColor,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  _isDone ? Icons.check : Icons.circle,
                  size: 14,
                  color: _isDone ? statusColor : Colors.transparent,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MODULE_$moduleIndex // $statusText',
                    style: ShadowTextTheme.mono(10, color: ShadowColors.textDisabled, weight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label.toUpperCase(),
                    style: ShadowTextTheme.headline(20, color: ShadowColors.textPrimary),
                  ),
                ],
              ),
            ),

            // Progress
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      isDecimal ? (completed / 10).toStringAsFixed(1) : completed.toInt().toString(),
                      style: ShadowTextTheme.headline(28, color: ShadowColors.textPrimary),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/ ${isDecimal ? (target / 10).toStringAsFixed(1) : target.toInt()} ${unit.toUpperCase()}',
                      style: ShadowTextTheme.mono(10, color: ShadowColors.textDisabled, weight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
