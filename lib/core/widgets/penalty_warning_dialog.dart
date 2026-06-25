import 'package:flutter/material.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/core/widgets/system_button.dart';

class PenaltyWarningDialog extends StatelessWidget {
  final String title;
  final String message;
  final String subMessage;
  final String primaryButtonLabel;
  final String secondaryButtonLabel;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSecondaryPressed;

  const PenaltyWarningDialog({
    super.key,
    this.title = 'SYSTEM WARNING',
    this.message = 'You can exit the screen, but you cannot escape the penalty you have to do.',
    this.subMessage = 'The penalty timer will continue to count down.',
    this.primaryButtonLabel = 'EXIT SCREEN',
    this.secondaryButtonLabel = 'STAY IN ZONE',
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: ShadowColors.penaltyBgDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ShadowColors.penaltyRed, width: 2),
          boxShadow: [
            BoxShadow(
              color: ShadowColors.penaltyRed.withValues(alpha: 0.4),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_rounded,
              color: ShadowColors.penaltyRed,
              size: 48,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: ShadowTextTheme.headline(20, color: ShadowColors.penaltyRed, letterSpacing: 1),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: ShadowTextTheme.body(18, color: ShadowColors.textPrimary, weight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              subMessage,
              style: ShadowTextTheme.body(14, color: ShadowColors.textSecondary, weight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SystemButton(
              label: primaryButtonLabel,
              color: ShadowColors.penaltyRed,
              textColor: ShadowColors.textPrimary,
              borderColor: ShadowColors.penaltyRed,
              onTap: onPrimaryPressed,
            ),
            const SizedBox(height: 16),
            SystemButton(
              label: secondaryButtonLabel,
              color: ShadowColors.penaltyBgLight,
              textColor: ShadowColors.penaltyRed,
              borderColor: ShadowColors.penaltyBgLight,
              onTap: onSecondaryPressed,
            ),
          ],
        ),
      ),
    );
  }
}
