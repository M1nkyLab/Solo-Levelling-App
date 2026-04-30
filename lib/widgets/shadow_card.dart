import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A reusable stat/info card with the Shadow Monarch glow aesthetic.
///
/// Usage:
/// ```dart
/// ShadowCard(
///   title: 'Strength',
///   value: '247',
///   icon: Icons.fitness_center,
///   accentColor: ShadowColors.amethyst,
/// )
/// ```
class ShadowCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? accentColor;
  final VoidCallback? onTap;
  final Widget? badge;        // optional badge (e.g., level-up indicator)

  const ShadowCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.accentColor,
    this.onTap,
    this.badge,
  });

  @override
  State<ShadowCard> createState() => _ShadowCardState();
}

class _ShadowCardState extends State<ShadowCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? ShadowColors.amethyst;
    final glowColor = accent.withOpacity(0.35);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedBuilder(
        animation: _glowAnim,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            transform: Matrix4.identity()
              ..scale(_pressed ? 0.97 : 1.0),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              color: ShadowColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                // Ambient purple glow – tighter and sharper
                BoxShadow(
                  color: glowColor.withOpacity(
                      glowColor.opacity * _glowAnim.value),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
                // Subtle inner depth shadow
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: child,
          );
        },
        child: _CardContent(
          title: widget.title,
          value: widget.value,
          icon: widget.icon,
          accent: accent,
          badge: widget.badge,
        ),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final Widget? badge;

  const _CardContent({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          // Icon container with accent glow ring
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: ShadowColors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withOpacity(0.4), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, color: accent, size: 26),
          ),
          const SizedBox(width: 16),

          // Title + Value column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.toUpperCase(),
                  style: ShadowTextTheme.mono(
                    11,
                    color: ShadowColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: ShadowTextTheme.mono(
                    28,
                    color: accent,
                    weight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Optional badge (e.g. arrow, level-up icon)
          if (badge != null) badge!,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Specialised variants built on ShadowCard
// ─────────────────────────────────────────────

/// Stat card specifically styled for RPG attributes (STR, AGI, etc.)
class StatCard extends StatelessWidget {
  final String statName;
  final int statValue;
  final IconData icon;

  const StatCard({
    super.key,
    required this.statName,
    required this.statValue,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ShadowCard(
      title: statName,
      value: statValue.toString(),
      icon: icon,
      accentColor: ShadowColors.amethyst,
    );
  }
}

/// HP card using the red health accent.
class HpCard extends StatelessWidget {
  final int currentHp;
  final int maxHp;

  const HpCard({super.key, required this.currentHp, required this.maxHp});

  @override
  Widget build(BuildContext context) {
    return ShadowCard(
      title: 'HP',
      value: '$currentHp / $maxHp',
      icon: Icons.favorite_rounded,
      accentColor: ShadowColors.hpRed,
    );
  }
}
