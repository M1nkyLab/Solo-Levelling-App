import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:solo_levelling_app/core/logic/system_logic.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';

final _rankRegex = RegExp(r'-Class|-Rank', caseSensitive: false);
final _numberFormatRegex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');

class PlayerStatusHeader extends StatelessWidget {
  final String playerName;
  final int level;
  final String? customTitle;
  final int currentXp;
  final int maxXp;
  final int currentHp;
  final int maxHp;

  const PlayerStatusHeader({
    super.key,
    required this.playerName,
    required this.level,
    this.customTitle,
    required this.currentXp,
    required this.maxXp,
    required this.currentHp,
    required this.maxHp,
  });

  String get _rankLabel =>
      customTitle ??
      SystemLogic.determineHunterRankLabel(level)
          .replaceAll(_rankRegex, '')
          .toUpperCase() + "-CLASS";

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player Name
          Text(
            playerName,
            style: GoogleFonts.cinzel(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFFFFF),
            ),
          ),
          const SizedBox(height: 16),
          // Rank & Level Cards
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  label: 'RANK',
                  value: _rankLabel,
                  valueColor: const Color(0xFFFFFFFF),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  label: 'LEVEL',
                  value: level.toString(),
                  valueColor: const Color(0xFF00D4FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // HP Bar
          _buildStatRow(
            label: 'HP',
            current: currentHp,
            max: maxHp,
            barColor: const Color(0xFFFF4444),
          ),
          const SizedBox(height: 16),
          // EXP Bar
          _buildStatRow(
            label: 'EXP',
            current: currentXp,
            max: maxXp,
            barColor: const Color(0xFF00B4FF),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xAA001122),
        border: Border.all(color: const Color(0xFF00D4FF), width: 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF00D4FF),
            blurRadius: 15,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.rajdhani(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4DD0E1),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.exo2(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: valueColor,
              shadows: [
                BoxShadow(
                  color: valueColor,
                  blurRadius: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required int current,
    required int max,
    required Color barColor,
  }) {
    final format = (int v) => v.toString().replaceAllMapped(_numberFormatRegex, (Match m) => '${m[1]},');
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFFFFFF),
              ),
            ),
            Text(
              '${format(current)}/${format(max)}',
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: const Color(0xFFA0A0A0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF222222),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: max > 0 ? (current / max).clamp(0.0, 1.0) : 0,
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: barColor,
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

