import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo_levelling_app/features/player/player_provider.dart';
import 'package:solo_levelling_app/features/quests/quest_provider.dart';
import 'package:solo_levelling_app/features/quests/schedule_provider.dart';
import 'package:solo_levelling_app/features/quests/daily_quest.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/features/player/player_status_header.dart';
import 'package:solo_levelling_app/features/quests/quest_tracker.dart';
import 'package:solo_levelling_app/features/quests/daily_countdown_timer.dart';
import 'package:solo_levelling_app/features/trials/trial_portal_card.dart';
import 'package:solo_levelling_app/features/trials/trial_failed_card.dart';
import 'package:solo_levelling_app/features/player/system_penalty_overlay.dart';
import 'package:solo_levelling_app/features/trials/trial_screen.dart';
import 'package:solo_levelling_app/features/player/profile_screen.dart';

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
  int _penaltyExpLost = 0;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

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

    // Check for missed workout penalty on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scheduleState = ref.read(scheduleProvider);
      final lost = ref.read(playerProvider.notifier).checkSchedulePenalty(scheduleState.days);
      if (lost > 0) {
        setState(() => _penaltyExpLost = lost);
      }
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _vibrate() {
    HapticFeedback.lightImpact();
  }

  void _enterTrial() {
    _vibrate();
    ref.read(playerProvider.notifier).startTrial();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TrialScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final quests = ref.watch(questProvider);
    final scheduleState = ref.watch(scheduleProvider);

    final bool showTrialPortal = player.isTrialAvailable && !player.hasFailedTrial;
    final bool allDone = quests.isNotEmpty && quests.every((q) => q.isCompleted);

    return Scaffold(
      backgroundColor: ShadowColors.blackTransparent,
      body: Stack(
        children: [
          _buildBackground(),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildAppBar(),
                
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      
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

                      FadeTransition(
                        opacity: _staggeredAnims[1],
                        child: Center(
                          child: (allDone && !showTrialPortal)
                              ? _CompletionBanner(expReward: player.level * 25)
                              : const DailyCountdownTimer(),
                        ),
                      ),
                      
                      const SizedBox(height: 32),

                      if (player.hasFailedTrial) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TrialFailedCard(onRetry: _enterTrial),
                        ),
                        const SizedBox(height: 24),
                      ],

                      _buildQuestSectionHeader(quests, showTrialPortal, scheduleState.days),
                      
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                if (showTrialPortal)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TrialPortalCard(onTap: _enterTrial),
                    ),
                  )
                else if (allDone)
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100), // Spacing when list is gone
                  )
                else
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

          if (_penaltyExpLost > 0)
            SystemPenaltyOverlay(
              expLost: _penaltyExpLost,
              onDismiss: () => setState(() => _penaltyExpLost = 0),
            ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: ShadowColors.obsidian, // True black base
          child: Stack(
            children: [
              Positioned(
                top: -80,
                left: -60,
                child: _glowOrb(
                  color: ShadowColors.amethyst,
                  size: 300,
                  opacity: 0.12,
                ),
              ),
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
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: false,
      floating: true,
      snap: true,
      expandedHeight: 0,
      title: Text(
        'SHADOW LEVELING',
        style: ShadowTextTheme.headline(15),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ShadowColors.surfaceAlt.withValues(alpha: 0.5),
                border: Border.all(
                  color: ShadowColors.amethyst.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Text(
                '👤', // Hunter Emoji
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestSectionHeader(List<DailyQuest> quests, bool isTrial, List<int> scheduledDays) {
    final today = DateTime.now();
    final dateStr =
        '${_weekday(today.weekday)}, ${today.day} ${_month(today.month)}';

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
                    color: isTrial ? ShadowColors.portalBlue : ShadowColors.amethyst,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: (isTrial ? ShadowColors.portalBlue : ShadowColors.amethyst)
                            .withValues(alpha: 0.6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isTrial ? 'URGENT: RANK UP TRIAL' : 'DAILY QUEST',
                    style: ShadowTextTheme.headline(18).copyWith(
                      color: isTrial ? ShadowColors.portalBlue : null,
                    ),
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
        ],
      ),
    );
  }

  Widget _buildStaggeredQuestTracker(DailyQuest quest, int index) {
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
            target: quest.getActualReps(ref.read(playerProvider).level),
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

class _CompletionBanner extends ConsumerStatefulWidget {
  final int expReward;
  const _CompletionBanner({required this.expReward});

  @override
  ConsumerState<_CompletionBanner> createState() => _CompletionBannerState();
}

class _CompletionBannerState extends ConsumerState<_CompletionBanner> with SingleTickerProviderStateMixin {
  Timer? _timer;
  Duration _nextWorkoutIn = Duration.zero;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _calculateNext();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _calculateNext());
    
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _calculateNext() {
    final now = DateTime.now();
    final scheduleState = ref.read(scheduleProvider);
    final schedule = scheduleState.days;
    if (schedule.isEmpty) {
      if (mounted) setState(() => _nextWorkoutIn = Duration.zero);
      return;
    }

    Duration? found;
    for (int i = 1; i <= 7; i++) {
      final next = now.add(Duration(days: i));
      if (schedule.contains(next.weekday)) {
        final nextStart = DateTime(next.year, next.month, next.day, 0, 0, 0);
        found = nextStart.difference(now);
        break;
      }
    }

    if (mounted) {
      setState(() {
        _nextWorkoutIn = found ?? Duration.zero;
      });
    }
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
    const accentColor = ShadowColors.portalBlue;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Side Accents
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(width: 4, color: accentColor),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: accentColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '[SYSTEM ALERT] DAILY QUEST COMPLETED',
                          style: ShadowTextTheme.mono(14, color: accentColor, weight: FontWeight.bold).copyWith(
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(color: accentColor.withValues(alpha: 0.5), blurRadius: 10),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'The System has verified your progress. Your physical capabilities have exceeded the previous day\'s limits.',
                    style: ShadowTextTheme.body(12, color: ShadowColors.textPrimary.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 24),
                  
                  // Stats / Rewards Row
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: ShadowColors.surfaceAlt.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ShadowColors.glassBorder.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem('REWARD', '+${widget.expReward} EXP', ShadowColors.xpGold),
                        _buildStatItem('STATUS', 'RECOVERED', ShadowColors.success),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Next Quest Timer
                  if (_nextWorkoutIn > Duration.zero)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AnimatedBuilder(
                              animation: _pulseCtrl,
                              builder: (context, child) {
                                return Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: accentColor.withValues(alpha: 0.3 + (0.7 * _pulseCtrl.value)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: accentColor.withValues(alpha: 0.5 * _pulseCtrl.value),
                                        blurRadius: 6,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'NEXT TRAINING CYCLE INITIALIZING IN:',
                              style: ShadowTextTheme.mono(10, color: ShadowColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 18),
                          child: Text(
                            _formatDuration(_nextWorkoutIn),
                            style: ShadowTextTheme.mono(24, color: accentColor, weight: FontWeight.bold).copyWith(
                              letterSpacing: 2,
                              shadows: [
                                Shadow(color: accentColor.withValues(alpha: 0.3), blurRadius: 10),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ShadowTextTheme.mono(9, color: ShadowColors.textDisabled)),
        const SizedBox(height: 2),
        Text(value, style: ShadowTextTheme.mono(13, color: color, weight: FontWeight.bold)),
      ],
    );
  }
}
