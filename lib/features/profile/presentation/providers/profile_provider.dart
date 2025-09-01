import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository repository;

  Map<String, dynamic>? userData;
  bool loading = true;
  bool saving = false;

  String? selectedGender = "Male";
  DateTime? selectedDob;

  final nicknameController = TextEditingController();
  final dobController = TextEditingController();
  final timezoneController = TextEditingController();

  final List<String> genderOptions = ["Male", "Female", "Others"];
  final RegExp timezoneRegex = RegExp(r'^[+-](0\d|1[0-4])$');

  ProfileProvider(this.repository);

  Future<void> loadProfile() async {
    loading = true;
    notifyListeners();

    final data = await repository.fetchFromCacheOrFirestore();
    if (data != null) _initControllers(data);

    userData = data;
    loading = false;
    notifyListeners();
  }

  void _initControllers(Map<String, dynamic> data) {
    nicknameController.text = data['nickname'] ?? '';
    selectedGender = data['gender'] ?? "Male";
    dobController.text = data['date_of_birth'] != null
        ? DateFormat.yMMMd().format(DateTime.parse(data['date_of_birth']))
        : '';
    timezoneController.text = data['timezone'] ?? '';
    if (data['date_of_birth'] != null) {
      selectedDob = DateTime.tryParse(data['date_of_birth']);
    }
  }

  Future<bool> saveProfile() async {
    saving = true;
    notifyListeners();
    try {
      final updatedData = {
        "nickname": nicknameController.text.trim(),
        "gender": selectedGender,
        "date_of_birth": selectedDob?.toIso8601String(),
        "timezone": timezoneController.text.trim(),
      };

      await repository.saveProfile(updatedData);

      userData = {...?userData, ...updatedData};
      saving = false;
      notifyListeners();
      return true;
    } catch (_) {
      saving = false;
      notifyListeners();
      return false;
    }
  }

  void updateDob(DateTime dob) {
    selectedDob = dob;
    dobController.text = DateFormat.yMMMd().format(dob);
    notifyListeners();
  }

  void updateGender(String gender) {
    selectedGender = gender;
    notifyListeners();
  }
}
