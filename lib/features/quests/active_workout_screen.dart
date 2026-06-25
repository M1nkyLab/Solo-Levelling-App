import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/features/quests/daily_quest.dart';
import 'package:solo_levelling_app/features/quests/quest_complete_screen.dart' as solo_levelling_app_qc;

class ActiveWorkoutScreen extends StatefulWidget {
  final List<DailyQuest> allQuests;
  final int initialIndex;

  const ActiveWorkoutScreen({
    super.key,
    required this.allQuests,
    required this.initialIndex,
  });

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late int _currentIndex;
  int _completedReps = 0;
  final int _repsPerSet = 10;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _completedReps = currentQuest.currentReps;
  }

  DailyQuest get currentQuest => widget.allQuests[_currentIndex];
  // Simplification for UI demonstration: Assuming player level 1 target reps calculation or getting it passed in
  // Let's just use 100 for now, or base it on the quest.
  int get targetReps => 100; // Hardcoded for demo, would ideally pass a map of target reps

  void _logSet() {
    if (_completedReps >= targetReps || _isPaused) return;
    
    HapticFeedback.heavyImpact();
    setState(() {
      _completedReps += _repsPerSet;
      if (_completedReps > targetReps) {
        _completedReps = targetReps;
      }
    });

    if (_completedReps >= targetReps) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const solo_levelling_app_qc.QuestCompleteScreen()),
      );
    }
  }

  void _completeWorkout() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(_completedReps);
  }

  void _switchQuest(int newIndex) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = newIndex;
      _completedReps = currentQuest.currentReps;
      _isPaused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_completedReps / targetReps).clamp(0.0, 1.0);
    final bool isDone = _completedReps >= targetReps;

    return Scaffold(
      backgroundColor: ShadowColors.obsidian,
      appBar: AppBar(
        title: Text(currentQuest.title.toUpperCase()),
      ),
      body: Column(
        children: [
          // Top Half: Video Placeholder
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ShadowColors.surfaceAlt,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: ShadowColors.systemBorder),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.play_circle_outline, size: 64, color: ShadowColors.textDisabled),
                  Positioned(
                    bottom: 16,
                    child: Text(
                      '[ INSTRUCTIONAL VIDEO FEED: ${currentQuest.title.toUpperCase()} ]',
                      style: ShadowTextTheme.mono(12, color: ShadowColors.textDisabled),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Up Next Carousel
          SizedBox(
            height: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('UP NEXT', style: ShadowTextTheme.mono(12, color: ShadowColors.textSecondary, weight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: widget.allQuests.length,
                    itemBuilder: (context, index) {
                      final quest = widget.allQuests[index];
                      final isSelected = index == _currentIndex;
                      return GestureDetector(
                        onTap: () => _switchQuest(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? ShadowColors.amethyst.withValues(alpha: 0.2) : ShadowColors.surfaceAlt,
                            border: Border.all(color: isSelected ? ShadowColors.amethyst : ShadowColors.systemBorder),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              quest.title.toUpperCase(),
                              style: ShadowTextTheme.mono(12, color: isSelected ? ShadowColors.amethystLight : ShadowColors.textDisabled),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Bottom Half: Rep Tracking UI
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ShadowColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: const Border(
                  top: BorderSide(color: ShadowColors.amethyst, width: 2),
                ),
                boxShadow: ShadowColors.systemPanelShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PROGRESS',
                        style: ShadowTextTheme.mono(14, color: ShadowColors.amethystLight, weight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, color: ShadowColors.textPrimary),
                        onPressed: () {
                          setState(() {
                            _isPaused = !_isPaused;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Dynamic Progress Bar
                  Stack(
                    children: [
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: ShadowColors.obsidian,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 12,
                        width: MediaQuery.of(context).size.width * 0.85 * progress,
                        decoration: BoxDecoration(
                          color: isDone ? ShadowColors.success : ShadowColors.amethyst,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: (isDone ? ShadowColors.success : ShadowColors.amethyst).withValues(alpha: 0.5),
                              blurRadius: 8,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Rep Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_completedReps / $targetReps REPS',
                        style: ShadowTextTheme.headline(32, color: ShadowColors.textPrimary),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: ShadowTextTheme.mono(24, color: ShadowColors.textSecondary),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Log Action Buttons
                  if (!isDone)
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: _isPaused ? null : _logSet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ShadowColors.amethyst.withValues(alpha: 0.2),
                          side: const BorderSide(color: ShadowColors.amethyst, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                        ),
                        child: Text(
                          _isPaused ? 'PAUSED' : 'LOG SET (+$_repsPerSet REPS)',
                          style: ShadowTextTheme.mono(16, color: ShadowColors.amethystLight, weight: FontWeight.bold, letterSpacing: 2),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: _completeWorkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ShadowColors.success.withValues(alpha: 0.2),
                          side: const BorderSide(color: ShadowColors.success, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                        ),
                        child: Text(
                          'COMPLETE WORKOUT',
                          style: ShadowTextTheme.mono(16, color: ShadowColors.success, weight: FontWeight.bold, letterSpacing: 2),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
