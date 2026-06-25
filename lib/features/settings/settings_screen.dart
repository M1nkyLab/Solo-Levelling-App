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
        title: Text(
          'SETTINGS',
          style: ShadowTextTheme.headline(20, letterSpacing: 2),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          _buildSettingsItem(
            icon: Icons.person_rounded,
            title: 'EDIT PROFILE',
            onTap: () {
              HapticFeedback.lightImpact();
              final user = ref.read(authProvider).user;
              final username = user?.userMetadata?['username'] as String? ?? 'HUNTER';
              _showEditProfileDialog(context, ref, username);
            },
          ),
          const Divider(color: ShadowColors.systemBorder, height: 1),
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
          const Divider(color: ShadowColors.systemBorder, height: 1),
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
          const Divider(color: ShadowColors.systemBorder, height: 1),
          _buildSettingsItem(
            icon: Icons.delete_forever_rounded,
            title: 'DELETE ACCOUNT',
            color: ShadowColors.hpRed,
            onTap: () async {
              HapticFeedback.heavyImpact();
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: ShadowColors.surfaceAlt,
                  title: Text(
                    'DELETE ACCOUNT?',
                    style: ShadowTextTheme.headline(20, color: ShadowColors.hpRed),
                  ),
                  content: Text(
                    'This action cannot be undone. All your progress will be lost.',
                    style: ShadowTextTheme.body(14),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('CANCEL', style: ShadowTextTheme.body(14)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('DELETE', style: ShadowTextTheme.body(14, color: ShadowColors.hpRed)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                HapticFeedback.heavyImpact();
                final success = await ref.read(authProvider.notifier).deleteAccount();
                if (success && context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete account.', style: ShadowTextTheme.body(14)),
                      backgroundColor: ShadowColors.hpRed,
                    ),
                  );
                }
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
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Icon(icon, color: color, size: 28),
      title: Text(
        title,
        style: ShadowTextTheme.headline(16, color: color),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.5)),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, String currentUsername) {
    final controller = TextEditingController(text: currentUsername);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ShadowColors.surfaceAlt,
          title: Text('EDIT PROFILE', style: ShadowTextTheme.headline(20, color: ShadowColors.amethyst)),
          content: TextField(
            controller: controller,
            style: ShadowTextTheme.body(16, color: ShadowColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'HUNTER NAME',
              labelStyle: ShadowTextTheme.body(14, color: ShadowColors.textSecondary),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: ShadowColors.systemBorder),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: ShadowColors.amethyst),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('CANCEL', style: ShadowTextTheme.body(14)),
            ),
            TextButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty && newName != currentUsername) {
                  HapticFeedback.heavyImpact();
                  await ref.read(authProvider.notifier).updateUsername(newName);
                }
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text('SAVE', style: ShadowTextTheme.body(14, color: ShadowColors.amethyst)),
            ),
          ],
        );
      },
    );
  }
}
