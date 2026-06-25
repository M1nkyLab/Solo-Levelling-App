import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/features/quests/daily_quest.dart';
import 'package:solo_levelling_app/features/quests/quest_provider.dart';
import 'package:solo_levelling_app/features/player/player_provider.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final DailyQuest quest;

  const ActiveWorkoutScreen({super.key, required this.quest});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  late int targetReps;
  late List<int> sets;
  late List<bool> completedSets;

  @override
  void initState() {
    super.initState();
    final player = ref.read(playerProvider);
    targetReps = widget.quest.getActualReps(player.level);
    
    _initializeSets();
  }

  void _initializeSets() {
    sets = [];
    if (widget.quest.id == 'run') {
      // For running, just one big set
      sets.add(targetReps);
    } else {
      // Divide into sets of 10
      int remaining = targetReps;
      while (remaining > 0) {
        if (remaining >= 10) {
          sets.add(10);
          remaining -= 10;
        } else {
          sets.add(remaining);
          remaining = 0;
        }
      }
    }
    completedSets = List.filled(sets.length, false);
  }

  void _toggleSet(int index) {
    if (completedSets[index]) return; // Already completed

    HapticFeedback.lightImpact();
    setState(() {
      completedSets[index] = true;
    });

    if (completedSets.every((c) => c)) {
      _completeQuest();
    }
  }

  void _completeQuest() {
    HapticFeedback.heavyImpact();
    
    // Show local celebration first
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

    // Wait for the user to see the celebration, then update the global state
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        final selectedDate = ref.read(selectedDateProvider);
        ref.read(questProvider.notifier).updateReps(widget.quest.id, targetReps, date: selectedDate);
      }
    });
  }

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
        title: Text(
          widget.quest.title.toUpperCase(),
          style: ShadowTextTheme.headline(20, letterSpacing: 2),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Top Half: Video / Animation Placeholder
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ShadowColors.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ShadowColors.systemBorder),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_circle_outline_rounded,
                    color: ShadowColors.textDisabled.withValues(alpha: 0.5),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'INSTRUCTIONAL VIDEO PLACEHOLDER',
                    style: ShadowTextTheme.mono(10, color: ShadowColors.textDisabled),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Half: Set Tracker UI
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: ShadowColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                border: Border(
                  top: BorderSide(color: ShadowColors.amethyst, width: 2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PROGRESS TRACKER',
                      style: ShadowTextTheme.headline(16, color: ShadowColors.amethystLight, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView.builder(
                        itemCount: sets.length,
                        itemBuilder: (context, index) {
                          final reps = sets[index];
                          final isCompleted = completedSets[index];
                          
                          return GestureDetector(
                            onTap: () => _toggleSet(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: isCompleted 
                                    ? ShadowColors.amethyst.withValues(alpha: 0.2)
                                    : ShadowColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCompleted 
                                      ? ShadowColors.amethyst 
                                      : ShadowColors.systemBorder,
                                  width: isCompleted ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'SET ${index + 1}',
                                    style: ShadowTextTheme.mono(14, 
                                      color: isCompleted ? ShadowColors.amethystLight : ShadowColors.textSecondary,
                                      weight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '$reps ${widget.quest.id == "run" ? "km" : "reps"}',
                                    style: ShadowTextTheme.headline(18, 
                                      color: isCompleted ? ShadowColors.amethystLight : ShadowColors.textPrimary,
                                    ),
                                  ),
                                  Icon(
                                    isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                    color: isCompleted ? ShadowColors.amethyst : ShadowColors.textDisabled,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
