import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

/// Manages robot directional control state and syncs with Firebase RTDB.
/// Each direction (forward, backward, left, right) is represented as 0 or 1.
class ControlProvider with ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  ControlProvider() {
    _dbRef.child('rc_control').keepSynced(true);
  }

  int _f = 0;
  int _b = 0;
  int _l = 0;
  int _r = 0;

  int get f => _f;
  int get b => _b;
  int get l => _l;
  int get r => _r;

  /// Updates a directional control value and syncs to Firebase.
  ///
  /// [direction] must be one of: "F", "B", "L", "R".
  /// [isPressed] toggles the value between 1 (pressed) and 0 (released).
  void updateDirection(String direction, {required bool isPressed}) {
    final int value = isPressed ? 1 : 0;

    switch (direction) {
      case 'F':
        _f = value;
      case 'B':
        _b = value;
      case 'L':
        _l = value;
      case 'R':
        _r = value;
    }

    notifyListeners();
    _syncWithFirebase();
  }

  void _syncWithFirebase() {
    _dbRef.child('rc_control').update({'F': _f, 'B': _b, 'L': _l, 'R': _r});
  }
}
