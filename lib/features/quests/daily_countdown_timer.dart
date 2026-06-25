import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:solo_levelling_app/features/player/player_provider.dart';
import 'package:solo_levelling_app/features/quests/quest_provider.dart';
import 'package:solo_levelling_app/features/quests/schedule_provider.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';

class DailyCountdownTimer extends ConsumerStatefulWidget {
  const DailyCountdownTimer({super.key});

  @override
  ConsumerState<DailyCountdownTimer> createState() => _DailyCountdownTimerState();
}

class _DailyCountdownTimerState extends ConsumerState<DailyCountdownTimer> {
  late final Timer _timer;
  late final ValueNotifier<Duration> _remainingTime;

  @override
  void initState() {
    super.initState();
    _remainingTime = ValueNotifier(_calculateTimeRemaining());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Duration _calculateTimeRemaining() {
    final now = DateTime.now();
    final scheduleState = ref.read(scheduleProvider);
    final schedule = scheduleState.days;

    if (schedule.isEmpty) return Duration.zero;

    // ── 1. If today is scheduled ──
    if (schedule.contains(now.weekday)) {
      final midnight = DateTime(now.year, now.month, now.day, 23, 59, 59);
      final diff = midnight.difference(now);
      return diff.isNegative ? Duration.zero : diff;
    }

    // ── 2. Find next scheduled day ──
    for (int i = 1; i <= 7; i++) {
      final next = now.add(Duration(days: i));
      if (schedule.contains(next.weekday)) {
        final nextMidnight = DateTime(next.year, next.month, next.day, 0, 0, 0);
        return nextMidnight.difference(now);
      }
    }

    return Duration.zero;
  }

  void _tick() {
    final newRemaining = _calculateTimeRemaining();
    
    // Penalty only triggers if today was a scheduled day and time ran out
    final scheduleState = ref.read(scheduleProvider);
    final schedule = scheduleState.days;
    final now = DateTime.now();
    
    if (schedule.contains(now.weekday) && newRemaining == Duration.zero && _remainingTime.value != Duration.zero) {
      _executePenalty();
    }
    
    _remainingTime.value = newRemaining;
  }

  void _executePenalty() {
    final quests = ref.read(questProvider);
    final allDone = quests.isNotEmpty && quests.every((q) => q.isCompleted);

    if (!allDone) {
      debugPrint('SYSTEM NOTIFICATION: DAILY QUEST FAILED. EXECUTING PENALTY...');
      
      ref.read(playerProvider.notifier).executePenalty();
      ref.read(questProvider.notifier).resetFailedQuests();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: ShadowColors.hpRed,
            content: Text(
              'PENALTY QUEST TRIGGERED: STATS REDUCED',
              style: ShadowTextTheme.mono(12, color: Colors.white, weight: FontWeight.bold),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _remainingTime.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hh = twoDigits(d.inHours);
    final mm = twoDigits(d.inMinutes.remainder(60));
    final ss = twoDigits(d.inSeconds.remainder(60));
    return '$hh : $mm : $ss';
  }

  @override
  Widget build(BuildContext context) {
    final quests = ref.watch(questProvider);
    final allDone = quests.isNotEmpty && quests.every((q) => q.isCompleted);
    final scheduleState = ref.watch(scheduleProvider);
    final schedule = scheduleState.days;
    final now = DateTime.now();
    final isTodayScheduled = schedule.contains(now.weekday);

    final isCompletedState = allDone || !isTodayScheduled;
    final color = isCompletedState ? ShadowColors.success : const Color(0xFFFF3366);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isCompletedState ? color.withValues(alpha: 0.1) : const Color(0xAA1A0000),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isCompletedState ? Icons.check_circle_outline_rounded : Icons.timer_outlined,
                color: color,
                size: 20,
                shadows: [],
              ),
              const SizedBox(width: 8),
              Text(
                isCompletedState ? 'DAILY QUEST COMPLETED' : 'TIME UNTIL PENALTY',
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isCompletedState ? color : const Color(0xFFFF88AA),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          ValueListenableBuilder<Duration>(
            valueListenable: _remainingTime,
            builder: (context, duration, _) {
              if (isCompletedState) {
                return const SizedBox.shrink();
              }
              return Text(
                _formatDuration(duration),
                style: GoogleFonts.exo2(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF3366),
                  shadows: [],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
