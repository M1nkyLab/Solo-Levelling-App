import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as v64;
import '../theme/app_theme.dart';

/// A reusable stat/info card with the Shadow Monarch glow aesthetic.
/// Updated with Antigravity Design principles: Glassmorphism & Spatial Depth.
class ShadowCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? accentColor;
  final VoidCallback? onTap;
  final Widget? badge;

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
  bool _isHovered = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // Don't auto-repeat — only animate on hover/tap
    _glowAnim = Tween<double>(begin: 0.6, end: 0.6).animate(_glowController);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? ShadowColors.amethyst;
    final glowColor = accent.withValues(alpha: 0.25);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _glowController.repeat(reverse: true); // only animate when hovered
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _glowController.stop();
        _glowController.reset();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedBuilder(
          animation: _glowAnim,
          builder: (context, child) {
            // Apply 3D perspective tilt (Spatial Depth)
            final double s = _pressed ? 0.96 : (_isHovered ? 1.02 : 1.0);
            final Matrix4 transform = Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateX(_isHovered ? -0.05 : 0.0)
              ..rotateY(_isHovered ? 0.05 : 0.0)
              ..scaleByVector3(v64.Vector3(s, s, 1.0));

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              transform: transform,
              transformAlignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                // ── PERF: Static background color + border 
                // instead of expensive BackdropFilter.
                color: ShadowColors.surface.withValues(alpha: 0.85),
                border: Border.all(
                  color: ShadowColors.glassBorder.withValues(
                      alpha: _isHovered ? 0.4 : 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  // Layered soft shadows (Weightlessness)
                  ...ShadowColors.weightlessShadow,
                  // Dynamic accent glow — reduced to static on idle
                  // to save GPU cycles from constant repaints.
                  BoxShadow(
                    color: glowColor.withValues(
                        alpha: _isHovered ? 0.5 : 0.2),
                    blurRadius: _isHovered ? 30 : 16,
                    spreadRadius: _isHovered ? 2 : 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _CardContent(
                  title: widget.title,
                  value: widget.value,
                  icon: widget.icon,
                  accent: accent,
                  badge: widget.badge,
                ),
              ),
            );
          },
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
              border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.3),
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
