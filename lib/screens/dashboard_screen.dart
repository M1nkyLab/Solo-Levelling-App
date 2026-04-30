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
  late AnimationController _headerAnim;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _headerAnim.dispose();
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
      backgroundColor: ShadowColors.voidDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeIn,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // ── Unified status header ──────────────────────────
                    PlayerStatusHeader(
                      level:      player.level,
                      currentXp:  player.currentExp,
                      maxXp:      player.maxExp,
                      currentHp:  player.currentHp,
                      maxHp:      player.maxHp,
                    ),
                    const SizedBox(height: 24),
                    _buildQuestSection(player, quests),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  App bar
  // ─────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: ShadowColors.obsidian,
      pinned: true,
      elevation: 0,
      title: Text('SHADOW LEVELLING', style: ShadowTextTheme.headline(14)),
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
          // ── Timer & Date Row ──
          const Center(child: DailyCountdownTimer()),
          const SizedBox(height: 24),

          // Section header
          Row(
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

          // Completion badge
          if (allDone) ...[
            const SizedBox(height: 12),
            _CompletionBanner(),
          ],

          const SizedBox(height: 16),

          // Trackers
          for (final quest in quests)
            QuestTracker(
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
        ],
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
