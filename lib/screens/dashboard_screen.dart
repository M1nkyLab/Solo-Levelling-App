import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/quest_tracker.dart';
import '../widgets/smoky_progress_bar.dart';

// ─────────────────────────────────────────────
//  Quest state model (plain class, swap for
//  Riverpod/Bloc when adding persistence)
// ─────────────────────────────────────────────
class _QuestState {
  int pushupsDone;
  final int pushupsTarget;
  int situpsDone;
  final int situpsTarget;
  int squatsDone;
  final int squatsTarget;
  int runSteps;           // stored as tenths of a km (1 step = 0.1 km)
  final int runTarget;    // also in tenths

  _QuestState({
    this.pushupsDone = 45,
    this.pushupsTarget = 100,
    this.situpsDone = 30,
    this.situpsTarget = 100,
    this.squatsDone = 0,
    this.squatsTarget = 100,
    this.runSteps = 3,
    this.runTarget = 30,   // 3.0 km
  });

  bool get allDone =>
      pushupsDone >= pushupsTarget &&
      situpsDone >= situpsTarget &&
      squatsDone >= squatsTarget &&
      runSteps >= runTarget;
}

// ─────────────────────────────────────────────
//  Dashboard Screen
// ─────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  // ── Player data (replace with Supabase model later) ──
  final String _username   = 'Sung Jin-Woo';
  final String _title      = 'E-Rank';
  final int    _level      = 1;
  final int    _currentHp  = 80;
  final int    _maxHp      = 100;
  final int    _currentMp  = 35;
  final int    _maxMp      = 50;

  late final _QuestState _quest;
  late AnimationController _headerAnim;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _quest = _QuestState();
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

  void _bump(VoidCallback change) {
    HapticFeedback.lightImpact();
    setState(change);
  }

  @override
  Widget build(BuildContext context) {
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
                    const SizedBox(height: 20),
                    _buildPlayerHeader(),
                    const SizedBox(height: 8),
                    _buildHpMpBars(),
                    const SizedBox(height: 32),
                    _buildQuestSection(),
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
          onPressed: () {},
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  Player identity header
  // ─────────────────────────────────────────────
  Widget _buildPlayerHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar circle with glow ring
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ShadowColors.surface,
              border: Border.all(color: ShadowColors.amethyst, width: 2),
              boxShadow: [
                BoxShadow(
                  color: ShadowColors.amethyst.withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.person_rounded,
                color: ShadowColors.amethystLight, size: 32),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: ShadowColors.amethyst.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: ShadowColors.amethyst.withOpacity(0.5)),
                  ),
                  child: Text(
                    _title,
                    style: ShadowTextTheme.mono(10,
                        color: ShadowColors.amethystLight,
                        weight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 4),
                Text(_username,
                    style: ShadowTextTheme.headline(20)),
              ],
            ),
          ),

          // Level badge
          Column(
            children: [
              Text('LEVEL',
                  style: ShadowTextTheme.mono(9,
                      color: ShadowColors.textSecondary)),
              Text(
                '$_level',
                style: ShadowTextTheme.mono(32,
                    color: ShadowColors.xpGold, weight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HP / MP progress bars
  // ─────────────────────────────────────────────
  Widget _buildHpMpBars() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _StatBar(
            label: 'HP',
            current: _currentHp,
            max: _maxHp,
            color: ShadowColors.hpRed,
            icon: Icons.favorite_rounded,
          ),
          const SizedBox(height: 10),
          _StatBar(
            label: 'MP',
            current: _currentMp,
            max: _maxMp,
            color: ShadowColors.icyCyan,
            icon: Icons.water_drop_rounded,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Daily Quest section
  // ─────────────────────────────────────────────
  Widget _buildQuestSection() {
    final today = DateTime.now();
    final dateStr =
        '${_weekday(today.weekday)}, ${today.day} ${_month(today.month)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      color: ShadowColors.amethyst.withOpacity(0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text('DAILY QUEST', style: ShadowTextTheme.headline(18)),
              const Spacer(),
              Text(dateStr,
                  style: ShadowTextTheme.mono(11,
                      color: ShadowColors.textSecondary)),
            ],
          ),

          // Completion badge
          if (_quest.allDone) ...[
            const SizedBox(height: 12),
            _CompletionBanner(),
          ],

          const SizedBox(height: 16),

          // Trackers
          QuestTracker(
            label: 'Push-ups',
            icon: Icons.fitness_center_rounded,
            completed: _quest.pushupsDone,
            target: _quest.pushupsTarget,
            onAdd: () => _bump(() {
              if (_quest.pushupsDone < _quest.pushupsTarget) {
                _quest.pushupsDone++;
              }
            }),
            onSubtract: () => _bump(() {
              if (_quest.pushupsDone > 0) _quest.pushupsDone--;
            }),
          ),

          QuestTracker(
            label: 'Sit-ups',
            icon: Icons.self_improvement_rounded,
            completed: _quest.situpsDone,
            target: _quest.situpsTarget,
            onAdd: () => _bump(() {
              if (_quest.situpsDone < _quest.situpsTarget) {
                _quest.situpsDone++;
              }
            }),
            onSubtract: () => _bump(() {
              if (_quest.situpsDone > 0) _quest.situpsDone--;
            }),
          ),

          QuestTracker(
            label: 'Squats',
            icon: Icons.directions_run_rounded,
            completed: _quest.squatsDone,
            target: _quest.squatsTarget,
            onAdd: () => _bump(() {
              if (_quest.squatsDone < _quest.squatsTarget) {
                _quest.squatsDone++;
              }
            }),
            onSubtract: () => _bump(() {
              if (_quest.squatsDone > 0) _quest.squatsDone--;
            }),
          ),

          QuestTracker(
            label: 'Running',
            icon: Icons.route_rounded,
            completed: _quest.runSteps,
            target: _quest.runTarget,
            unit: 'km',
            isDecimal: true,
            onAdd: () => _bump(() {
              if (_quest.runSteps < _quest.runTarget) _quest.runSteps++;
            }),
            onSubtract: () => _bump(() {
              if (_quest.runSteps > 0) _quest.runSteps--;
            }),
          ),
        ],
      ),
    );
  }

  String _weekday(int d) =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1];

  String _month(int m) => [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ][m - 1];
}

// ─────────────────────────────────────────────
//  HP / MP stat bar widget (uses SmokyProgressBar)
// ─────────────────────────────────────────────
class _StatBar extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  final Color color;
  final IconData icon;

  const _StatBar({
    required this.label,
    required this.current,
    required this.max,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        SizedBox(
          width: 28,
          child: Text(
            label,
            style: ShadowTextTheme.mono(11,
                color: color, weight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SmokyProgressBar(
            currentValue: current,
            maxValue: max,
            color: color,
            height: 10,
            particleCount: 20,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$current/$max',
          style: ShadowTextTheme.mono(11, color: ShadowColors.textSecondary),
        ),
      ],
    );
  }
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
        color: ShadowColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: ShadowColors.success.withOpacity(0.4)),
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
