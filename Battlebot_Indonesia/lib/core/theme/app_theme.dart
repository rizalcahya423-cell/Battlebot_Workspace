import 'package:flutter/material.dart';

import 'package:my_flutter_app/core/constants/app_colors.dart';

/// Centralized theme configuration (§5.2 DRY).
/// ThemeData dipindahkan dari main.dart ke sini.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      useMaterial3: true,
    );
  }
}
