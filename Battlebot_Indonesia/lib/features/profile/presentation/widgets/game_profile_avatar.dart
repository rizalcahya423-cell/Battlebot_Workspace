import 'package:flutter/material.dart';

/// Game-style profile avatar with decorative frame overlay.
/// The avatar is displayed inside the frame, creating a layered look
/// similar to MOBA/RPG game profile icons.
class GameProfileAvatar extends StatelessWidget {
  final String avatarAsset;
  final String frameAsset;
  final double size;
  final VoidCallback? onTap;

  const GameProfileAvatar({
    super.key,
    required this.avatarAsset,
    required this.frameAsset,
    this.size = 48,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Avatar (no rounding — frame overlay defines the shape)
            Image.asset(
              avatarAsset,
              width: size * 0.58,
              height: size * 0.58,
              fit: BoxFit.cover,
              cacheWidth: (size * 0.58 * 2).toInt(),
              cacheHeight: (size * 0.58 * 2).toInt(),
            ),
            // Frame overlay (full size, on top of avatar)
            Image.asset(
              frameAsset,
              width: size,
              height: size,
              fit: BoxFit.contain,
              cacheWidth: (size * 2).toInt(),
              cacheHeight: (size * 2).toInt(),
            ),
          ],
        ),
      ),
    );
  }
}
