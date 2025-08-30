import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  User? _user;

  User? get user => _user;

  AuthProvider() {
    _repository.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signUp(String email, String password) async {
    await _repository.signUp(email, password);
  }

  Future<void> signIn(String email, String password) async {
    await _repository.signIn(email, password);
  }

  Future<void> signOut() async {
    await _repository.signOut();
  }
}
