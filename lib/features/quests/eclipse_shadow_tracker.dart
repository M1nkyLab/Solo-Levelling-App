import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:light/light.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';

/// "God-Mode" Eclipse Tracker with manual sensitivity tuning.
/// Allows for ultra-sensitive detection (down to 5% light drop) for extremely bright rooms.
class EclipseShadowTracker extends StatefulWidget {
  final int targetReps;
  final int initialReps;
  final Color accentColor;
  final Function(int) onRepRegistered;
  final VoidCallback? onComplete;

  const EclipseShadowTracker({
    super.key,
    required this.targetReps,
    this.initialReps = 0,
    this.accentColor = ShadowColors.portalBlue,
    required this.onRepRegistered,
    this.onComplete,
  });

  @override
  State<EclipseShadowTracker> createState() => _EclipseShadowTrackerState();
}

class _EclipseShadowTrackerState extends State<EclipseShadowTracker>
    with TickerProviderStateMixin {
  late int _currentReps;
  double? _baselineLux;
  double _currentLux = 0;
  bool _isDown = false;
  bool _isCalibrating = true;
  
  // ULTRA SENSITIVITY CONTROLS
  double _manualSensitivity = 0.15; // Default to 15% light drop
  double _peakShadowDepth = 0.0;
  
  late StreamSubscription<int> _subscription;
  
  late AnimationController _scanController;
  late AnimationController _shadowController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _currentReps = widget.initialReps;

    _scanController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _shadowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);

    _startLightSensor();
  }

  void _startLightSensor() {
    _subscription = Light().lightSensorStream.listen((int lux) {
      if (!mounted) return;

      setState(() {
        _currentLux = lux.toDouble();
      });

      // 1. Calibration
      if (_isCalibrating) {
        if (_baselineLux == null && _currentLux > 0) {
          _baselineLux = _currentLux;
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() => _isCalibrating = false);
              _scanController.stop();
              HapticFeedback.mediumImpact();
            }
          });
        }
        return;
      }

      // 2. Ultra-Sensitive Detection
      if (_baselineLux! > 0) {
        double shadowDepth = 1.0 - (_currentLux / _baselineLux!).clamp(0.0, 1.0);
        
        // Track peak for UI feedback
        if (shadowDepth > _peakShadowDepth) {
          setState(() => _peakShadowDepth = shadowDepth);
        }

        // Trigger logic using the manual sensitivity slider
        if (shadowDepth > _manualSensitivity && !_isDown) {
          setState(() => _isDown = true);
          _shadowController.forward();
          HapticFeedback.mediumImpact();
        } else if (shadowDepth < (_manualSensitivity * 0.6) && _isDown) {
          setState(() => _isDown = false);
          _shadowController.reverse();
          _registerRep();
          // Reset peak after rep to track the next movement
          _peakShadowDepth = 0;
        }
      }
    });
  }

  void _registerRep() {
    if (_currentReps < widget.targetReps) {
      setState(() => _currentReps++);
      HapticFeedback.heavyImpact();
      widget.onRepRegistered(_currentReps);
      if (_currentReps == widget.targetReps) widget.onComplete?.call();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _scanController.dispose();
    _shadowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double shadowDepth = _baselineLux == null || _baselineLux == 0 ? 0 : 1.0 - (_currentLux / _baselineLux!).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: ShadowColors.obsidian,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ShadowColors.glassBorder.withValues(alpha: 0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          _buildBackgroundGlow(),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildCounter(),
                const SizedBox(height: 30),
                _buildEclipseDisplay(shadowDepth),
                const SizedBox(height: 30),
                _buildTuningPanel(shadowDepth),
              ],
            ),
          ),
          
          if (_isCalibrating) _buildCalibrationOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlow() {
    return AnimatedBuilder(
      animation: _shadowController,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  widget.accentColor.withValues(alpha: 0.2 * (1.0 - _shadowController.value)),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Text(
      'SYSTEM TUNING ACTIVE',
      style: ShadowTextTheme.mono(12, color: widget.accentColor, weight: FontWeight.bold).copyWith(letterSpacing: 4),
    );
  }

  Widget _buildCounter() {
    return Column(
      children: [
        Text(
          '$_currentReps',
          style: ShadowTextTheme.headline(80, weight: FontWeight.w900).copyWith(
            color: _isDown ? ShadowColors.textDisabled : ShadowColors.textPrimary,
            height: 1,
          ),
        ),
        Text('/ ${widget.targetReps} REPS', style: ShadowTextTheme.mono(16, color: ShadowColors.textSecondary)),
      ],
    );
  }

  Widget _buildEclipseDisplay(double shadowDepth) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.1).animate(_pulseController),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: widget.accentColor.withValues(alpha: 0.1), width: 1),
            ),
          ),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _isDown ? widget.accentColor : ShadowColors.textDisabled, width: 2),
            boxShadow: [
              if (_isDown) BoxShadow(color: widget.accentColor.withValues(alpha: 0.5), blurRadius: 40, spreadRadius: 10),
            ],
          ),
          child: CircularProgressIndicator(
            value: shadowDepth,
            strokeWidth: 4,
            color: widget.accentColor,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        Icon(
          _isDown ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded,
          color: _isDown ? widget.accentColor : ShadowColors.textDisabled,
          size: 32,
        ),
      ],
    );
  }

  Widget _buildTuningPanel(double currentDepth) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ShadowColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ShadowColors.glassBorder.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SENSOR SENSITIVITY', style: ShadowTextTheme.mono(10, color: ShadowColors.textSecondary)),
              Text('${(_manualSensitivity * 100).round()}% DROP', style: ShadowTextTheme.mono(10, color: widget.accentColor, weight: FontWeight.bold)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: widget.accentColor,
              inactiveTrackColor: ShadowColors.surfaceAlt,
              thumbColor: widget.accentColor,
              overlayColor: widget.accentColor.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: _manualSensitivity,
              min: 0.05,
              max: 0.50,
              onChanged: (val) => setState(() => _manualSensitivity = val),
            ),
          ),
          const SizedBox(height: 16),
          _buildLiveMeter('CURRENT SHADOW', currentDepth, widget.accentColor),
          const SizedBox(height: 8),
          _buildLiveMeter('PEAK SHADOW', _peakShadowDepth, ShadowColors.hpRed),
          const SizedBox(height: 12),
          Text(
            'Adjust slider until "Peak" consistently crosses red marker.',
            style: ShadowTextTheme.body(10, color: ShadowColors.textDisabled),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMeter(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: ShadowTextTheme.mono(8, color: ShadowColors.textDisabled)),
            Text('${(value * 100).round()}%', style: ShadowTextTheme.mono(8, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 2,
          width: double.infinity,
          color: ShadowColors.surfaceAlt,
          child: Stack(
            children: [
              Positioned(
                left: MediaQuery.of(context).size.width * 0.7 * _manualSensitivity,
                child: Container(width: 2, height: 2, color: ShadowColors.hpRed),
              ),
              FractionallySizedBox(
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalibrationOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.black.withValues(alpha: 0.9),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RotationTransition(turns: _scanController, child: Icon(Icons.sync_rounded, color: widget.accentColor, size: 60)),
                const SizedBox(height: 24),
                Text('SYSTEM CALIBRATING', style: ShadowTextTheme.headline(18).copyWith(color: widget.accentColor)),
                const SizedBox(height: 40),
                Text('STEP AWAY FROM SENSOR', style: ShadowTextTheme.mono(10, color: ShadowColors.hpRed, weight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
