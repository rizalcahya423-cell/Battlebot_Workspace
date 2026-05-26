import 'package:flutter/material.dart';

import 'package:my_flutter_app/core/constants/app_colors.dart';

/// Reusable control button for robot directional controls.
/// Provides tactile press feedback with scale and glow animations.
class ControlButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final double size;

  const ControlButton({
    super.key,
    required this.icon,
    this.color = AppColors.cyanAccent,
    required this.onTapDown,
    required this.onTapUp,
    this.size = 100,
  });

  @override
  State<ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<ControlButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    widget.onTapDown();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onTapUp();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    widget.onTapUp();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: widget.size,
          height: widget.size,
          decoration: _buildDecoration(),
          child: Center(
            child: Icon(
              widget.icon,
              size: widget.size * 0.5,
              color: _isPressed
                  ? widget.color
                  : widget.color.withValues(alpha: 0.9),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      color: _isPressed ? AppColors.buttonPressed : AppColors.buttonDefault,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: _isPressed
              ? widget.color.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.5),
          offset: _isPressed ? Offset.zero : const Offset(4, 4),
          blurRadius: _isPressed ? 15 : 10,
          spreadRadius: _isPressed ? 2 : 0,
        ),
        if (!_isPressed)
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.05),
            offset: const Offset(-4, -4),
            blurRadius: 10,
          ),
      ],
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _isPressed
            ? const [
                AppColors.buttonGradientLightPressed,
                AppColors.buttonGradientDarkPressed,
              ]
            : const [
                AppColors.buttonGradientLight,
                AppColors.buttonGradientDark,
              ],
      ),
      border: Border.all(
        color: _isPressed ? widget.color : widget.color.withValues(alpha: 0.1),
        width: 2,
      ),
    );
  }
}
