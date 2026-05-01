import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/schedule_provider.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: ShadowColors.obsidian,
      body: Stack(
        children: [
          // ── Background ──────────────────────────────────────────
          _buildBackground(),

          // ── Content ─────────────────────────────────────────────
          CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.6, 0.7),
            radius: 1.2,
            colors: [
              ShadowColors.glassAmethyst,
              ShadowColors.obsidian,
            ],
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      pinned: true,
      elevation: 0,
      centerTitle: true,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: ShadowColors.obsidian.withValues(alpha: 0.5)),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ShadowColors.amethystLight),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'HUNTER PROFILE',
        style: ShadowTextTheme.headline(16).copyWith(
          shadows: [
            const Shadow(color: ShadowColors.amethyst, blurRadius: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(scheduleProvider);
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: ShadowColors.weightlessShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ShadowColors.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ShadowColors.glassBorder.withValues(alpha: 0.2)),
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
                          color: isSelected ? ShadowColors.amethyst : const Color(0xFF1E1E1E).withValues(alpha: 0.5),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: ShadowColors.amethyst.withValues(alpha: 0.5),
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
          ),
        ),
      ),
    );
  }
}
