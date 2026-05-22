import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Manages authentication state using Firebase Auth.
/// Listens to auth state changes and notifies listeners accordingly.
class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  /// Attempts to sign in with email and password.
  /// Returns null on success, or an error message string on failure.
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// Attempts to create a new account with email and password.
  /// Returns null on success, or an error message string on failure.
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// Signs out the currently authenticated user.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
