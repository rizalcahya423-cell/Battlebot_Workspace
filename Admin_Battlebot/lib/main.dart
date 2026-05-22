import 'package:flutter/material.dart';

import 'package:rc_camera_server/core/theme/app_theme.dart';
import 'package:rc_camera_server/features/broadcaster/presentation/pages/broadcaster_page.dart';

void main() {
  runApp(const AdminBattlebotApp());
}

/// Root application widget for Admin Battlebot.
class AdminBattlebotApp extends StatelessWidget {
  const AdminBattlebotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Battlebot',
      theme: AppTheme.darkTheme,
      home: const BroadcasterPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
