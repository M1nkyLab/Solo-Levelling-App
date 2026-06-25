import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/features/player/player_provider.dart';
import 'package:solo_levelling_app/features/auth/auth_provider.dart';
import 'package:solo_levelling_app/features/main/notification_screen.dart' as solo_levelling_app_notifications;
import 'package:solo_levelling_app/features/settings/settings_screen.dart' as solo_levelling_app_settings;

class PlayerProfileScreen extends ConsumerStatefulWidget {
  final bool isFromNavBar;

  const PlayerProfileScreen({super.key, this.isFromNavBar = false});

  @override
  ConsumerState<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends ConsumerState<PlayerProfileScreen> {
  DateTime _focusedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final username = user?.userMetadata?['username'] as String? ?? 'HUNTER';
    final player = ref.watch(playerProvider);

    return Scaffold(
      backgroundColor: ShadowColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'PROFILE',
          style: ShadowTextTheme.headline(20, letterSpacing: 2),
        ),
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ShadowColors.surfaceAlt,
                  border: Border.all(color: ShadowColors.amethyst, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: ShadowColors.amethyst.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.person, size: 50, color: ShadowColors.textPrimary),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                username.toUpperCase(),
                style: ShadowTextTheme.headline(24, letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              Text(
                'RANK: ${player.rank.name.toUpperCase()}',
                style: ShadowTextTheme.mono(16, color: ShadowColors.amethystLight, weight: FontWeight.bold, letterSpacing: 1.5),
              ),
              const SizedBox(height: 40),
              
              // Full-Month Attendance Log
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ATTENDANCE LOG',
                  style: ShadowTextTheme.headline(18, color: ShadowColors.textSecondary, letterSpacing: 1),
                ),
              ),
              const SizedBox(height: 16),
              _buildCalendar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ShadowColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ShadowColors.systemBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          // Month/Year header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, color: ShadowColors.textPrimary),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                  });
                },
              ),
              Text(
                '${_getMonthName(_focusedMonth.month)} ${_focusedMonth.year}',
                style: ShadowTextTheme.headline(16, letterSpacing: 1.5),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, color: ShadowColors.textPrimary),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Days of week
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: ShadowTextTheme.mono(12, color: ShadowColors.textDisabled, weight: FontWeight.bold),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Calendar Grid
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    
    // Dart DateTime.weekday: 1 = Monday ... 7 = Sunday
    // For calendar with Sunday as first column:
    final firstWeekday = firstDayOfMonth.weekday; // 1 to 7
    final offset = firstWeekday == 7 ? 0 : firstWeekday;

    final totalCells = offset + daysInMonth;
    final totalRows = (totalCells / 7).ceil();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: totalRows * 7,
      itemBuilder: (context, index) {
        if (index < offset || index >= offset + daysInMonth) {
          return const SizedBox(); // Empty cell
        }
        
        final day = index - offset + 1;
        final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
        final now = DateTime.now();
        final isToday = date.year == now.year &&
                        date.month == now.month &&
                        date.day == now.day;
                        
        final isPast = date.isBefore(DateTime(now.year, now.month, now.day));
        // Mocking attendance for past dates (this should ideally read from a database of completed quests)
        final isAttended = isPast && (day % 4 != 0); // Random visual data: missing every 4th day

        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isToday 
                ? ShadowColors.amethyst.withValues(alpha: 0.8) 
                : (isAttended ? ShadowColors.success.withValues(alpha: 0.2) : Colors.transparent),
            border: Border.all(
              color: isToday 
                  ? ShadowColors.amethyst 
                  : (isAttended ? ShadowColors.success : ShadowColors.systemBorder.withValues(alpha: 0.3)),
            ),
          ),
          child: Center(
            child: Text(
              day.toString(),
              style: ShadowTextTheme.mono(
                12, 
                color: isToday ? ShadowColors.textPrimary : (isAttended ? ShadowColors.success : ShadowColors.textDisabled),
                weight: isToday || isAttended ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = ['JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE', 'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'];
    return months[month - 1];
  }
}
