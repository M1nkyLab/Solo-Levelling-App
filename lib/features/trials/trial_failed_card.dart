import 'package:flutter/material.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';

class TrialFailedCard extends StatelessWidget {
  final VoidCallback onRetry;

  const TrialFailedCard({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ShadowColors.surface,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: ShadowColors.hpRed.withValues(alpha: 0.5),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: ShadowColors.hpRed,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'SYSTEM NOTIFICATION',
                  style: ShadowTextTheme.mono(12,
                      color: ShadowColors.hpRed, weight: FontWeight.bold, letterSpacing: 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'TRIAL FAILED.',
            style: ShadowTextTheme.headline(18, color: ShadowColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'The System waits for you to grow stronger. Re-evaluation is required to ascend.',
            style: ShadowTextTheme.body(14, color: ShadowColors.textSecondary),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: ShadowColors.hpRed.withValues(alpha: 0.1),
                foregroundColor: ShadowColors.hpRed,
                side: const BorderSide(color: ShadowColors.hpRed, width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
              ),
              child: Text(
                'RE-ENTER PORTAL',
                style: ShadowTextTheme.mono(14, weight: FontWeight.bold, letterSpacing: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
