import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';

class RankUpChallengeScreen extends StatelessWidget {
  const RankUpChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShadowColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ShadowColors.textPrimary),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SYSTEM ALERT',
                style: ShadowTextTheme.headline(32, color: ShadowColors.amethyst, letterSpacing: 4),
              ),
              const SizedBox(height: 16),
              Text(
                'YOU HAVE MET THE REQUIREMENTS FOR A RANK UP.',
                style: ShadowTextTheme.body(16, color: ShadowColors.textSecondary, letterSpacing: 1),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: ShadowColors.surfaceAlt,
                  border: Border.all(color: ShadowColors.amethyst),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: ShadowColors.amethyst.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: -5),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'JOB CHANGE QUEST',
                      style: ShadowTextTheme.headline(24, color: ShadowColors.textPrimary, letterSpacing: 2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Survive the dungeon and prove your worth. Failure means death.',
                      style: ShadowTextTheme.body(14, color: ShadowColors.textDisabled),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    // Navigate to actual trial
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ShadowColors.amethyst,
                    foregroundColor: ShadowColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'ACCEPT QUEST',
                    style: ShadowTextTheme.headline(20, letterSpacing: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
