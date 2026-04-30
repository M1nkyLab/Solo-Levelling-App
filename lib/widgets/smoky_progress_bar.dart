import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────
//  Particle data — immutable, created once
// ─────────────────────────────────────────────
class _Particle {
  final double baseX;   // 0..1  normalised position along the bar
  final double baseY;   // 0..1  normalised within bar height
  final double radius;  // base puff radius in px
  final double speed;   // upward drift, bar-heights per second
  final double waveAmp; // horizontal sine amplitude in px
  final double waveFreq;// sine wave frequency multiplier
  final double phase;   // random phase offset
  final double opacity; // base opacity (0..1)

  const _Particle({
    required this.baseX,
    required this.baseY,
    required this.radius,
    required this.speed,
    required this.waveAmp,
    required this.waveFreq,
    required this.phase,
    required this.opacity,
  });
}

// ─────────────────────────────────────────────
//  CustomPainter — draws one frame
// ─────────────────────────────────────────────
class _SmokePainter extends CustomPainter {
  final double fillProgress; // 0..1
  final double smokeTime;    // total elapsed seconds
  final List<_Particle> particles;
  final Color accentColor;
  final Color trackColor;
  final double barRadius;

  const _SmokePainter({
    required this.fillProgress,
    required this.smokeTime,
    required this.particles,
    required this.accentColor,
    required this.trackColor,
    required this.barRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Guard: skip painting if laid out with zero size
    if (w <= 0 || h <= 0) return;

    final double fillW = (w * fillProgress).clamp(0.0, w);

    // ── 1. Track ────────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h),
          Radius.circular(barRadius)),
      Paint()..color = trackColor,
    );

    if (fillProgress <= 0.001) return;

    final fillRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, fillW, h),
      Radius.circular(barRadius),
    );

    // Guard: skip fill painting if fill width is negligibly small
    if (fillW < 1) return;

    // ── 2. Clip to filled region ─────────────────────────────────
    canvas.save();
    canvas.clipRRect(fillRRect);

    // ── 3. Base gradient fill ─────────────────────────────────────
    canvas.drawRRect(
      fillRRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            accentColor.withOpacity(0.25),
            accentColor.withOpacity(0.65),
            accentColor,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, fillW, h)),
    );

    // ── 4. Smoke / particle layer ────────────────────────────────
    for (final p in particles) {
      // Skip particles whose base position is beyond the fill
      if (p.baseX > fillProgress) continue;

      // Y drifts upward over time, wraps around
      final double drift = (smokeTime * p.speed) % 1.0;
      final double normY = (p.baseY - drift + 1.0) % 1.0;

      // Fade near top & bottom edges so particles don't pop
      double edgeFade = 1.0;
      if (normY < 0.25) edgeFade = normY / 0.25;
      if (normY > 0.75) edgeFade = (1.0 - normY) / 0.25;

      // Sine-wave horizontal drift
      final double xWave =
          math.sin(smokeTime * p.waveFreq + p.phase) * p.waveAmp;

      final double px = p.baseX * fillW + xWave;
      final double py = normY * h;

      // Pulse the radius slightly to sell the "breathing smoke" feel
      final double pulseFactor =
          1.0 + 0.25 * math.sin(smokeTime * 2.3 + p.phase);
      final double r = p.radius * pulseFactor;

      final Offset center = Offset(px, py);

      // Soft radial gradient puff — skip if radius would be zero
      final double drawR = r * 2.5;
      if (drawR < 0.5) continue;

      canvas.drawCircle(
        center,
        drawR,
        Paint()
          ..shader = RadialGradient(
            colors: [
              accentColor.withOpacity(p.opacity * edgeFade * 0.9),
              accentColor.withOpacity(0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: drawR)),
      );
    }

    // ── 5. Shimmer sweep ─────────────────────────────────────────
    // A bright band that slowly sweeps across the filled area
    final double shimmerPos = (smokeTime * 0.35 % 1.5 - 0.25) * fillW;
    // Only draw shimmer if the shader rect has a non-zero width
    const double shimmerW = 160.0;
    final Rect shimmerRect = Rect.fromLTWH(shimmerPos - shimmerW / 2, 0, shimmerW, h);
    if (shimmerRect.width > 0 && shimmerRect.height > 0) {
      canvas.drawRRect(
        fillRRect,
        Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.transparent,
              Colors.white.withOpacity(0.09),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(shimmerRect),
      );
    }

    canvas.restore();

    // ── 6. Glowing leading edge ──────────────────────────────────
    if (fillProgress > 0.015 && fillProgress < 0.985) {
      final double glow = 0.55 + 0.45 * math.sin(smokeTime * 4.5);

      // Outer soft halo
      canvas.drawLine(
        Offset(fillW, 2),
        Offset(fillW, h - 2),
        Paint()
          ..color = accentColor.withOpacity(0.12 * glow)
          ..strokeWidth = 12
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );

      // Inner bright line
      canvas.drawLine(
        Offset(fillW, 1),
        Offset(fillW, h - 1),
        Paint()
          ..color = accentColor.withOpacity(0.9 * glow)
          ..strokeWidth = 1.2
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );

      // Tiny spark at the leading tip
      final double sparkY = h / 2;
      final double sparkR = 2.5 * glow;
      canvas.drawCircle(
        Offset(fillW, sparkY),
        sparkR,
        Paint()
          ..color = Colors.white.withOpacity(0.8 * glow)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }

    // ── 7. Completion aura (full bar) ────────────────────────────
    if (fillProgress >= 0.985) {
      final double aura = 0.45 + 0.55 * math.sin(smokeTime * 2.8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-2, -1, w + 4, h + 2),
          Radius.circular(barRadius + 1),
        ),
        Paint()
          ..color = accentColor.withOpacity(0.15 * aura)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  @override
  bool shouldRepaint(_SmokePainter old) =>
      old.fillProgress != fillProgress || old.smokeTime != smokeTime;
}

// ─────────────────────────────────────────────
//  Public SmokyProgressBar widget
// ─────────────────────────────────────────────
class SmokyProgressBar extends StatefulWidget {
  /// The current value (e.g. 45).
  final int currentValue;

  /// The maximum value (e.g. 100).
  final int maxValue;

  /// Accent / smoke colour. Defaults to [ShadowColors.amethyst].
  final Color? color;

  /// Bar height in logical pixels.
  final double height;

  /// Number of smoke particles. More = denser smoke, higher CPU.
  final int particleCount;

  const SmokyProgressBar({
    super.key,
    required this.currentValue,
    required this.maxValue,
    this.color,
    this.height = 14,
    this.particleCount = 28,
  });

  @override
  State<SmokyProgressBar> createState() => _SmokyProgressBarState();
}

class _SmokyProgressBarState extends State<SmokyProgressBar>
    with TickerProviderStateMixin {
  // Drives the fill level change (per value update)
  late AnimationController _fillCtrl;
  late Animation<double> _fillAnim;

  // Drives the continuous smoke / shimmer animation
  late AnimationController _smokeCtrl;

  double _smokeTime = 0;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    final initial = _targetProgress;

    _fillCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fillAnim = AlwaysStoppedAnimation(initial);

    // Smoke ticker — ~60 fps updates via addListener
    _smokeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // irrelevant — we use repeat
    )..addListener(_onSmokeTick)
      ..repeat();

    _generateParticles();
  }

  double get _targetProgress => widget.maxValue <= 0
      ? 0.0
      : (widget.currentValue / widget.maxValue).clamp(0.0, 1.0);

  void _generateParticles() {
    // Fixed seed so particles don't jump on rebuild
    final rng = math.Random(7);
    _particles = List.generate(widget.particleCount, (_) {
      return _Particle(
        baseX: rng.nextDouble(),
        baseY: rng.nextDouble(),
        radius: rng.nextDouble() * 5 + 3,
        speed: rng.nextDouble() * 0.28 + 0.08,
        waveAmp: rng.nextDouble() * 7 + 2,
        waveFreq: rng.nextDouble() * 2.5 + 0.8,
        phase: rng.nextDouble() * math.pi * 2,
        opacity: rng.nextDouble() * 0.32 + 0.08,
      );
    });
  }

  void _onSmokeTick() {
    if (!mounted) return;
    setState(() {
      // Advance smoke time by ~16ms per tick
      _smokeTime += 0.016;
    });
  }

  @override
  void didUpdateWidget(SmokyProgressBar old) {
    super.didUpdateWidget(old);
    final changed = old.currentValue != widget.currentValue ||
        old.maxValue != widget.maxValue;
    if (changed) {
      final from = _fillAnim.value;
      final to = _targetProgress;
      _fillAnim = Tween<double>(begin: from, end: to).animate(
        CurvedAnimation(parent: _fillCtrl, curve: Curves.easeOutCubic),
      );
      _fillCtrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _fillCtrl.dispose();
    _smokeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.color ?? ShadowColors.amethyst;
    final radius = widget.height / 2;

    return AnimatedBuilder(
      animation: _fillCtrl,
      builder: (context, _) {
        return SizedBox(
          height: widget.height,
          width: double.infinity,
          child: CustomPaint(
            painter: _SmokePainter(
              fillProgress: _fillAnim.value,
              smokeTime: _smokeTime,
              particles: _particles,
              accentColor: accent,
              trackColor: ShadowColors.surfaceAlt,
              barRadius: radius,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  Convenience labelled variant (label + bar)
// ─────────────────────────────────────────────
class LabelledSmokyBar extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  final Color color;
  final IconData icon;

  const LabelledSmokyBar({
    super.key,
    required this.label,
    required this.current,
    required this.max,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 5),
            Text(label,
                style: ShadowTextTheme.mono(11,
                    color: color, weight: FontWeight.bold)),
            const Spacer(),
            Text('$current / $max',
                style: ShadowTextTheme.mono(11,
                    color: ShadowColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 6),
        SmokyProgressBar(
          currentValue: current,
          maxValue: max,
          color: color,
          height: 10,
          particleCount: 22,
        ),
      ],
    );
  }
}
