import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/core/widgets/smoky_progress_bar.dart';

enum PassiveQuestType { pushups, squats }

class PassiveSensorTracker extends StatefulWidget {
  final PassiveQuestType type;
  final int targetReps;
  final Color accentColor;
  final VoidCallback onComplete;

  const PassiveSensorTracker({
    super.key,
    required this.type,
    required this.targetReps,
    this.accentColor = ShadowColors.amethyst,
    required this.onComplete,
  });

  @override
  State<PassiveSensorTracker> createState() => _PassiveSensorTrackerState();
}

class _PassiveSensorTrackerState extends State<PassiveSensorTracker>
    with SingleTickerProviderStateMixin {
  int _currentReps = 0;
  bool _isNear = false;
  bool _isDipping = false;
  static const double squatThreshold = 3.5;

  late StreamSubscription<dynamic> _sensorSubscription;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _startTracking();
  }

  void _startTracking() {
    if (widget.type == PassiveQuestType.pushups) {
      _sensorSubscription = ProximitySensor.events.listen((int event) {
        bool isCurrentlyNear = (event > 0);
        if (isCurrentlyNear && !_isNear) {
          _isNear = true;
          _onHalfRep();
        } else if (!isCurrentlyNear && _isNear) {
          _isNear = false;
          _registerRep();
        }
      });
    } else {
      _sensorSubscription = userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
        if (event.y < -squatThreshold && !_isDipping) {
          _isDipping = true;
          _onHalfRep();
        } else if (event.y > squatThreshold && _isDipping) {
          _isDipping = false;
          _registerRep();
        }
      });
    }
  }

  void _onHalfRep() {
    // Subtle vibration for the "down" phase
    HapticFeedback.mediumImpact();
  }

  void _registerRep() {
    if (_currentReps < widget.targetReps) {
      setState(() {
        _currentReps++;
      });
      
      HapticFeedback.heavyImpact();
      _pulseController.forward(from: 0).then((_) => _pulseController.reverse());

      if (_currentReps == widget.targetReps) {
        widget.onComplete();
      }
    }
  }

  @override
  void dispose() {
    _sensorSubscription.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String label = widget.type == PassiveQuestType.pushups ? "PUSH-UPS" : "SQUATS";
    final IconData icon = widget.type == PassiveQuestType.pushups 
        ? Icons.fitness_center_rounded 
        : Icons.keyboard_double_arrow_down_rounded;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF111118).withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.accentColor.withValues(
                alpha: 0.2 + (0.3 * _glowAnimation.value),
              ),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: widget.accentColor.withValues(
                  alpha: 0.1 * _glowAnimation.value,
                ),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: widget.accentColor, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: ShadowTextTheme.headline(14, weight: FontWeight.bold).copyWith(
                          letterSpacing: 2,
                          color: ShadowColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const _SensorBadge(),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$_currentReps',
                    style: ShadowTextTheme.mono(56, weight: FontWeight.w900).copyWith(
                      color: _currentReps == widget.targetReps 
                          ? ShadowColors.portalBlue 
                          : ShadowColors.textPrimary,
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '/ ${widget.targetReps} REPS',
                    style: ShadowTextTheme.mono(16, color: ShadowColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SmokyProgressBar(
                currentValue: _currentReps,
                maxValue: widget.targetReps,
                color: widget.accentColor,
                height: 12,
                particleCount: 25,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SensorBadge extends StatefulWidget {
  const _SensorBadge();

  @override
  State<_SensorBadge> createState() => _SensorBadgeState();
}

class _SensorBadgeState extends State<_SensorBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: ShadowColors.portalBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ShadowColors.portalBlue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sensors_rounded, color: ShadowColors.portalBlue, size: 12),
            const SizedBox(width: 4),
            Text(
              'PASSIVE TRACKING',
              style: ShadowTextTheme.mono(8, color: ShadowColors.portalBlue, weight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
