import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo_levelling_app/features/quests/schedule_provider.dart';
import 'package:solo_levelling_app/features/auth/login_screen.dart';
import 'package:solo_levelling_app/features/auth/auth_provider.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';

import 'package:solo_levelling_app/features/skills/skill_tree_screen.dart';
import 'package:solo_levelling_app/features/player/shadow_gallery_screen.dart';

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
                      _buildMenuButton(
                        context, 
                        'SKILL TREE', 
                        Icons.account_tree_rounded, 
                        ShadowColors.amethyst,
                        () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SkillTreeScreen())),
                      ),
                      const SizedBox(height: 16),
                      _buildMenuButton(
                        context, 
                        'SHADOW ARMY', 
                        Icons.groups_rounded, 
                        ShadowColors.portalBlue,
                        () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ShadowGalleryScreen())),
                      ),
                      const SizedBox(height: 32),
                      _buildScheduleCard(context, ref),
                      const SizedBox(height: 48),
                      _buildLogoutButton(context, ref),
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

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: ShadowColors.surface,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: ShadowTextTheme.headline(14, color: ShadowColors.textPrimary, letterSpacing: 2),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        color: ShadowColors.obsidian,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: ShadowColors.obsidian,
      pinned: true,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ShadowColors.amethystLight, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'HUNTER STATUS',
        style: ShadowTextTheme.headline(16, letterSpacing: 2),
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, WidgetRef ref) {
    final scheduleState = ref.watch(scheduleProvider);
    final schedule = scheduleState.days;
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      decoration: BoxDecoration(
        color: ShadowColors.surface,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: ShadowColors.systemBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month_rounded, color: ShadowColors.amethystLight, size: 20),
                const SizedBox(width: 12),
                Text(
                  'WORKOUT PROTOCOLS',
                  style: ShadowTextTheme.headline(14, color: ShadowColors.textPrimary, weight: FontWeight.bold, letterSpacing: 1.5),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final dayNum = index + 1;
                final isSelected = schedule.contains(dayNum);
                
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(scheduleProvider.notifier).toggleDay(dayNum);
                      },
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected ? ShadowColors.amethyst.withValues(alpha: 0.1) : ShadowColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(
                              color: isSelected ? ShadowColors.amethyst : ShadowColors.systemBorder,
                              width: 1.0,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              days[index],
                              style: ShadowTextTheme.mono(
                                14,
                                color: isSelected ? ShadowColors.textPrimary : ShadowColors.textDisabled,
                                weight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
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
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          HapticFeedback.mediumImpact();
          // 1. Trigger Supabase logout
          await ref.read(authProvider.notifier).logout();
          
          // 2. Explicitly navigate to LoginScreen and clear entire stack
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        icon: const Icon(Icons.link_off_rounded, size: 18),
        label: Text('TERMINATE SESSION', style: ShadowTextTheme.mono(14, weight: FontWeight.bold, letterSpacing: 2)),
        style: OutlinedButton.styleFrom(
          foregroundColor: ShadowColors.hpRed,
          side: const BorderSide(color: ShadowColors.hpRed, width: 1.0),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        ),
      ),
    );
  }
}
