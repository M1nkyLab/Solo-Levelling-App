import 'dart:async';
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
  late int _totalBossHp;
  DateTime _lastProgressTime = DateTime.now();
  bool _showSystemWarning = false;

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

    _totalBossHp = _targets.values.reduce((a, b) => a + b);

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
          
          // Check for intensity warning (no progress for 30s)
          final inactiveDuration = DateTime.now().difference(_lastProgressTime).inSeconds;
          if (inactiveDuration >= 30 && !_showSystemWarning) {
            _showSystemWarning = true;
            HapticFeedback.vibrate();
          } else if (inactiveDuration < 30 && _showSystemWarning) {
            _showSystemWarning = false;
          }
        });
      } else {
        _timer.cancel();
        _handleTrialEnd(failed: true);
      }
    });
  }

  void _updateProgress(String id, int val) {
    setState(() {
      _progress[id] = val;
      _lastProgressTime = DateTime.now();
      _showSystemWarning = false;
    });
    _checkCompletion();
  }

  void _checkCompletion() {
    if (_progress['pushups']! >= _targets['pushups']! &&
        _progress['situps']! >= _targets['situps']! &&
        _progress['squats']! >= _targets['squats']! &&
        _progress['run']! >= _targets['run']!) {
      _handleTrialEnd(failed: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int currentTotalProgress = _progress.values.reduce((a, b) => a + b);
    final double bossHpPercent = ((_totalBossHp - currentTotalProgress) / _totalBossHp).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: ShadowColors.obsidian,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildTrialHeader(bossHpPercent),
                if (_showSystemWarning) _buildIntensityWarning(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // PUSH-UPS via Eclipse Tracker
                      EclipseShadowTracker(
                        targetReps: _targets['pushups']!,
                        accentColor: ShadowColors.hpRed,
                        onRepRegistered: (val) => _updateProgress('pushups', val),
                      ),
                      const SizedBox(height: 24),

                      // SIT-UPS via Proximity Hover Tracker
                      ProximityHoverTracker(
                        targetReps: _targets['situps']!,
                        accentColor: ShadowColors.hpRed,
                        onRepRegistered: (val) => _updateProgress('situps', val),
                      ),
                      const SizedBox(height: 24),
                      
                      // SQUATS via Passive Sensor Tracker
                      PassiveSensorTracker(
                        type: PassiveQuestType.squats,
                        targetReps: _targets['squats']!,
                        accentColor: ShadowColors.hpRed,
                        onComplete: () => _updateProgress('squats', _targets['squats']!),
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
                        onAdd: () => _updateProgress('run', (_progress['run']! + 1).clamp(0, _targets['run']!)),
                        onLongAdd: () => _updateProgress('run', (_progress['run']! + 10).clamp(0, _targets['run']!)),
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

  Widget _buildTrialHeader(double bossHpPercent) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          Text(
            'RANK UP TRIAL',
            style: ShadowTextTheme.headline(16, weight: FontWeight.bold)
                .copyWith(color: ShadowColors.hpRed, letterSpacing: 4),
          ),
          const SizedBox(height: 16),
          _buildBossHpBar(bossHpPercent),
          const SizedBox(height: 16),
          Text(
            _formatTime(_secondsRemaining),
            style: ShadowTextTheme.mono(32, weight: FontWeight.bold)
                .copyWith(color: ShadowColors.hpRed, letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildBossHpBar(double percent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DUNGEON BOSS',
              style: ShadowTextTheme.mono(10, color: ShadowColors.hpRed, weight: FontWeight.bold),
            ),
            Text(
              '${(percent * 100).toInt()}%',
              style: ShadowTextTheme.mono(10, color: ShadowColors.hpRed, weight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(
            color: ShadowColors.hpRed.withValues(alpha: 0.1),
            border: Border.all(color: ShadowColors.hpRed.withValues(alpha: 0.5), width: 1),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percent,
            child: Container(
              decoration: const BoxDecoration(
                color: ShadowColors.hpRed,
                boxShadow: [
                  BoxShadow(color: ShadowColors.hpRed, blurRadius: 10, spreadRadius: -2),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleTrialEnd({required bool failed}) {
    _timer.cancel();
    if (failed) {
      ref.read(playerProvider.notifier).failTrial();
      Navigator.of(context).pop();
    } else {
      setState(() {
        _isQuestComplete = true;
      });
      HapticFeedback.heavyImpact();
    }
  }

  String _formatTime(int seconds) {
    final int mins = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showGiveUpWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ShadowColors.surface,
        title: Text('ABANDON TRIAL?', style: ShadowTextTheme.headline(18, color: ShadowColors.hpRed)),
        content: Text('Abandoning the trial will result in immediate failure and penalty.', 
          style: ShadowTextTheme.body(14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('RESUME', style: ShadowTextTheme.mono(14, color: ShadowColors.textPrimary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleTrialEnd(failed: true);
            },
            child: Text('ABANDON', style: ShadowTextTheme.mono(14, color: ShadowColors.hpRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildIntensityWarning() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: ShadowColors.hpRed.withValues(alpha: 0.2),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: ShadowColors.hpRed, size: 16),
            const SizedBox(width: 8),
            Text(
              'SYSTEM WARNING: INTENSITY DROPPING',
              style: ShadowTextTheme.mono(10, color: ShadowColors.hpRed, weight: FontWeight.bold, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGiveUpButton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: TextButton(
        onPressed: _showGiveUpWarning,
        child: Text(
          'ABANDON PROTOCOL',
          style: ShadowTextTheme.mono(12, color: ShadowColors.textDisabled, weight: FontWeight.bold)
              .copyWith(letterSpacing: 1),
        ),
      ),
    );
  }
}
