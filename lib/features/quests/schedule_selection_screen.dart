import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'schedule_provider.dart';
import 'quest_provider.dart';
import '../auth/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import 'dashboard_screen.dart';

class ScheduleSelectionScreen extends ConsumerStatefulWidget {
  const ScheduleSelectionScreen({super.key});

  @override
  ConsumerState<ScheduleSelectionScreen> createState() => _ScheduleSelectionScreenState();
}

class _ScheduleSelectionScreenState extends ConsumerState<ScheduleSelectionScreen> {
  final List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  void _handleContinue() async {
    HapticFeedback.mediumImpact();
    await ref.read(scheduleProvider.notifier).confirmSchedule();
    
    // Refresh quests based on new schedule
    final authState = ref.read(authProvider);
    final scheduleState = ref.read(scheduleProvider);
    
    if (authState.user != null) {
      final now = DateTime.now();
      debugPrint('ScheduleSelection: Refreshing quests for today (${now.weekday}). Schedule: ${scheduleState.days}');
      ref.read(selectedDateProvider.notifier).state = now;
      await ref.read(questProvider.notifier).fetchQuests(
        authState.user!.id, 
        date: now,
        localSchedule: scheduleState.days,
      );
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final schedule = ref.watch(scheduleProvider);
    final days = schedule.days;

    return Scaffold(
      backgroundColor: ShadowColors.obsidian,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    '[SYSTEM NOTIFICATION]',
                    style: ShadowTextTheme.mono(14, color: ShadowColors.amethystLight, weight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'DEFINE YOUR TRAINING CYCLE',
                    style: ShadowTextTheme.headline(24, weight: FontWeight.w900).copyWith(
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'The System requires a designated training schedule to monitor your growth. Failure to maintain the cycle will result in penalties.',
                    style: ShadowTextTheme.body(14, color: ShadowColors.textSecondary),
                  ),
                  const SizedBox(height: 40),
                  
                  Expanded(
                    child: ListView.builder(
                      itemCount: 7,
                      itemBuilder: (context, index) {
                        final int dayNum = index + 1;
                        final bool isSelected = days.contains(dayNum);
                        
                        return _DayTile(
                          label: _weekdays[index],
                          isSelected: isSelected,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(scheduleProvider.notifier).toggleDay(dayNum);
                          },
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: days.isEmpty ? null : _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ShadowColors.amethyst,
                        disabledBackgroundColor: ShadowColors.surfaceAlt.withValues(alpha: 0.3),
                      ),
                      child: Text(
                        days.isEmpty ? 'SELECT AT LEAST ONE DAY' : 'INITIALIZE SCHEDULE',
                        style: ShadowTextTheme.mono(14, weight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: ShadowColors.obsidian,
          child: Stack(
            children: [
              Positioned(
                top: -100,
                right: -50,
                child: _glowOrb(color: ShadowColors.amethyst, size: 400, opacity: 0.08),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glowOrb({required Color color, required double size, required double opacity}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected 
            ? ShadowColors.amethyst.withValues(alpha: 0.15) 
            : ShadowColors.surfaceAlt.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ShadowColors.amethyst : ShadowColors.amethyst.withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: ShadowColors.amethyst.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ] : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: ShadowTextTheme.mono(16, 
                  color: isSelected ? ShadowColors.textPrimary : ShadowColors.textSecondary,
                  weight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: ShadowColors.amethyst, size: 24)
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ShadowColors.textDisabled.withValues(alpha: 0.3), width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
