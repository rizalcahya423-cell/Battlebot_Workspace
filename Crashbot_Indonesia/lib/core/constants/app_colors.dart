import 'package:flutter/material.dart';

/// Centralized color constants for the entire app.
/// Semua warna hardcoded dikumpulkan di sini agar konsisten & DRY (§5.2).
class AppColors {
  AppColors._();

  // ─── Base / Background ───
  static const Color scaffoldBackground = Color(0xFF070B19);
  static const Color darkBase = Color(0xFF070010);
  static const Color surfaceDark = Color(0xFF0D0D20);
  static const Color cardDark = Color(0xFF1A1A2E);

  // ─── Primary Blues ───
  static const Color primaryBlue = Color(0xFF2979FF);
  static const Color accentBlue = Color(0xFF42A5F5);
  static const Color lightBlue = Color(0xFF00E5FF);
  static const Color deepNavy = Color(0xFF1A237E);
  static const Color royalBlue = Color(0xFF0D47A1);

  // ─── Reds ───
  static const Color dangerRed = Color(0xFFFF1744);
  static const Color deepRed = Color(0xFFD50000);

  // ─── Greens ───
  static const Color successGreen = Color(0xFF00E676);
  static const Color batteryGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color tealGreen = Color(0xFF00E5A0);

  // ─── Yellows / Oranges ───
  static const Color warningYellow = Color(0xFFFFB300);
  static const Color bronzeOrange = Color(0xFFE67E22);

  // ─── Rank Colors ───
  static const Color rankGold = Color(0xFFFFD700);
  static const Color rankSilver = Color(0xFFB0BEC5);
  static const Color rankBronze = Color(0xFFE67E22);
  static const Color rankEmerald = Color(0xFF00E5A0);
  static const Color rankPurple = Color(0xFF9C5FFF);

  // ─── Gradients (profile avatar) ───
  static const Color gradientPurple = Color(0xFF4A148C);

  // ─── Cyan (login accent) ───
  static const Color cyanAccent = Colors.cyanAccent;

  // ─── Pressed button states ───
  static const Color buttonPressed = Color(0xFF333333);
  static const Color buttonDefault = Color(0xFF222222);
  static const Color buttonGradientLightPressed = Color(0xFF3A3A3A);
  static const Color buttonGradientDarkPressed = Color(0xFF2A2A2A);
  static const Color buttonGradientLight = Color(0xFF2A2A2A);
  static const Color buttonGradientDark = Color(0xFF1A1A1A);
}
