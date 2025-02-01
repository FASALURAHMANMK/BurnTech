import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _errorMessage;
  String? _uid;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  String? get uid => _uid;
  Future<void> checkUidInPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getString('uid') != null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loginUser(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _uid = userCredential.user!.uid;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', _uid!);
      _isLoggedIn = true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = "An unexpected error occurred.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logoutUser(BuildContext context) async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    _uid = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}