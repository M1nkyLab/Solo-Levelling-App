import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/player_provider.dart';
import '../logic/quest_provider.dart';
import '../models/daily_quest.dart';
import '../models/player.dart';
import '../theme/app_theme.dart';
import '../widgets/player_status_header.dart';
import '../widgets/quest_tracker.dart';
import '../widgets/daily_countdown_timer.dart';
import 'profile_screen.dart';

// ─────────────────────────────────────────────
//  Dashboard Screen
// ─────────────────────────────────────────────
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  final List<Animation<double>> _staggeredAnims = [];

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Create 5 staggered steps for entry
    for (int i = 0; i < 5; i++) {
      final double start = i * 0.1;
      final double end = (start + 0.6).clamp(0.0, 1.0);
      _staggeredAnims.add(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    }

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _vibrate() {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final quests = ref.watch(questProvider);

    return Scaffold(
      backgroundColor: ShadowColors.obsidian,
      body: Stack(
        children: [
          // ── Parallax Background (Floating depth) ──────────────────
          _buildBackground(),

          // ── Main Content ──────────────────────────────────────────
          SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      
                      // ── 1. Status Header (Staggered Step 0) ──────────
                      FadeTransition(
                        opacity: _staggeredAnims[0],
                        child: SlideTransition(
                          position: _staggeredAnims[0].drive(
                            Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero),
                          ),
                          child: PlayerStatusHeader(
                            level:      player.level,
                            currentXp:  player.currentExp,
                            maxXp:      player.maxExp,
                            currentHp:  player.currentHp,
                            maxHp:      player.maxHp,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      // ── 2. Timer (Staggered Step 1) ─────────────────
                      FadeTransition(
                        opacity: _staggeredAnims[1],
                        child: const Center(child: DailyCountdownTimer()),
                      ),
                      
                      const SizedBox(height: 32),

                      // ── 3. Quest Section (Staggered Step 2+) ────────
                      _buildQuestSection(player, quests),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Parallax Background layer
  // ─────────────────────────────────────────────
  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.7, -0.6),
            radius: 1.2,
            colors: [
              ShadowColors.glassAmethyst,
              ShadowColors.obsidian,
            ],
          ),
        ),
        // ── PERF: BackdropFilter(blur:50) removed — the background is
        // fully opaque so blurring it had no visible effect but forced
        // an expensive GPU composite pass on every frame.
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  App bar
  // ─────────────────────────────────────────────
  Widget _buildAppBar() {
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
      title: Text(
        'SHADOW LEVELLING',
        style: ShadowTextTheme.headline(14).copyWith(
          shadows: [
            const Shadow(color: ShadowColors.amethyst, blurRadius: 8),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline_rounded,
              color: ShadowColors.amethystLight),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  Daily Quest section
  // ─────────────────────────────────────────────
  Widget _buildQuestSection(Player player, List<DailyQuest> quests) {
    final today = DateTime.now();
    final dateStr =
        '${_weekday(today.weekday)}, ${today.day} ${_month(today.month)}';

    final allDone = quests.every((DailyQuest q) => q.isCompleted);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header (Staggered Step 2)
          FadeTransition(
            opacity: _staggeredAnims[2],
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    color: ShadowColors.amethyst,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: ShadowColors.amethyst.withValues(alpha: 0.6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'DAILY QUEST',
                    style: ShadowTextTheme.headline(18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                Text(dateStr,
                    style: ShadowTextTheme.mono(11,
                        color: ShadowColors.textSecondary)),
              ],
            ),
          ),

          // Completion badge
          if (allDone) ...[
            const SizedBox(height: 12),
            _CompletionBanner(),
          ],

          const SizedBox(height: 16),

          // Trackers (Staggered Step 3+)
          for (int i = 0; i < quests.length; i++)
            _buildStaggeredQuestTracker(quests[i], player, i),
        ],
      ),
    );
  }

  Widget _buildStaggeredQuestTracker(DailyQuest quest, Player player, int index) {
    // Use animation 3 for the first quest, 4 for the rest (clamped)
    final animIndex = (3 + index).clamp(0, 4);
    
    return FadeTransition(
      opacity: _staggeredAnims[animIndex],
      child: SlideTransition(
        position: _staggeredAnims[animIndex].drive(
          Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero),
        ),
        child: QuestTracker(
          label: quest.title,
          icon: _getIconForQuest(quest.id),
          completed: quest.currentReps,
          target: quest.getActualReps(player.rank),
          unit: quest.id == 'run' ? 'km' : 'reps',
          isDecimal: quest.id == 'run',
          onAdd: () {
            _vibrate();
            ref.read(questProvider.notifier).updateReps(quest.id, 1);
          },
          onSubtract: () {
            _vibrate();
            ref.read(questProvider.notifier).updateReps(quest.id, -1);
          },
          onLongAdd: () {
            _vibrate();
            ref.read(questProvider.notifier).updateReps(quest.id, 10);
          },
          onLongSubtract: () {
            _vibrate();
            ref.read(questProvider.notifier).updateReps(quest.id, -10);
          },
        ),
      ),
    );
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

  String _weekday(int d) =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1];

  String _month(int m) => [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ][m - 1];
}

// ─────────────────────────────────────────────
//  All-done completion banner
// ─────────────────────────────────────────────
class _CompletionBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ShadowColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: ShadowColors.success.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded,
              color: ShadowColors.xpGold, size: 22),
          const SizedBox(width: 10),
          Text(
            'DAILY QUEST COMPLETE  +500 XP',
            style: ShadowTextTheme.mono(12,
                color: ShadowColors.success, weight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
