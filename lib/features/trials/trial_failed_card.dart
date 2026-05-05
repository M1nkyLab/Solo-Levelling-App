import 'package:flutter/material.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';

class TrialFailedCard extends StatelessWidget {
  final VoidCallback onRetry;

  const TrialFailedCard({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ShadowColors.glassAmethystCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ShadowColors.hpRed.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ShadowColors.hpRed.withValues(alpha: 0.15),
            blurRadius: 16,
          ),
          ...ShadowColors.weightlessShadow,
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: ShadowColors.hpRed,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'SYSTEM NOTIFICATION',
                  style: ShadowTextTheme.mono(14,
                      color: ShadowColors.hpRed, weight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Trial Failed. The System waits for you to grow stronger. Try Again.',
            style: ShadowTextTheme.body(16, color: ShadowColors.textPrimary),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: ShadowColors.hpRed.withValues(alpha: 0.2),
                foregroundColor: ShadowColors.hpRed,
                side: const BorderSide(color: ShadowColors.hpRed, width: 1),
              ),
              child: const Text('RE-ENTER PORTAL'),
            ),
          ),
        ],
      ),
    );
  }
}
