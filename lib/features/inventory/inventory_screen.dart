import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {'name': 'Health Potion', 'qty': 5, 'rarity': 'Normal', 'icon': Icons.local_drink},
      {'name': 'System Key', 'qty': 1, 'rarity': 'Rare', 'icon': Icons.vpn_key},
      {'name': 'Teleportation Stone', 'qty': 2, 'rarity': 'Epic', 'icon': Icons.public},
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
          'INVENTORY',
          style: ShadowTextTheme.headline(20, letterSpacing: 2),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          Color rarityColor = ShadowColors.textDisabled;
          if (item['rarity'] == 'Rare') rarityColor = const Color(0xFF00B4FF);
          if (item['rarity'] == 'Epic') rarityColor = ShadowColors.amethyst;

          return Container(
            decoration: BoxDecoration(
              color: ShadowColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: rarityColor.withValues(alpha: 0.5)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item['icon'], color: rarityColor, size: 48),
                const SizedBox(height: 16),
                Text(
                  item['name'],
                  style: ShadowTextTheme.headline(14, color: ShadowColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'QTY: ${item['qty']}',
                  style: ShadowTextTheme.mono(12, color: ShadowColors.textDisabled),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
