import 'package:flutter/material.dart';
import '../../../services/local_storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    loadTheme(); // Load persisted theme at startup
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    _storageService.saveDarkMode(_isDarkMode); // persist
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
    _storageService.saveDarkMode(value); // persist
  }

  Future<void> loadTheme() async {
    _isDarkMode = await _storageService.getDarkMode() ?? false;
    notifyListeners();
  }
}
