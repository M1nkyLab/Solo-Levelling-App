import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';

/// A full-screen passive tracker using the Proximity Sensor.
/// Counts reps based on a "Hover" cycle: Near (down) -> Far (up).
class ProximityHoverTracker extends StatefulWidget {
  final int targetReps;
  final int initialReps;
  final Color accentColor;
  final Function(int) onRepRegistered;
  final VoidCallback? onComplete;

  const ProximityHoverTracker({
    super.key,
    required this.targetReps,
    this.initialReps = 0,
    this.accentColor = ShadowColors.amethyst, // Default to Amethyst Purple
    required this.onRepRegistered,
    this.onComplete,
  });

  @override
  State<ProximityHoverTracker> createState() => _ProximityHoverTrackerState();
}

class _ProximityHoverTrackerState extends State<ProximityHoverTracker>
    with TickerProviderStateMixin {
  late int _currentReps;
  bool _isNear = false;
  late StreamSubscription<dynamic> _sensorSubscription;

  late AnimationController _flashController;
  late Animation<Color?> _flashAnimation;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _currentReps = widget.initialReps;

    // Rep Flash Animation
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flashAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.accentColor.withValues(alpha: 0.4),
    ).animate(CurvedAnimation(parent: _flashController, curve: Curves.easeOut));

    // Radar Pulse Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startProximityListening();
  }

  void _startProximityListening() {
    _sensorSubscription = ProximitySensor.events.listen((int event) {
      // Typically: event > 0 is NEAR, 0 is FAR
      bool isCurrentlyNear = (event > 0);

      if (isCurrentlyNear && !_isNear) {
        // User lowered down
        setState(() => _isNear = true);
        HapticFeedback.mediumImpact(); // Subtle "Lock-on" feedback
      } else if (!isCurrentlyNear && _isNear) {
        // User pushed back up -> Full Rep Cycle Complete
        setState(() => _isNear = false);
        _registerRep();
      }
    });
  }

  void _registerRep() {
    if (_currentReps < widget.targetReps) {
      setState(() {
        _currentReps++;
      });

      // Visceral Feedback
      HapticFeedback.heavyImpact();
      _flashController.forward(from: 0).then((_) => _flashController.reverse());

      widget.onRepRegistered(_currentReps);

      if (_currentReps == widget.targetReps) {
        widget.onComplete?.call();
      }
    }
  }

  @override
  void dispose() {
    _sensorSubscription.cancel();
    _flashController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450, // Fixed height for list view
      decoration: BoxDecoration(
        color: ShadowColors.obsidian,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ShadowColors.glassBorder.withValues(alpha: 0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedBuilder(
        animation: _flashAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              // Ambient Glow
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        widget.accentColor.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Flash Overlay
              Positioned.fill(
                child: Container(color: _flashAnimation.value),
              ),

              // Main Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SIT-UPS TUNING ACTIVE',
                      style: ShadowTextTheme.mono(12, color: widget.accentColor, weight: FontWeight.bold).copyWith(letterSpacing: 4),
                    ),
                    const SizedBox(height: 20),
                    // Massive Rep Counter
                    Text(
                      '$_currentReps',
                      style: ShadowTextTheme.headline(100, weight: FontWeight.w900).copyWith(
                        color: _currentReps == widget.targetReps 
                            ? ShadowColors.portalBlue 
                            : ShadowColors.textPrimary,
                        letterSpacing: -5,
                        height: 1,
                      ),
                    ),
                    Text(
                      '/ ${widget.targetReps} REPS',
                      style: ShadowTextTheme.mono(18, color: ShadowColors.textSecondary),
                    ),
                    
                    const SizedBox(height: 40),

                    // Radar / Observer Indicator
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.accentColor.withValues(alpha: 0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.accentColor.withValues(alpha: 0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isNear ? Icons.visibility_rounded : Icons.radar_rounded,
                          color: widget.accentColor,
                          size: 36,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      _isNear ? "TARGET DETECTED" : "SYSTEM OBSERVING...",
                      style: ShadowTextTheme.mono(12, 
                        color: _isNear ? ShadowColors.hpRed : widget.accentColor, 
                        weight: FontWeight.bold
                      ).copyWith(letterSpacing: 4),
                    ),

                    const SizedBox(height: 8),
                    
                    Text(
                      "HOVER 2 INCHES ABOVE SCREEN",
                      style: ShadowTextTheme.body(10, color: ShadowColors.textDisabled),
                    ),
                  ],
                ),
              ),

              // Proximity State Indicator (Bottom)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isNear ? ShadowColors.hpRed : ShadowColors.success,
                      boxShadow: [
                        BoxShadow(
                          color: (_isNear ? ShadowColors.hpRed : ShadowColors.success)
                              .withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
