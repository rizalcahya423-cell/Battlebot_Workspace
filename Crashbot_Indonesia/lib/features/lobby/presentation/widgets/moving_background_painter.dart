import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:my_flutter_app/core/constants/app_colors.dart';

/// Animated abstract moving background with blurred color blobs.
/// Used as the lobby screen backdrop.
class MovingBackgroundPainter extends CustomPainter {
  final double animationValue;
  const MovingBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()..color = AppColors.darkBase;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), basePaint);

    final double w = size.width;
    final double h = size.height;
    final double phase = animationValue * 2 * math.pi;

    _drawBlob(
      canvas,
      offset: Offset(
        w * 0.25 + math.sin(phase) * w * 0.15,
        h * 0.4 + math.cos(phase) * h * 0.2,
      ),
      radius: math.min(w, h) * 0.45 + math.sin(phase) * 40,
      color: AppColors.dangerRed.withValues(alpha: 0.35),
      blurSigma: 130,
    );

    _drawBlob(
      canvas,
      offset: Offset(
        w * 0.75 + math.cos(phase) * w * 0.15,
        h * 0.5 + math.sin(phase) * h * 0.2,
      ),
      radius: math.min(w, h) * 0.45 + math.cos(phase) * 40,
      color: AppColors.lightBlue.withValues(alpha: 0.28),
      blurSigma: 140,
    );

    _drawBlob(
      canvas,
      offset: Offset(
        w * 0.6 + math.sin(phase + 1.0) * w * 0.2,
        h * 0.3 + math.cos(phase + 1.0) * h * 0.15,
      ),
      radius: math.min(w, h) * 0.5 + math.sin(phase + 1.0) * 30,
      color: AppColors.primaryBlue.withValues(alpha: 0.3),
      blurSigma: 150,
    );

    _drawBlob(
      canvas,
      offset: Offset(
        w * 0.4 + math.cos(phase + 2.0) * w * 0.2,
        h * 0.7 + math.sin(phase + 2.0) * h * 0.15,
      ),
      radius: math.min(w, h) * 0.45 + math.cos(phase + 2.0) * 30,
      color: AppColors.deepRed.withValues(alpha: 0.25),
      blurSigma: 120,
    );
  }

  void _drawBlob(
    Canvas canvas, {
    required Offset offset,
    required double radius,
    required Color color,
    required double blurSigma,
  }) {
    final paint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
    canvas.drawCircle(offset, radius, paint);
  }

  @override
  bool shouldRepaint(covariant MovingBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
