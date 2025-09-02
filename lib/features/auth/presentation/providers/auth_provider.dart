import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/local_storage_service.dart';
import '../../data/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  User? _user;
  bool _isLoading = true;

  User? get user => _user;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _repository.authStateChanges.listen((user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> signUp(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.signUp(email, password);
      _user = FirebaseAuth.instance.currentUser;
      if (_user != null) {
        await LocalStorageService.saveUserId(_user!.uid);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.signIn(email, password);
      _user = FirebaseAuth.instance.currentUser;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _user = null;
    await LocalStorageService.removeUserId();
    await LocalStorageService.removeUserData();
    notifyListeners();
  }

  // Save additional profile info to Firestore
  Future<void> registerUserProfile({
    required String nickname,
    required String gender,
    required String timezone,
    required DateTime dateOfBirth,
  }) async {
    if (_user == null) return;
    final userId = _user!.uid;
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);

    await docRef.set({
      'nickname': nickname,
      'gender': gender,
      'timezone': timezone,
      'date_of_birth': dateOfBirth,
      'email': _user!.email,
      'created_at': FieldValue.serverTimestamp(),
    });

    // Save locally for faster profile load
    await LocalStorageService.saveUserData({
      'nickname': nickname,
      'gender': gender,
      'timezone': timezone,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'email': _user!.email,
    });

    // Populate default categories
    await _populateDefaultCategories(userId);
  }

  Future<void> _populateDefaultCategories(String userId) async {
    final defaultCategories = [
      'Health',
      'Study',
      'Fitness',
      'Productivity',
      'Mental Health',
    ];

    final prefRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('preferences');

    final docSnapshot = await prefRef.get();
    if (!docSnapshot.exists || !(docSnapshot.data()?['categories'] is List)) {
      await prefRef.set({
        'categories': defaultCategories,
      }, SetOptions(merge: true));
    }
  }


  // Set current user from stored userId
  Future<void> setUserById(String userId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.uid == userId) {
      _user = user;
      notifyListeners();
    }
  }
}

