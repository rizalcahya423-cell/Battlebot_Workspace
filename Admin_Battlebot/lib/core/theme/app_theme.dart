import 'package:flutter/material.dart';

import 'package:rc_camera_server/core/constants/app_colors.dart';

/// Centralized theme configuration for Admin Battlebot.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.liveRed),
      useMaterial3: true,
    );
  }
}
