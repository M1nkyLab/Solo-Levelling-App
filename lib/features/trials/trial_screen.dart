import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo_levelling_app/features/player/player_provider.dart';
import 'package:solo_levelling_app/core/logic/system_logic.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/features/player/player_rank.dart';
import 'package:solo_levelling_app/features/quests/quest_tracker.dart';
import 'package:solo_levelling_app/features/quests/passive_sensor_tracker.dart';
import 'package:solo_levelling_app/features/quests/eclipse_shadow_tracker.dart';
import 'package:solo_levelling_app/features/quests/quest_complete_overlay.dart';
import 'package:solo_levelling_app/features/quests/proximity_hover_tracker.dart';

class TrialScreen extends ConsumerStatefulWidget {
  const TrialScreen({super.key});

  @override
  ConsumerState<TrialScreen> createState() => _TrialScreenState();
}

class _TrialScreenState extends ConsumerState<TrialScreen> {
  late Timer _timer;
  int _secondsRemaining = 3600; // 60 minutes
  
  final Map<String, int> _progress = {
    'pushups': 0,
    'situps': 0,
    'squats': 0,
    'run': 0,
  };

  late Map<String, int> _targets;

  bool _isQuestComplete = false;
  late PlayerRank _oldRank;
  late PlayerRank _newRank;

  @override
  void initState() {
    super.initState();
    _startTimer();
    
    final player = ref.read(playerProvider);
    final currentRank = player.rank;
    _oldRank = currentRank;
    
    // Get trial requirements from SystemLogic
    final reqs = SystemLogic.getTrialRequirements(currentRank);
    _targets = {
      'pushups': reqs.pushups,
      'situps': reqs.situps,
      'squats': reqs.squats,
      'run': reqs.running,
    };

    final currentRankIndex = PlayerRank.values.indexOf(currentRank);
    _newRank = currentRankIndex < PlayerRank.values.length - 1
        ? PlayerRank.values[currentRankIndex + 1]
        : currentRank;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer.cancel();
        _handleTrialEnd(failed: true);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _handleTrialEnd({required bool failed}) {
    if (failed) {
      ref.read(playerProvider.notifier).failTrial();
      if (mounted) Navigator.of(context).pop();
    } else {
      _timer.cancel();
      setState(() {
        _isQuestComplete = true;
      });
    }
  }

  void _checkCompletion() {
    if (_progress['pushups']! >= _targets['pushups']! &&
        _progress['situps']! >= _targets['situps']! &&
        _progress['squats']! >= _targets['squats']! &&
        _progress['run']! >= _targets['run']!) {
      _handleTrialEnd(failed: false);
    }
  }

  void _showGiveUpWarning() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ShadowColors.obsidian.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ShadowColors.hpRed, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_rounded, color: ShadowColors.hpRed, size: 64),
                const SizedBox(height: 16),
                Text(
                  'WARNING',
                  style: ShadowTextTheme.headline(24, weight: FontWeight.bold)
                      .copyWith(color: ShadowColors.hpRed),
                ),
                const SizedBox(height: 16),
                Text(
                  'Abandoning the trial will result in severe penalties. Do you wish to flee?',
                  style: ShadowTextTheme.body(16, color: ShadowColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ShadowColors.textSecondary,
                          side: const BorderSide(color: ShadowColors.textDisabled),
                        ),
                        child: const Text('CONTINUE FIGHTING'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          _handleTrialEnd(failed: true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ShadowColors.hpRed,
                          foregroundColor: ShadowColors.textPrimary,
                        ),
                        child: const Text('FLEE'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShadowColors.obsidian,
      body: Stack(
        children: [
          // Ambient Red Glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    ShadowColors.hpRed.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildTrialHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // PUSH-UPS via Eclipse Tracker
                      EclipseShadowTracker(
                        targetReps: _targets['pushups']!,
                        accentColor: ShadowColors.hpRed,
                        onRepRegistered: (val) {
                          setState(() => _progress['pushups'] = val);
                          _checkCompletion();
                        },
                      ),
                      const SizedBox(height: 24),

                      // SIT-UPS via Proximity Hover Tracker
                      ProximityHoverTracker(
                        targetReps: _targets['situps']!,
                        accentColor: ShadowColors.hpRed,
                        onRepRegistered: (val) {
                          setState(() => _progress['situps'] = val);
                          _checkCompletion();
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // SQUATS via Passive Sensor Tracker
                      PassiveSensorTracker(
                        type: PassiveQuestType.squats,
                        targetReps: _targets['squats']!,
                        accentColor: ShadowColors.hpRed,
                        onComplete: () {
                          setState(() => _progress['squats'] = _targets['squats']!);
                          _checkCompletion();
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // RUNNING via Manual Tracker
                      QuestTracker(
                        label: 'RUNNING',
                        icon: Icons.directions_run_rounded,
                        completed: _progress['run']!,
                        target: _targets['run']!,
                        unit: 'km',
                        isDecimal: true,
                        accentColor: ShadowColors.hpRed,
                        onAdd: () {
                          setState(() => _progress['run'] = (_progress['run']! + 1).clamp(0, _targets['run']!));
                          _checkCompletion();
                        },
                        onLongAdd: () {
                          setState(() => _progress['run'] = (_progress['run']! + 10).clamp(0, _targets['run']!));
                          _checkCompletion();
                        },
                      ),
                    ],
                  ),
                ),
                _buildGiveUpButton(),
              ],
            ),
          ),

          if (_isQuestComplete)
            RankUpOverlay(
              oldRank: _oldRank,
              newRank: _newRank,
              onDismiss: () {
                ref.read(playerProvider.notifier).completeTrial();
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTrialHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          Text(
            'RANK UP TRIAL',
            style: ShadowTextTheme.headline(14, weight: FontWeight.bold)
                .copyWith(color: ShadowColors.hpRed, letterSpacing: 4),
          ),
          const SizedBox(height: 8),
          Text(
            _formatTime(_secondsRemaining),
            style: ShadowTextTheme.mono(48, weight: FontWeight.bold)
                .copyWith(color: ShadowColors.hpRed),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 100,
            decoration: BoxDecoration(
              color: ShadowColors.hpRed,
              boxShadow: [
                BoxShadow(color: ShadowColors.hpRed.withValues(alpha: 0.5), blurRadius: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiveUpButton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: TextButton(
        onPressed: _showGiveUpWarning,
        child: Text(
          'GIVE UP',
          style: ShadowTextTheme.mono(14, color: ShadowColors.textDisabled)
              .copyWith(decoration: TextDecoration.underline),
        ),
      ),
    );
  }
}
