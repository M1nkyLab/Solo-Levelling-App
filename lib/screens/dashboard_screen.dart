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

    // ── PERF: Increased stagger steps to 8 to avoid clamping 
    // too many items to the same animation index.
    for (int i = 0; i < 8; i++) {
      final double start = i * 0.08;
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
    final playerLevel = ref.watch(playerProvider.select((p) => p.level));
    final playerXp = ref.watch(playerProvider.select((p) => p.currentExp));
    final playerMaxXp = ref.watch(playerProvider.select((p) => p.maxExp));
    final playerHp = ref.watch(playerProvider.select((p) => p.currentHp));
    final playerMaxHp = ref.watch(playerProvider.select((p) => p.maxHp));
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
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildAppBar(),
                
                // ── Header & Status (Lazily composed) ──────────────────
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
                            level:      playerLevel,
                            currentXp:  playerXp,
                            maxXp:      playerMaxXp,
                            currentHp:  playerHp,
                            maxHp:      playerMaxHp,
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

                      // ── 3. Quest Section Header (Staggered Step 2) ──
                      _buildQuestSectionHeader(quests),
                      
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // ── 4. Quest Trackers (Lazily loaded) ─────────────────
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.builder(
                    itemCount: quests.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildStaggeredQuestTracker(quests[index], index),
                      );
                    },
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Background: ambient glowing orbs
  // ─────────────────────────────────────────────
  Widget _buildBackground() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            // Top-left amethyst orb
            Positioned(
              top: -80,
              left: -60,
              child: _glowOrb(
                color: ShadowColors.amethyst,
                size: 300,
                opacity: 0.12,
              ),
            ),
            // Bottom-right blue orb
            Positioned(
              bottom: -100,
              right: -80,
              child: _glowOrb(
                color: ShadowColors.portalBlue,
                size: 350,
                opacity: 0.09,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Sliver app bar
  // ─────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: false,
      floating: true,
      snap: true,
      expandedHeight: 0,
      title: Row(
        children: [
          // Logo / brand mark
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: ShadowColors.amethyst.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: ShadowColors.amethyst.withValues(alpha: 0.5),
              ),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: ShadowColors.amethyst,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'SHADOW LEVELING',
            style: ShadowTextTheme.headline(15),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _vibrate,
          icon: const Icon(Icons.notifications_none_rounded,
              color: ShadowColors.textSecondary),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  Quest section header
  // ─────────────────────────────────────────────
  Widget _buildQuestSectionHeader(List<DailyQuest> quests) {
    final today = DateTime.now();
    final dateStr =
        '${_weekday(today.weekday)}, ${today.day} ${_month(today.month)}';

    final allDone = quests.isNotEmpty && quests.every((DailyQuest q) => q.isCompleted);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            const _CompletionBanner(),
          ],
        ],
      ),
    );
  }

  Widget _buildStaggeredQuestTracker(DailyQuest quest, int index) {
    // ── PERF: Animation index now staggers across a larger range (3..7).
    final animIndex = (3 + index).clamp(0, _staggeredAnims.length - 1);
    
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _staggeredAnims[animIndex],
        child: SlideTransition(
          position: _staggeredAnims[animIndex].drive(
            Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero),
          ),
          child: QuestTracker(
            label: quest.title,
            icon: _getIconForQuest(quest.id),
            completed: quest.currentReps,
            target: quest.getActualReps(ref.read(playerProvider).rank),
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

  Widget _glowOrb({
    required Color color,
    required double size,
    required double opacity,
  }) {
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

// ─────────────────────────────────────────────
//  All-done completion banner
// ─────────────────────────────────────────────
class _CompletionBanner extends StatelessWidget {
  const _CompletionBanner();

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
