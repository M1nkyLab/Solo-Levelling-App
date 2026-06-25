import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo_levelling_app/features/player/player_provider.dart';
import 'package:solo_levelling_app/features/player/player.dart';
import 'package:solo_levelling_app/features/player/player_rank.dart';
import 'package:solo_levelling_app/features/quests/quest_provider.dart';
import 'package:solo_levelling_app/features/quests/schedule_provider.dart';
import 'package:solo_levelling_app/features/quests/daily_quest.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/features/player/player_status_header.dart';
import 'package:solo_levelling_app/features/quests/daily_countdown_timer.dart';
import 'package:solo_levelling_app/features/trials/trial_portal_card.dart';
import 'package:solo_levelling_app/features/trials/trial_failed_card.dart';
import 'package:solo_levelling_app/features/player/system_penalty_overlay.dart';
import 'package:solo_levelling_app/features/trials/trial_screen.dart';
import 'package:solo_levelling_app/features/auth/auth_provider.dart';
import 'package:solo_levelling_app/features/quests/quest_complete_overlay.dart';
import 'package:solo_levelling_app/features/quests/dashboard_quest_tile.dart';
import 'package:solo_levelling_app/features/player/character_avatar_widget.dart';
import 'package:solo_levelling_app/features/player/player_profile_screen.dart';
import 'package:solo_levelling_app/features/main/notification_screen.dart' as solo_levelling_app_notifications;
import 'package:solo_levelling_app/features/settings/settings_screen.dart' as solo_levelling_app_settings;

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

    // Initial quest fetch for the current date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      final selectedDate = ref.read(selectedDateProvider);
      final currentQuests = ref.read(questProvider);
      final schedule = ref.read(scheduleProvider);
      
      // Always fetch on startup to ensure sync, or at least if list is empty
      if (authState.user != null && currentQuests.isEmpty) {
        debugPrint('Dashboard: Initial quest fetch for ${selectedDate.weekday}. Schedule: ${schedule.days}');
        ref.read(questProvider.notifier).fetchQuests(
          authState.user!.id, 
          date: selectedDate,
          localSchedule: schedule.days,
        );
      }
    });

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
    final authState = ref.watch(authProvider);
    final player = ref.watch(playerProvider);
    final quests = ref.watch(questProvider);
    final scheduleState = ref.watch(scheduleProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final isLoading = ref.watch(questLoadingProvider);
    final questCompletionReward = ref.watch(questCompletionOverlayProvider);
    
    final now = DateTime.now();
    final bool isToday = selectedDate.year == now.year && 
                        selectedDate.month == now.month && 
                        selectedDate.day == now.day;
    
    final bool isScheduledDay = scheduleState.days.contains(selectedDate.weekday);
    final bool hasQuests = quests.isNotEmpty;

    final bool showTrialPortal = isToday && player.isTrialAvailable && player.trialStatus != TrialStatus.failed;
    final bool allDone = hasQuests && quests.every((q) => q.isCompleted);

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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const PlayerProfileScreen()),
                                  );
                                },
                                child: CharacterAvatarWidget(
                                  rank: player.rank,
                                  level: player.level,
                                ),
                              ),
                              PlayerStatusHeader(
                                playerName: authState.user?.userMetadata?['username']?.toString().toUpperCase() ?? 'HUNTER',
                                level:      player.level,
                                currentXp:  player.currentExp,
                                maxXp:      player.maxExp,
                                currentHp:  player.currentHp,
                                maxHp:      player.maxHp,
                              ),
                            ],
                          ),
                        ),
                      ),
                      


                      FadeTransition(
                        opacity: _staggeredAnims[1],
                        child: Center(
                          child: (allDone && !showTrialPortal)
                              ? _CompletionBanner(expReward: player.level * 25, isToday: isToday)
                              : (!isScheduledDay)
                                  ? const SizedBox.shrink()
                                  : Column(
                                      children: [
                                        if (isToday)
                                          const DailyCountdownTimer()
                                        else
                                          Text(
                                            'TRAINING WINDOW ACTIVE',
                                            style: ShadowTextTheme.mono(16, color: ShadowColors.amethystLight, weight: FontWeight.bold),
                                          ),
                                      ],
                                    ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),

                      if (isToday && player.trialStatus == TrialStatus.failed) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TrialFailedCard(onRetry: _enterTrial),
                        ),
                        const SizedBox(height: 24),
                      ],

                      _buildHorizontalDaySelector(),
                      const SizedBox(height: 24),

                      _buildQuestSectionHeader(quests, showTrialPortal, scheduleState.days, selectedDate, isScheduledDay, player.trialStatus == TrialStatus.penalty),
                      
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                if (showTrialPortal)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PENDING RANK-UP EVALUATION',
                            style: ShadowTextTheme.mono(10, color: ShadowColors.portalBlue, weight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TrialPortalCard(onTap: _enterTrial),
                        ],
                      ),
                    ),
                  ),

                if (isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: ShadowColors.amethyst),
                            SizedBox(height: 16),
                            Text(
                              'SYNCHRONIZING WITH SYSTEM...',
                              style: TextStyle(
                                color: ShadowColors.textDisabled,
                                fontSize: 12,

                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (!hasQuests)
                   SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              isScheduledDay 
                                ? 'NO DAILY QUEST FOR TODAY'
                                : 'RECOVERY PHASE ACTIVE',
                              textAlign: TextAlign.center,
                              style: ShadowTextTheme.headline(20).copyWith(
                                color: isScheduledDay ? ShadowColors.amethystLight : ShadowColors.textDisabled,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (isScheduledDay)
                              Text(
                                'The System has not yet generated your training protocols for this cycle.',
                                textAlign: TextAlign.center,
                                style: ShadowTextTheme.body(12, color: ShadowColors.textSecondary),
                              ),
                            const SizedBox(height: 32),
                            if (isScheduledDay)
                              Column(
                                children: [
                                  _MonarchButton(
                                    label: 'INITIALIZE PROTOCOLS',
                                    icon: Icons.sync_rounded,
                                    onTap: () {
                                      _vibrate();
                                      final user = ref.read(authProvider).user;
                                      if (user != null) {
                                        ref.read(questProvider.notifier).fetchQuests(
                                          user.id, 
                                          date: selectedDate,
                                          localSchedule: scheduleState.days,
                                        );
                                      }
                                    },
                                    isPrimary: true,
                                  ),
                                  const SizedBox(height: 12),
                                  _MonarchButton(
                                    label: 'REPAIR SYSTEM',
                                    icon: Icons.build_rounded,
                                    onTap: () {
                                      _vibrate();
                                      final user = ref.read(authProvider).user;
                                      if (user != null) {
                                        // Force a total refresh of everything
                                        ref.read(playerProvider.notifier).fetchFromSupabase();
                                        ref.read(scheduleProvider.notifier).loadForUser(user.id);
                                        ref.read(questProvider.notifier).fetchQuests(
                                          user.id,
                                          date: selectedDate,
                                          localSchedule: scheduleState.days,
                                        );
                                      }
                                    },
                                    isPrimary: false,
                                  ),
                                ],
                              )
                            else
                              _MonarchButton(
                                label: 'START BONUS PROTOCOL',
                                icon: Icons.bolt_rounded,
                                onTap: () {
                                  _vibrate();
                                  final user = ref.read(authProvider).user;
                                  if (user != null) {
                                    ref.read(questProvider.notifier).fetchQuests(
                                      user.id, 
                                      date: selectedDate,
                                      // Bonus protocol bypasses schedule check in service
                                      localSchedule: [selectedDate.weekday], 
                                    );
                                  }
                                },
                                isPrimary: false,
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (!allDone)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: quests.map((q) => DashboardQuestTile(
                          quest: q,
                          targetReps: q.getActualReps(player.level),
                          selectedDate: selectedDate,
                        )).toList(),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),

          if (_penaltyExpLost > 0)
            SystemPenaltyOverlay(
              expLost: _penaltyExpLost,
              onDismiss: () => setState(() => _penaltyExpLost = 0),
            ),

          // Daily quest completion popup — shown BEFORE reward is given
          if (questCompletionReward != null)
            Positioned.fill(
              child: QuestCompleteOverlay(
                expReward: questCompletionReward,
                hpHeal: player.rank.hpGainOnCompletion,
                rank: player.rank,
                onContinue: () {
                  ref.read(questProvider.notifier).claimQuestReward();
                },
              ),
            ),
          
        ],
      ),
    );
  }

  Widget _buildHorizontalDaySelector() {
    final now = DateTime.now();
    final selectedDate = ref.watch(selectedDateProvider);
    final schedule = ref.watch(scheduleProvider).days;

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 7,
        itemBuilder: (context, index) {
          // Show current week: Mon to Sun
          final monday = now.subtract(Duration(days: now.weekday - 1));
          final date = monday.add(Duration(days: index));
          final bool isSelected = date.year == selectedDate.year && 
                                  date.month == selectedDate.month && 
                                  date.day == selectedDate.day;
          final bool isToday = date.year == now.year && 
                                date.month == now.month && 
                                date.day == now.day;
          final bool isScheduled = schedule.contains(date.weekday);

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(selectedDateProvider.notifier).state = date;
              final user = ref.read(authProvider).user;
              if (user != null) {
                ref.read(questProvider.notifier).fetchQuests(
                  user.id, 
                  date: date,
                  localSchedule: schedule.toList(),
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected 
                  ? ShadowColors.amethyst.withValues(alpha: 0.15) 
                  : ShadowColors.surfaceAlt,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: isSelected 
                    ? ShadowColors.amethyst 
                    : (isToday ? ShadowColors.amethyst.withValues(alpha: 0.4) : ShadowColors.systemBorder),
                  width: 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekday(date.weekday).toUpperCase(),
                    style: ShadowTextTheme.mono(9, 
                      color: isSelected ? ShadowColors.textPrimary : ShadowColors.textDisabled,
                      weight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: ShadowTextTheme.mono(16, 
                      color: isSelected ? ShadowColors.amethystLight : ShadowColors.textPrimary,
                      weight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isScheduled)
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: ShadowColors.amethyst,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: ShadowColors.obsidian, // Deep Obsidian background
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: ShadowColors.textPrimary),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const solo_levelling_app_notifications.NotificationScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: ShadowColors.textPrimary),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const solo_levelling_app_settings.SettingsScreen()),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildQuestSectionHeader(List<DailyQuest> quests, bool isTrial, List<int> scheduledDays, DateTime selectedDate, bool isScheduledDay, bool isPenalty) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeTransition(
            opacity: _staggeredAnims[2],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    isTrial ? 'RANK UP TRIAL' : (isPenalty ? 'PENALTY PROTOCOL' : 'DAILY QUESTS'),
                    style: ShadowTextTheme.headline(24, letterSpacing: 1.5).copyWith(
                      color: isTrial ? ShadowColors.portalBlue : (isPenalty ? ShadowColors.hpRed : ShadowColors.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 1,
            color: isTrial ? ShadowColors.portalBlue : (isPenalty ? ShadowColors.hpRed : ShadowColors.amethyst),
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
}

class _CompletionBanner extends ConsumerStatefulWidget {
  final int expReward;
  final bool isToday;
  const _CompletionBanner({required this.expReward, this.isToday = true});

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
    const accentColor = ShadowColors.success;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Stack(
          children: [
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(width: 3, color: accentColor),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isToday && _nextWorkoutIn > Duration.zero) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'SYSTEM COOLDOWN. NEXT QUEST IN:',
                            style: ShadowTextTheme.mono(10, color: ShadowColors.textSecondary, weight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _formatDuration(_nextWorkoutIn),
                      style: ShadowTextTheme.mono(28, color: accentColor, weight: FontWeight.bold).copyWith(
                        letterSpacing: 2,
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        const Icon(Icons.verified_rounded, color: accentColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'DAILY QUEST COMPLETED',
                            style: ShadowTextTheme.headline(16, color: accentColor, letterSpacing: 1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonarchButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _MonarchButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPrimary ? ShadowColors.amethyst : ShadowColors.textDisabled;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: isPrimary ? color : ShadowColors.systemBorder, 
            width: 1.0
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 12),
            Text(
              label.toUpperCase(),
              style: ShadowTextTheme.mono(12, color: color, weight: FontWeight.bold).copyWith(
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
