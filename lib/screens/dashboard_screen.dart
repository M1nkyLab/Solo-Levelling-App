import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../logic/system_logic.dart';
import '../theme/app_theme.dart';
import '../widgets/player_status_header.dart';
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
  // ── Player data (mutable for state updates) ──
  final String _username   = 'Sung Jin-Woo';
  int    _level      = 9;
  int    _currentHp  = 80;
  int    _maxHp      = 100;
  int    _currentXp  = 340;
  int    _maxXp      = 480;

  late final _QuestState _quest;
  late AnimationController _headerAnim;
  late Animation<double> _fadeIn;

  // Track rewarded quests
  final Set<String> _rewardedQuests = {};
  bool _allDoneBonusClaimed = false;

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

  void _addXp(int amount) {
    setState(() {
      _currentXp += amount;
      while (_currentXp >= _maxXp) {
        _currentXp -= _maxXp;
        _level++;
        _maxXp = SystemLogic.xpToNextLevel(_level);
        // Bonus for leveling up
        _maxHp = SystemLogic.calculateMaxHp(vitality: _level); // simple scaling for now
        _currentHp = _maxHp;
      }
    });
  }

  void _checkQuestRewards() {
    // Individual quest rewards
    if (_quest.pushupsDone >= _quest.pushupsTarget && !_rewardedQuests.contains('pushups')) {
      _rewardedQuests.add('pushups');
      _addXp(100);
    }
    if (_quest.situpsDone >= _quest.situpsTarget && !_rewardedQuests.contains('situps')) {
      _rewardedQuests.add('situps');
      _addXp(100);
    }
    if (_quest.squatsDone >= _quest.squatsTarget && !_rewardedQuests.contains('squats')) {
      _rewardedQuests.add('squats');
      _addXp(100);
    }
    if (_quest.runSteps >= _quest.runTarget && !_rewardedQuests.contains('run')) {
      _rewardedQuests.add('run');
      _addXp(150);
    }

    // All-done bonus
    if (_quest.allDone && !_allDoneBonusClaimed) {
      _allDoneBonusClaimed = true;
      _addXp(500);
    }
  }

  void _bump(VoidCallback change) {
    HapticFeedback.lightImpact();
    setState(change);
    _checkQuestRewards();
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
                    const SizedBox(height: 12),
                    // ── Unified status header ──────────────────────────
                    PlayerStatusHeader(
                      level:      _level,
                      currentXp:  _currentXp,
                      maxXp:      _maxXp,
                      currentHp:  _currentHp,
                      maxHp:      _maxHp,
                    ),
                    const SizedBox(height: 24),
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
            onLongAdd: () => _bump(() {
              _quest.pushupsDone = (_quest.pushupsDone + 10).clamp(0, _quest.pushupsTarget);
            }),
            onLongSubtract: () => _bump(() {
              _quest.pushupsDone = (_quest.pushupsDone - 10).clamp(0, _quest.pushupsTarget);
            }),
          ),

          QuestTracker(
            label: 'Sit-ups',
            icon: Icons.accessibility_new_rounded,
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
            onLongAdd: () => _bump(() {
              _quest.situpsDone = (_quest.situpsDone + 10).clamp(0, _quest.situpsTarget);
            }),
            onLongSubtract: () => _bump(() {
              _quest.situpsDone = (_quest.situpsDone - 10).clamp(0, _quest.situpsTarget);
            }),
          ),

          QuestTracker(
            label: 'Squats',
            icon: Icons.sports_gymnastics_rounded,
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
            onLongAdd: () => _bump(() {
              _quest.squatsDone = (_quest.squatsDone + 10).clamp(0, _quest.squatsTarget);
            }),
            onLongSubtract: () => _bump(() {
              _quest.squatsDone = (_quest.squatsDone - 10).clamp(0, _quest.squatsTarget);
            }),
          ),

          QuestTracker(
            label: 'Running',
            icon: Icons.directions_run_rounded,
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
            onLongAdd: () => _bump(() {
              _quest.runSteps = (_quest.runSteps + 10).clamp(0, _quest.runTarget);
            }),
            onLongSubtract: () => _bump(() {
              _quest.runSteps = (_quest.runSteps - 10).clamp(0, _quest.runTarget);
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
