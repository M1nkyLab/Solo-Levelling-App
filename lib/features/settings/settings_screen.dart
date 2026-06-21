import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/features/auth/auth_provider.dart';
import 'package:solo_levelling_app/features/auth/login_screen.dart';
import 'package:solo_levelling_app/features/quests/schedule_selection_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          'SETTINGS',
          style: ShadowTextTheme.headline(20, letterSpacing: 2),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSettingsItem(
            icon: Icons.calendar_month_rounded,
            title: 'EDIT SCHEDULE',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ScheduleSelectionScreen(isEditing: true),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            icon: Icons.logout_rounded,
            title: 'LOGOUT',
            color: ShadowColors.hpRed,
            onTap: () async {
              HapticFeedback.heavyImpact();
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = ShadowColors.textPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ShadowColors.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ShadowColors.systemBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: ShadowTextTheme.headline(16, color: color),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
