import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/features/quests/daily_quest.dart';
import 'package:solo_levelling_app/features/quests/quest_provider.dart';
import 'package:solo_levelling_app/features/quests/active_workout_screen.dart';

class DashboardQuestTile extends ConsumerStatefulWidget {
  final DailyQuest quest;
  final int targetReps;
  final DateTime selectedDate;

  const DashboardQuestTile({
    super.key,
    required this.quest,
    required this.targetReps,
    required this.selectedDate,
  });

  @override
  ConsumerState<DashboardQuestTile> createState() => _DashboardQuestTileState();
}

class _DashboardQuestTileState extends ConsumerState<DashboardQuestTile> {
  bool _isExpanded = false;
  late List<int> _sets;
  late List<bool> _completedSets;

  @override
  void initState() {
    super.initState();
    _initializeSets();
  }
  
  @override
  void didUpdateWidget(covariant DashboardQuestTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quest.id != widget.quest.id || oldWidget.targetReps != widget.targetReps) {
      _initializeSets();
    }
  }

  void _initializeSets() {
    _sets = [];
    if (widget.quest.id == 'run') {
      _sets.add(widget.targetReps);
    } else {
      int remaining = widget.targetReps;
      while (remaining > 0) {
        if (remaining >= 10) {
          _sets.add(10);
          remaining -= 10;
        } else {
          _sets.add(remaining);
          remaining = 0;
        }
      }
    }
    
    if (widget.quest.isCompleted) {
      _completedSets = List.filled(_sets.length, true);
    } else {
      _completedSets = List.filled(_sets.length, false);
      
      int current = widget.quest.currentReps;
      for (int i = 0; i < _sets.length; i++) {
        if (current >= _sets[i]) {
          _completedSets[i] = true;
          current -= _sets[i];
        } else if (current > 0) {
          break;
        }
      }
    }
  }

  void _toggleSet(int index) {
    if (_completedSets[index] || widget.quest.isCompleted) return;

    HapticFeedback.lightImpact();
    setState(() {
      _completedSets[index] = true;
    });

    final bool allDone = _completedSets.every((c) => c);
    
    ref.read(questProvider.notifier).updateReps(
      widget.quest.id, 
      _sets[index], 
      date: widget.selectedDate
    );

    if (allDone && !widget.quest.isCompleted) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.quest.title.toUpperCase()} COMPLETED',
            style: ShadowTextTheme.mono(12, color: ShadowColors.obsidian, weight: FontWeight.bold),
          ),
          backgroundColor: ShadowColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() {
        _isExpanded = false;
      });
    }
  }

  IconData _getIconForQuest(String id) {
    switch (id) {
      case 'pushups': return Icons.fitness_center_rounded;
      case 'situps': return Icons.accessibility_new_rounded;
      case 'squats': return Icons.sports_gymnastics_rounded;
      case 'run': return Icons.directions_run_rounded;
      default: return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.quest.isCompleted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ShadowColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? ShadowColors.success.withValues(alpha: 0.3) : ShadowColors.systemBorder,
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              if (isCompleted) return;
              HapticFeedback.selectionClick();
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _getIconForQuest(widget.quest.id),
                    color: isCompleted ? ShadowColors.textDisabled : ShadowColors.amethystLight,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.quest.title.toUpperCase(),
                          style: ShadowTextTheme.headline(18, color: isCompleted ? ShadowColors.textDisabled : ShadowColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.targetReps} ${widget.quest.id == "run" ? "km" : "reps"}',
                          style: ShadowTextTheme.mono(14, color: ShadowColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    const Icon(Icons.check_circle_rounded, color: ShadowColors.success, size: 28)
                  else
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, 
                      color: ShadowColors.textPrimary, 
                      size: 28
                    ),
                ],
              ),
            ),
          ),
          
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: _buildExpandedContent(),
            crossFadeState: _isExpanded && !isCompleted ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: ShadowColors.systemBorder),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final allQuests = ref.read(questProvider);
                final initialIndex = allQuests.indexWhere((q) => q.id == widget.quest.id);
                
                final completedReps = await Navigator.of(context).push<int>(
                  MaterialPageRoute(
                    builder: (_) => ActiveWorkoutScreen(
                      allQuests: allQuests,
                      initialIndex: initialIndex >= 0 ? initialIndex : 0,
                    ),
                  ),
                );
                
                if (completedReps != null && mounted) {
                  // If returned with more reps, update the provider
                  if (completedReps > widget.quest.currentReps) {
                    final int repsToAdd = completedReps - widget.quest.currentReps;
                    ref.read(questProvider.notifier).updateReps(
                      widget.quest.id,
                      repsToAdd,
                      date: widget.selectedDate
                    );
                    
                    if (completedReps >= widget.targetReps && !widget.quest.isCompleted) {
                      HapticFeedback.heavyImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${widget.quest.title.toUpperCase()} COMPLETED',
                            style: ShadowTextTheme.mono(12, color: ShadowColors.obsidian, weight: FontWeight.bold),
                          ),
                          backgroundColor: ShadowColors.success,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      setState(() {
                        _isExpanded = false;
                      });
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ShadowColors.amethyst.withValues(alpha: 0.2),
                side: const BorderSide(color: ShadowColors.amethyst, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'ENTER ACTIVE WORKOUT',
                style: ShadowTextTheme.mono(12, color: ShadowColors.amethystLight, weight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'OR QUICK TRACK',
            style: ShadowTextTheme.mono(10, color: ShadowColors.textSecondary, weight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(_sets.length, (index) {
              final isDone = _completedSets[index];
              return InkWell(
                onTap: () => _toggleSet(index),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isDone ? ShadowColors.success.withValues(alpha: 0.1) : ShadowColors.obsidian,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDone ? ShadowColors.success : ShadowColors.systemBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check_rounded, color: ShadowColors.success)
                        : Text(
                            '+${_sets[index]}',
                            style: ShadowTextTheme.headline(18, color: ShadowColors.amethystLight),
                          ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
