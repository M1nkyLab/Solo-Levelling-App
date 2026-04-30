import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DailyCountdownTimer extends StatefulWidget {
  const DailyCountdownTimer({super.key});

  @override
  State<DailyCountdownTimer> createState() => _DailyCountdownTimerState();
}

class _DailyCountdownTimerState extends State<DailyCountdownTimer> {
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
    final midnight = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final diff = midnight.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  void _tick() {
    final newRemaining = _calculateTimeRemaining();
    _remainingTime.value = newRemaining;
    
    if (newRemaining == Duration.zero) {
      _executePenalty();
    }
  }

  void _executePenalty() {
    debugPrint('SYSTEM NOTIFICATION: DAILY QUEST FAILED. EXECUTING PENALTY...');
    // TODO: Implement actual penalty logic (e.g., loss of XP, rank demotion)
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
    return ValueListenableBuilder<Duration>(
      valueListenable: _remainingTime,
      builder: (context, duration, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer_outlined, color: Colors.redAccent, size: 14),
              const SizedBox(width: 8),
              Text(
                'TIME REMAINING [ ${_formatDuration(duration)} ]',
                style: ShadowTextTheme.mono(
                  12,
                  color: Colors.redAccent,
                  weight: FontWeight.bold,
                ).copyWith(
                  shadows: [
                    const Shadow(
                      color: Colors.redAccent,
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
