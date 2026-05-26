import 'package:flutter/material.dart';

/// Game-style profile avatar.
class GameProfileAvatar extends StatelessWidget {
  final String avatarAsset;
  final double size;
  final VoidCallback? onTap;

  const GameProfileAvatar({
    super.key,
    required this.avatarAsset,
    this.size = 48,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(avatarAsset),
            fit: BoxFit.cover,
          ),
          border: Border.all(
            color: Colors.white24,
            width: 2,
          ),
        ),
      ),
    );
  }
}
