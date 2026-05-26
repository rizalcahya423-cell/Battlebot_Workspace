import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:my_flutter_app/core/constants/app_colors.dart';
import 'package:my_flutter_app/core/constants/app_sizes.dart';
import 'package:my_flutter_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_flutter_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:my_flutter_app/features/profile/presentation/widgets/game_profile_avatar.dart';
import 'package:my_flutter_app/features/profile/presentation/widgets/profile_customization_dialog.dart';

/// Top bar widget for lobby screen.
/// Displays user profile, app title, and realtime status indicators.
class LobbyTopBar extends StatelessWidget {
  final int gems;
  final int batteryLevel;
  final IconData batteryIcon;
  final Color batteryColor;
  final String batteryText;
  final IconData signalIcon;
  final Color signalColor;
  final int pingMs;

  const LobbyTopBar({
    super.key,
    required this.gems,
    required this.batteryLevel,
    required this.batteryIcon,
    required this.batteryColor,
    required this.batteryText,
    required this.signalIcon,
    required this.signalColor,
    required this.pingMs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingLg,
        vertical: 6,
      ),
      child: SizedBox(
        height: AppSizes.topBarHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _ProfileChip(
                onLongPress: () => _showLogoutDialog(context),
              ),
            ),
            const Align(alignment: Alignment.center, child: _AppTitle()),
            Align(
              alignment: Alignment.centerRight,
              child: _StatusIndicators(
                gems: gems,
                signalIcon: signalIcon,
                signalColor: signalColor,
                pingMs: pingMs,
                batteryIcon: batteryIcon,
                batteryColor: batteryColor,
                batteryText: batteryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.spacingXl),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text(
          'Keluar',
          style: TextStyle(color: AppColors.accentBlue),
        ),
        content: const Text(
          'Apakah Anda ingin keluar?',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  final VoidCallback onLongPress;
  const _ProfileChip({required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    return GestureDetector(
      onTap: () => ProfileCustomizationDialog.show(context),
      onLongPress: onLongPress,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GameProfileAvatar(
            avatarAsset: profile.avatarAsset,
            frameAsset: profile.frameAsset,
            size: 56,
          ),
          const SizedBox(width: AppSizes.spacingMd),
          const Text(
            'USER_01',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: AppSizes.fontLg,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppTitle extends StatelessWidget {
  const _AppTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'CRASHBOT',
          style: TextStyle(
            color: Colors.white,
            fontSize: AppSizes.fontTitle,
            fontWeight: FontWeight.w900,
            letterSpacing: 6,
            shadows: [
              Shadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.8),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        Text(
          'INDONESIA',
          style: TextStyle(
            color: Colors.white70,
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w700,
            letterSpacing: 8,
            shadows: [
              Shadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusIndicators extends StatelessWidget {
  final int gems;
  final IconData signalIcon;
  final Color signalColor;
  final int pingMs;
  final IconData batteryIcon;
  final Color batteryColor;
  final String batteryText;

  const _StatusIndicators({
    required this.gems,
    required this.signalIcon,
    required this.signalColor,
    required this.pingMs,
    required this.batteryIcon,
    required this.batteryColor,
    required this.batteryText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GemsDisplay(gems: gems),
        const SizedBox(width: 6),
        _AddButton(),
        const SizedBox(width: 10),
        _SignalDisplay(icon: signalIcon, color: signalColor, pingMs: pingMs),
        const SizedBox(width: 10),
        _BatteryDisplay(
          icon: batteryIcon,
          color: batteryColor,
          text: batteryText,
        ),
      ],
    );
  }
}

class _GemsDisplay extends StatelessWidget {
  final int gems;
  const _GemsDisplay({required this.gems});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingMd,
        vertical: AppSizes.spacingSm,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.diamond,
            color: AppColors.accentBlue,
            size: AppSizes.iconMd,
          ),
          const SizedBox(width: AppSizes.spacingSm),
          Text(
            '$gems',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: AppSizes.fontLg,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.darkGreen.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.batteryGreen.withValues(alpha: 0.5),
        ),
      ),
      child: const Icon(
        Icons.add,
        color: AppColors.batteryGreen,
        size: AppSizes.iconSm,
      ),
    );
  }
}

class _SignalDisplay extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int pingMs;

  const _SignalDisplay({
    required this.icon,
    required this.color,
    required this.pingMs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: AppSizes.iconLg),
        const SizedBox(width: AppSizes.spacingSm),
        Text(
          pingMs > 0 ? '$pingMs ms' : '-- ms',
          style: TextStyle(
            color: color,
            fontSize: AppSizes.fontBase,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _BatteryDisplay extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _BatteryDisplay({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: AppSizes.iconSm),
          const SizedBox(width: AppSizes.spacingXs),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
