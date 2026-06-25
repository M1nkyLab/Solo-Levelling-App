import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock notifications for now
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'SYSTEM PENALTY',
        'message': 'You failed to complete your daily quests. Penalty imposed.',
        'time': '2 HOURS AGO',
        'type': 'penalty',
      },
      {
        'title': 'LEVEL UP',
        'message': 'You have reached level 5. Stats increased.',
        'time': '1 DAY AGO',
        'type': 'reward',
      },
      {
        'title': 'QUEST COMPLETED',
        'message': 'Daily quest "100 Pushups" completed.',
        'time': '2 DAYS AGO',
        'type': 'info',
      },
    ];

    return Scaffold(
      backgroundColor: ShadowColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ShadowColors.textPrimary),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'SYSTEM LOG',
          style: ShadowTextTheme.headline(20, letterSpacing: 2),
        ),
        centerTitle: true,
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text(
                'NO LOGS FOUND.',
                style: ShadowTextTheme.mono(14, color: ShadowColors.textDisabled),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                
                Color iconColor = ShadowColors.amethyst;
                IconData icon = Icons.info_outline_rounded;
                
                if (notif['type'] == 'penalty') {
                  iconColor = ShadowColors.hpRed;
                  icon = Icons.warning_amber_rounded;
                } else if (notif['type'] == 'reward') {
                  iconColor = ShadowColors.success;
                  icon = Icons.verified_rounded;
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ShadowColors.surfaceAlt,
                    border: Border.all(color: ShadowColors.systemBorder.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: iconColor, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notif['title'],
                              style: ShadowTextTheme.headline(16, color: iconColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif['time'],
                              style: ShadowTextTheme.mono(10, color: ShadowColors.textDisabled),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              notif['message'],
                              style: ShadowTextTheme.body(14, color: ShadowColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
