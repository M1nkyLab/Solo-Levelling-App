import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';

class HunterProfileSecurityScreen extends StatelessWidget {
  const HunterProfileSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'HUNTER SECURITY',
          style: ShadowTextTheme.headline(20, letterSpacing: 2),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSecurityOption(context, 'Edit Profile', Icons.person_outline),
          const SizedBox(height: 16),
          _buildSecurityOption(context, 'Change Password', Icons.lock_outline),
          const SizedBox(height: 16),
          _buildSecurityOption(context, 'Privacy Settings', Icons.security),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: ShadowColors.hpRed),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'DELETE SYSTEM CACHE',
                style: ShadowTextTheme.headline(16, color: ShadowColors.hpRed, letterSpacing: 1),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSecurityOption(BuildContext context, String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: ShadowColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ShadowColors.systemBorder.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: Icon(icon, color: ShadowColors.amethyst),
        title: Text(title, style: ShadowTextTheme.body(16, color: ShadowColors.textPrimary)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: ShadowColors.textDisabled, size: 16),
        onTap: () {
          HapticFeedback.lightImpact();
        },
      ),
    );
  }
}
