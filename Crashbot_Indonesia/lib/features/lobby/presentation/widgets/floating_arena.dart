import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:my_flutter_app/core/constants/app_colors.dart';
import 'package:my_flutter_app/core/constants/app_sizes.dart';

/// Floating arena diorama widget with glow animation.
/// Loads and renders the arena_diorama.png asset with proper aspect ratio.
class FloatingArena extends StatefulWidget {
  final Animation<double> pulseAnimation;
  const FloatingArena({super.key, required this.pulseAnimation});

  @override
  State<FloatingArena> createState() => _FloatingArenaState();
}

class _FloatingArenaState extends State<FloatingArena> {
  ui.Image? _arenaImage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final data = await rootBundle.load('assets/arena_diorama.png');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      if (mounted) setState(() => _arenaImage = frame.image);
    } on Exception catch (e, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: e, stack: stackTrace),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        _ArenaGlow(pulseAnimation: widget.pulseAnimation),
        _arenaImage != null
            ? OverflowBox(
                minWidth: AppSizes.arenaWidth,
                maxWidth: AppSizes.arenaWidth,
                minHeight: AppSizes.arenaHeight,
                maxHeight: AppSizes.arenaHeight,
                child: SizedBox(
                  width: AppSizes.arenaWidth,
                  height: AppSizes.arenaHeight,
                  child: CustomPaint(
                    painter: _ArenaImagePainter(image: _arenaImage!),
                  ),
                ),
              )
            : const OverflowBox(
                minWidth: AppSizes.arenaWidth,
                maxWidth: AppSizes.arenaWidth,
                minHeight: AppSizes.arenaHeight,
                maxHeight: AppSizes.arenaHeight,
                child: SizedBox(
                  width: AppSizes.arenaWidth,
                  height: AppSizes.arenaHeight,
                ),
              ),
      ],
    );
  }
}

class _ArenaGlow extends StatelessWidget {
  final Animation<double> pulseAnimation;
  const _ArenaGlow({required this.pulseAnimation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (_, __) => Positioned(
        bottom: -10,
        child: Container(
          width: AppSizes.arenaWidth * 0.8,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(
                  alpha: 0.3 + 0.2 * pulseAnimation.value,
                ),
                blurRadius: 40,
                spreadRadius: 12,
              ),
              BoxShadow(
                color: AppColors.dangerRed.withValues(
                  alpha: 0.15 + 0.1 * pulseAnimation.value,
                ),
                blurRadius: 30,
                spreadRadius: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints the arena image maintaining proper aspect ratio.
class _ArenaImagePainter extends CustomPainter {
  final ui.Image image;
  const _ArenaImagePainter({required this.image});

  @override
  void paint(Canvas canvas, Size size) {
    final double srcWidth = image.width.toDouble();
    final double srcHeight = image.height.toDouble();
    final double srcAspect = srcWidth / srcHeight;
    final double dstAspect = size.width / size.height;

    final double drawWidth;
    final double drawHeight;

    if (srcAspect > dstAspect) {
      drawWidth = size.width;
      drawHeight = size.width / srcAspect;
    } else {
      drawHeight = size.height;
      drawWidth = size.height * srcAspect;
    }

    final double dx = (size.width - drawWidth) / 2;
    final double dy = (size.height - drawHeight) / 2;

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, srcWidth, srcHeight),
      Rect.fromLTWH(dx, dy, drawWidth, drawHeight),
      Paint(),
    );
  }

  @override
  bool shouldRepaint(covariant _ArenaImagePainter old) => old.image != image;
}
