import 'package:flutter/material.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';

class SystemButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;

  const SystemButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.textColor,
    this.borderColor,
  });

  @override
  State<SystemButton> createState() => _SystemButtonState();
}

class _SystemButtonState extends State<SystemButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color ?? ShadowColors.surfaceAlt;
    final bColor = widget.borderColor ?? ShadowColors.amethyst;
    final tColor = widget.textColor ?? ShadowColors.textPrimary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: _isPressed ? baseColor.withValues(alpha: 0.8) : baseColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered || _isPressed ? bColor : bColor.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: _isHovered || _isPressed
                ? [
                    BoxShadow(
                      color: bColor.withValues(alpha: 0.4),
                      blurRadius: 15,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label.toUpperCase(),
            style: ShadowTextTheme.mono(
              18,
              color: tColor,
              weight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
