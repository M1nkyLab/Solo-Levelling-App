import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';

class PenaltyCompleteScreen extends StatelessWidget {
  const PenaltyCompleteScreen({super.key});

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
                color: ShadowColors.hpRed.withValues(alpha: 0.3),
                boxShadow: [
                  BoxShadow(color: ShadowColors.hpRed.withValues(alpha: 0.3), blurRadius: 100),
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
                color: const Color(0xCC1A0000),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: ShadowColors.hpRed, width: 2),
                boxShadow: [
                  BoxShadow(color: ShadowColors.hpRed.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 5),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ShadowColors.hpRed.withValues(alpha: 0.2),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: ShadowColors.hpRed,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'PENALTY SURVIVED',
                    style: ShadowTextTheme.headline(24, color: ShadowColors.hpRed, letterSpacing: 2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'YOU HAVE ESCAPED THE ZONE',
                    style: ShadowTextTheme.body(14, color: ShadowColors.textDisabled, letterSpacing: 1),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ShadowColors.hpRed,
                        foregroundColor: ShadowColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'RETURN',
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
}
