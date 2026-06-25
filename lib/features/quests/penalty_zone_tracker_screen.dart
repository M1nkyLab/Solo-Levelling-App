import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/core/widgets/penalty_warning_dialog.dart';
import 'package:solo_levelling_app/core/widgets/system_button.dart';
import 'package:solo_levelling_app/features/quests/penalty_complete_screen.dart' as solo_levelling_app_pc;

class PenaltyZoneTrackerScreen extends StatefulWidget {
  const PenaltyZoneTrackerScreen({super.key});

  @override
  State<PenaltyZoneTrackerScreen> createState() => _PenaltyZoneTrackerScreenState();
}

class _PenaltyZoneTrackerScreenState extends State<PenaltyZoneTrackerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _tryExit() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => PenaltyWarningDialog(
        onPrimaryPressed: () {
          // Exit the zone (return to dashboard, but penalty remains)
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(context).pop(); // Close PenaltyZoneTrackerScreen
        },
        onSecondaryPressed: () {
          // Stay in zone
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShadowColors.penaltyBgDark,
      body: Stack(
        children: [
          // Background pulsing effect
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      ShadowColors.penaltyRed.withValues(alpha: _pulseAnimation.value),
                      Colors.transparent,
                    ],
                    radius: 1.5,
                    center: Alignment.center,
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ShadowColors.penaltyRed),
                        onPressed: _tryExit,
                      ),
                      const Expanded(
                        child: Text(
                          'PENALTY ZONE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Cinzel',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: ShadowColors.penaltyRed,
                            letterSpacing: 4,
                            shadows: [Shadow(color: ShadowColors.penaltyRed, blurRadius: 10)],
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance for back button
                    ],
                  ),
                ),

                const Spacer(),

                // Center warning graphic
                const Icon(
                  Icons.report_problem_outlined,
                  size: 100,
                  color: ShadowColors.penaltyRed,
                ),
                const SizedBox(height: 16),
                Text(
                  'SURVIVE.',
                  textAlign: TextAlign.center,
                  style: ShadowTextTheme.headline(36, color: ShadowColors.textPrimary, letterSpacing: 8).copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Time remaining: 04:00:00',
                  textAlign: TextAlign.center,
                  style: ShadowTextTheme.mono(18, color: ShadowColors.textSecondary),
                ),

                const Spacer(),

                // Penalty Quest Box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: ShadowColors.penaltyBgLight.withValues(alpha: 0.1),
                      border: Border.all(color: ShadowColors.penaltyRed, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: ShadowColors.penaltyRed.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PENALTY QUEST',
                          style: ShadowTextTheme.mono(14, color: ShadowColors.penaltyRed, weight: FontWeight.bold, letterSpacing: 2),
                        ),
                        const SizedBox(height: 16),
                        _buildQuestRow(Icons.directions_run_rounded, 'RUN 10 KM', '0 / 10'),
                        const SizedBox(height: 12),
                        _buildQuestRow(Icons.favorite_outline_rounded, 'SURVIVE CENTIPEDES', 'IN PROGRESS'),
                      ],
                    ),
                  ),
                ),
                
                // Action Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(bottom: 32),
                  child: SystemButton(
                    label: 'ACCEPT FATE',
                    color: ShadowColors.penaltyRed,
                    textColor: ShadowColors.textPrimary,
                    borderColor: ShadowColors.penaltyRed,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // In a real flow, starts the tracking.
                      // For now, simulate finishing the penalty quest:
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const solo_levelling_app_pc.PenaltyCompleteScreen()),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestRow(IconData icon, String label, String status) {
    return Row(
      children: [
        Icon(icon, color: ShadowColors.textPrimary, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: ShadowTextTheme.body(16, color: ShadowColors.textPrimary, weight: FontWeight.bold),
          ),
        ),
        Text(
          status,
          style: ShadowTextTheme.mono(14, color: ShadowColors.textSecondary),
        ),
      ],
    );
  }
}
