import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages user profile customization state (avatar & frame selection).
/// Persists selections locally using SharedPreferences.
class ProfileProvider with ChangeNotifier {
  static const String _avatarKey = 'selected_avatar';
  static const String _frameKey = 'selected_frame';

  static const int avatarCount = 6;
  static const int frameCount = 2;

  int _selectedAvatarIndex = 1;
  int _selectedFrameIndex = 1;

  int get selectedAvatarIndex => _selectedAvatarIndex;
  int get selectedFrameIndex => _selectedFrameIndex;

  String get avatarAsset => 'assets/avatar$_selectedAvatarIndex.png';
  String get frameAsset => 'assets/frame$_selectedFrameIndex.png';

  ProfileProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedAvatarIndex = prefs.getInt(_avatarKey) ?? 1;
      _selectedFrameIndex = prefs.getInt(_frameKey) ?? 1;
      notifyListeners();
    } on Exception catch (e, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: e, stack: stackTrace),
      );
    }
  }

  Future<void> selectAvatar(int index) async {
    _selectedAvatarIndex = index;
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> selectFrame(int index) async {
    _selectedFrameIndex = index;
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_avatarKey, _selectedAvatarIndex);
      await prefs.setInt(_frameKey, _selectedFrameIndex);
    } on Exception catch (e, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: e, stack: stackTrace),
      );
    }
  }
}
