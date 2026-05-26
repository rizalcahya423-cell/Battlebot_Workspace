import 'package:flutter/material.dart';

import 'package:my_flutter_app/core/constants/app_colors.dart';
import 'package:my_flutter_app/core/constants/app_sizes.dart';

/// Right-side leaderboard panel showing global rankings.
class LobbyLeaderboard extends StatelessWidget {
  const LobbyLeaderboard({super.key});

  static const List<(int, String)> _players = [
    (1, 'NeonStrider'),
    (2, 'Cipher'),
    (3, 'VoidWalker'),
    (4, 'ApexSumo'),
    (5, 'TitanSmasher'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.leaderboardWidth,
      margin: const EdgeInsets.only(
        top: AppSizes.spacingMd,
        bottom: AppSizes.spacingMd,
        right: AppSizes.spacingMd,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          const _LeaderboardTitle(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: 6,
                horizontal: AppSizes.spacingMd,
              ),
              itemCount: _players.length,
              itemBuilder: (_, index) {
                final (rank, name) = _players[index];
                return _LeaderboardEntry(rank: rank, name: name);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardTitle extends StatelessWidget {
  const _LeaderboardTitle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingLg),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: const Text(
        'LEADERBOARD GLOBAL',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: AppSizes.fontMd,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _LeaderboardEntry extends StatelessWidget {
  final int rank;
  final String name;

  const _LeaderboardEntry({required this.rank, required this.name});

  Color get _color => switch (rank) {
    1 => AppColors.rankGold,
    2 => AppColors.rankSilver,
    3 => AppColors.rankBronze,
    4 => AppColors.rankEmerald,
    _ => AppColors.rankPurple,
  };

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingMd,
        vertical: AppSizes.spacingMd,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: rank <= 3 ? color.withValues(alpha: 0.2) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          _PlayerAvatar(color: color),
          const SizedBox(width: AppSizes.spacingMd),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppSizes.fontBase,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _RankBadge(rank: rank, color: color),
        ],
      ),
    );
  }
}

class _PlayerAvatar extends StatelessWidget {
  final Color color;
  const _PlayerAvatar({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.avatarSmall,
      height: AppSizes.avatarSmall,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cardDark,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white54,
        size: AppSizes.iconMd,
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  final Color color;

  const _RankBadge({required this.rank, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.rankBadgeSize,
      height: AppSizes.rankBadgeSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        boxShadow: rank <= 3
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            color: color,
            fontSize: AppSizes.fontBase,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
