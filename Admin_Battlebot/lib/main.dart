import 'package:flutter/material.dart';
import 'agora_broadcaster_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Battlebot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const AgoraBroadcasterScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
