import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:my_flutter_app/core/constants/app_colors.dart';
import 'package:my_flutter_app/core/constants/app_sizes.dart';
import 'package:my_flutter_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:my_flutter_app/features/profile/presentation/widgets/game_profile_avatar.dart';

/// Full-screen dialog for customizing profile avatar and frame.
/// Styled like a game customization panel with glowing selections.
class ProfileCustomizationDialog extends StatelessWidget {
  const ProfileCustomizationDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const ProfileCustomizationDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profile, _) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 60,
            vertical: 24,
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520, maxHeight: 440),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0E1F),
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              border: Border.all(
                color: AppColors.accentBlue.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.15),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DialogHeader(profile: profile),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.spacingXxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle(title: 'PILIH AVATAR'),
                        const SizedBox(height: AppSizes.spacingMd),
                        _AvatarGrid(profile: profile),
                        const SizedBox(height: AppSizes.spacingXl),
                        const _SectionTitle(title: 'PILIH FRAME'),
                        const SizedBox(height: AppSizes.spacingMd),
                        _FrameGrid(profile: profile),
                        const SizedBox(height: AppSizes.spacingXl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final ProfileProvider profile;
  const _DialogHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingXl),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          GameProfileAvatar(
            avatarAsset: profile.avatarAsset,
            frameAsset: profile.frameAsset,
            size: 64,
          ),
          const SizedBox(width: AppSizes.spacingXl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KUSTOMISASI PROFIL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppSizes.fontXxl,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingSm),
                Text(
                  'Pilih avatar dan frame untuk profil kamu',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: AppSizes.fontBase,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white54,
                size: AppSizes.iconMd,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.accentBlue.withValues(alpha: 0.9),
        fontSize: AppSizes.fontLg,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
      ),
    );
  }
}

class _AvatarGrid extends StatelessWidget {
  final ProfileProvider profile;
  const _AvatarGrid({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.spacingLg,
      runSpacing: AppSizes.spacingLg,
      children: List.generate(ProfileProvider.avatarCount, (index) {
        final avatarIndex = index + 1;
        final isSelected = profile.selectedAvatarIndex == avatarIndex;

        return GestureDetector(
          onTap: () => profile.selectAvatar(avatarIndex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: isSelected
                    ? AppColors.accentBlue
                    : Colors.white.withValues(alpha: 0.1),
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.accentBlue.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg - 2),
              child: Image.asset(
                'assets/avatar$avatarIndex.png',
                fit: BoxFit.cover,
                cacheWidth: 136,
                cacheHeight: 136,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _FrameGrid extends StatelessWidget {
  final ProfileProvider profile;
  const _FrameGrid({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.spacingXl,
      runSpacing: AppSizes.spacingLg,
      children: List.generate(ProfileProvider.frameCount, (index) {
        final frameIndex = index + 1;
        final isSelected = profile.selectedFrameIndex == frameIndex;

        return GestureDetector(
          onTap: () => profile.selectFrame(frameIndex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(AppSizes.spacingMd),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accentBlue.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              border: Border.all(
                color: isSelected
                    ? AppColors.accentBlue
                    : Colors.white.withValues(alpha: 0.1),
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.accentBlue.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                // Preview: avatar inside frame
                GameProfileAvatar(
                  avatarAsset: profile.avatarAsset,
                  frameAsset: 'assets/frame$frameIndex.png',
                  size: 72,
                ),
                const SizedBox(height: AppSizes.spacingMd),
                Text(
                  'Frame $frameIndex',
                  style: TextStyle(
                    color: isSelected ? AppColors.accentBlue : Colors.white54,
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
