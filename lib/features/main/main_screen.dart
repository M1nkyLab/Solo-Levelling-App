import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/features/quests/dashboard_screen.dart';
import 'package:solo_levelling_app/features/player/player_profile_screen.dart';
import 'package:solo_levelling_app/features/trials/rank_up_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShadowColors.obsidian,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              TickerMode(
                enabled: _currentIndex == 0,
                child: const DashboardScreen(),
              ),
              TickerMode(
                enabled: _currentIndex == 1,
                child: const RankUpScreen(),
              ),
              TickerMode(
                enabled: _currentIndex == 2,
                child: const PlayerProfileScreen(isFromNavBar: true),
              ),
            ],
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Positioned(
      left: 24,
      right: 24,
      bottom: 24,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: ShadowColors.obsidian,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: ShadowColors.systemBorder.withValues(alpha: 0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home_rounded, _currentIndex == 0, () {
              if (_currentIndex != 0) {
                HapticFeedback.lightImpact();
                setState(() => _currentIndex = 0);
              }
            }),
            _buildNavItem(Icons.bolt_rounded, _currentIndex == 1, () {
              if (_currentIndex != 1) {
                HapticFeedback.lightImpact();
                setState(() => _currentIndex = 1);
              }
            }),
            _buildNavItem(Icons.person_rounded, _currentIndex == 2, () {
              if (_currentIndex != 2) {
                HapticFeedback.lightImpact();
                setState(() => _currentIndex = 2);
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              color: isActive ? ShadowColors.amethyst : ShadowColors.textDisabled, 
              size: 28
            ),
          ],
        ),
      ),
    );
  }
}
