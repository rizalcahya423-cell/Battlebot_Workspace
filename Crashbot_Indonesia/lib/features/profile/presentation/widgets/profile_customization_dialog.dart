import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:my_flutter_app/core/constants/app_colors.dart';
import 'package:my_flutter_app/core/constants/app_sizes.dart';
import 'package:my_flutter_app/features/auth/presentation/providers/auth_provider.dart';
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
            constraints: const BoxConstraints(maxWidth: 520, maxHeight: 420),
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
                    padding: const EdgeInsets.all(AppSizes.spacingXl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bagian Pilih Avatar
                        const _SectionTitle(title: 'PILIH AVATAR'),
                        const SizedBox(height: AppSizes.spacingMd),
                        _AvatarGrid(profile: profile),
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
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingXl),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: user != null
                ? FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots()
                : null,
            builder: (context, snapshot) {
              String avatarAsset = profile.avatarAsset;
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                if (data != null) {
                  avatarAsset = data['avatarAsset'] ?? profile.avatarAsset;
                }
              }
              return GameProfileAvatar(
                avatarAsset: avatarAsset,
                size: 64,
              );
            },
          ),
          const SizedBox(width: AppSizes.spacingXl),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: user != null
                  ? FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots()
                  : null,
              builder: (context, snapshot) {
                String username = 'LOADING...';
                String playerId = 'CB-00000';

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  if (data != null) {
                    username = data['username'] ?? 'USER';
                    playerId = data['playerId'] ?? 'CB-00000';
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppSizes.fontXxl,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingSm),
                    Text(
                      'ID PEMAIN: $playerId',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: AppSizes.fontBase,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
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
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;

    return StreamBuilder<DocumentSnapshot>(
      stream: user != null
          ? FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots()
          : null,
      builder: (context, snapshot) {
        int selectedIndex = profile.selectedAvatarIndex;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null && data['avatarAsset'] != null) {
            final asset = data['avatarAsset'] as String;
            final match = RegExp(r'avatar(\d+)\.png').firstMatch(asset);
            if (match != null) {
              selectedIndex = int.parse(match.group(1)!);
            }
          }
        }

        return Wrap(
          spacing: AppSizes.spacingLg,
          runSpacing: AppSizes.spacingLg,
          children: List.generate(ProfileProvider.avatarCount, (index) {
            final avatarIndex = index + 1;
            final isSelected = selectedIndex == avatarIndex;

            return GestureDetector(
              onTap: () async {
                profile.selectAvatar(avatarIndex);
                if (user != null) {
                  try {
                    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                      'avatarAsset': 'assets/avatar$avatarIndex.png',
                    });
                  } catch (_) {}
                }
              },
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
      },
    );
  }
}

