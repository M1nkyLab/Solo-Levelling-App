import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';

class QuestCompleteScreen extends StatelessWidget {
  const QuestCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShadowColors.obsidian,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ShadowColors.amethyst.withValues(alpha: 0.5),
                boxShadow: [
                  BoxShadow(color: ShadowColors.amethyst.withValues(alpha: 0.5), blurRadius: 100),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00B4FF).withValues(alpha: 0.3),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF00B4FF).withValues(alpha: 0.3), blurRadius: 100),
                ],
              ),
            ),
          ),
          // Modal Content
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xCC1A1A2E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF00B4FF), width: 2),
                boxShadow: const [
                  BoxShadow(color: Color(0x4D00B4FF), blurRadius: 30, spreadRadius: 5),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Checkmark Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00B4FF).withValues(alpha: 0.2),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Color(0xFF00B4FF),
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'QUEST COMPLETED',
                    style: ShadowTextTheme.headline(24, color: const Color(0xFF00B4FF), letterSpacing: 2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'DAILY PREPARATION',
                    style: ShadowTextTheme.body(14, color: ShadowColors.textDisabled, letterSpacing: 1),
                  ),
                  const SizedBox(height: 32),
                  // Rewards List
                  _buildRewardRow('EXP', '+500', const Color(0xFF00B4FF)),
                  const SizedBox(height: 16),
                  _buildRewardRow('POINTS', '+10', ShadowColors.xpGold),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4FF),
                        foregroundColor: ShadowColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'CONTINUE',
                        style: ShadowTextTheme.headline(18, letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: ShadowTextTheme.headline(16, color: ShadowColors.textSecondary),
        ),
        Text(
          value,
          style: ShadowTextTheme.headline(20, color: color),
        ),
      ],
    );
  }
}
