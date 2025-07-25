import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? user;
  bool isLoading = false;
  String? error;

  Future<void> signInWithGoogle() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      user = await _googleSignIn.signIn();
      if (user == null) {
        error = 'Sign in aborted.';
      }
    } catch (e) {
      error = 'Login failed: $e';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    user = null;
    notifyListeners();
  }
} 