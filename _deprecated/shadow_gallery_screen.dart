import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/features/player/shadow_extraction.dart';
import 'package:solo_levelling_app/features/player/shadow_provider.dart';
import 'package:solo_levelling_app/core/widgets/shadow_card.dart';

class ShadowGalleryScreen extends ConsumerWidget {
  const ShadowGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shadows = ref.watch(shadowProvider);

    return Scaffold(
      backgroundColor: ShadowColors.obsidian,
      appBar: AppBar(
        backgroundColor: ShadowColors.obsidian,
        title: Text('SHADOW GALLERY', style: ShadowTextTheme.headline(18, letterSpacing: 2)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ShadowColors.amethyst),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: shadows.isEmpty 
        ? _buildEmptyState()
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: shadows.length,
            itemBuilder: (context, index) {
              final shadow = shadows[index];
              return _buildShadowCard(shadow);
            },
          ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_fix_high_rounded, color: ShadowColors.textDisabled, size: 64),
          const SizedBox(height: 16),
          Text(
            'NO SHADOWS EXTRACTED',
            style: ShadowTextTheme.headline(16, color: ShadowColors.textDisabled),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete Rank-Up Trials to arise your army.',
            style: ShadowTextTheme.body(14, color: ShadowColors.textDisabled),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShadowCard(Shadow shadow) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: ShadowCard(
        accentColor: ShadowColors.portalBlue,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: ShadowColors.obsidian,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: ShadowColors.portalBlue, width: 1),
                ),
                child: const Icon(Icons.person_outline_rounded, color: ShadowColors.portalBlue, size: 40),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shadow.name.toUpperCase(),
                      style: ShadowTextTheme.headline(18, color: ShadowColors.textPrimary),
                    ),
                    Text(
                      shadow.title,
                      style: ShadowTextTheme.mono(12, color: ShadowColors.portalBlue),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: ShadowColors.portalBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: ShadowColors.portalBlue, width: 0.5),
                      ),
                      child: Text(
                        shadow.rank.toUpperCase(),
                        style: ShadowTextTheme.mono(10, color: ShadowColors.portalBlue, weight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      shadow.description,
                      style: ShadowTextTheme.body(12, color: ShadowColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
