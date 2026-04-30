import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/schedule_provider.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: ShadowColors.voidDark,
      appBar: AppBar(
        backgroundColor: ShadowColors.obsidian,
        title: Text('HUNTER PROFILE', style: ShadowTextTheme.headline(16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScheduleCard(context, ref),
            const SizedBox(height: 24),
            // Add other profile sections here (Rank history, Gear, etc.)
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(scheduleProvider);
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ShadowColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ShadowColors.amethyst.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, color: ShadowColors.amethystLight, size: 20),
              const SizedBox(width: 10),
              Text(
                'WORKOUT SCHEDULE',
                style: ShadowTextTheme.mono(13, color: ShadowColors.textPrimary, weight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayNum = index + 1;
              final isSelected = schedule.contains(dayNum);
              
              return GestureDetector(
                onTap: () => ref.read(scheduleProvider.notifier).toggleDay(dayNum),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? ShadowColors.amethyst : const Color(0xFF1E1E1E),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: ShadowColors.amethyst.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      )
                    ] : [],
                    border: Border.all(
                      color: isSelected ? ShadowColors.amethystLight : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      days[index],
                      style: ShadowTextTheme.mono(
                        14,
                        color: isSelected ? Colors.white : ShadowColors.textDisabled,
                        weight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
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
