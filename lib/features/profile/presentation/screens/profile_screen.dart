import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../services/local_storage_service.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _loading = true;
  String? _userId;
  bool _saving = false;


  final _formKey = GlobalKey<FormState>();
  final RegExp _timezoneRegex = RegExp(r'^[+-](0\d|1[0-4])$');

  late TextEditingController _nicknameController;
  late TextEditingController _dobController;
  late TextEditingController _timezoneController;

  String _selectedGender = "Male";
  DateTime? _selectedDob;

  final List<String> _genderOptions = ["Male", "Female", "Others"];

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userId = authProvider.user?.uid;
    _loadFromCacheOrFirestore();
  }

  Future<void> _loadFromCacheOrFirestore() async {
    if (_userId == null) return;

    final cachedData = await LocalStorageService.getUserData();
    if (cachedData != null) {
      _initControllers(cachedData);
      setState(() {
        _userData = cachedData;
        _loading = false;
      });
    } else {
      await _fetchFromFirestore();
    }
  }

  void _initControllers(Map<String, dynamic> data) {
    _nicknameController = TextEditingController(text: data['nickname'] ?? '');
    _selectedGender = data['gender'] ?? "Male";
    _dobController = TextEditingController(
        text: data['date_of_birth'] != null
            ? DateFormat.yMMMd().format(DateTime.parse(data['date_of_birth']))
            : '');
    _timezoneController = TextEditingController(text: data['timezone'] ?? '');
    if (data['date_of_birth'] != null) {
      _selectedDob = DateTime.tryParse(data['date_of_birth']);
    }
  }

  Future<void> _fetchFromFirestore() async {
    if (_userId == null) return;

    try {
      final doc =
      await FirebaseFirestore.instance.collection('users').doc(_userId).get();
      if (doc.exists) {
        final data = doc.data()!;

        if (data['date_of_birth'] is Timestamp) {
          data['date_of_birth'] =
              (data['date_of_birth'] as Timestamp).toDate().toIso8601String();
        }
        if (data['created_at'] is Timestamp) {
          data['created_at'] =
              (data['created_at'] as Timestamp).toDate().toIso8601String();
        }

        _initControllers(data);

        setState(() {
          _userData = data;
          _loading = false;
        });

        await LocalStorageService.saveUserData(data);
      } else {
        setState(() {
          _userData = null;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final userRef =
      FirebaseFirestore.instance.collection('users').doc(_userId);

      final updatedData = {
        "nickname": _nicknameController.text.trim(),
        "gender": _selectedGender,
        "date_of_birth": _selectedDob?.toIso8601String(),
        "timezone": _timezoneController.text.trim(),
      };

      await userRef.update(updatedData);

      setState(() {
        _userData = {...?_userData, ...updatedData};
      });

      await LocalStorageService.saveUserData(_userData!);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully.")),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }


  Future<void> _onRefresh() async {
    await _fetchFromFirestore();
  }

  void _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    Navigator.of(context).pop(); // navigate back to login
  }

  Future<void> _pickDob() async {
    DateTime initialDate = _selectedDob ?? DateTime(2000);
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDob = date;
        _dobController.text = DateFormat.yMMMd().format(date);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    if (_loading && _userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userData == null) {
      return const Scaffold(
        body: Center(child: Text("User data not found")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Nickname
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: "Nickname",
                  border: OutlineInputBorder(),
                ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return "Enter nickname";
                    }
                    if (v.trim().length < 3) {
                      return "Name must be at least 3 characters";
                    }
                    return null;
                  },
              ),
              const SizedBox(height: 12),

              // Email (not editable)
              TextFormField(
                initialValue: _userData!['email'] ?? '',
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 12),

              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: "Gender",
                  border: OutlineInputBorder(),
                ),
                items: _genderOptions
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedGender = value);
                },
              ),
              const SizedBox(height: 12),

              // DOB
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(
                  labelText: "Date of Birth",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _pickDob,
                validator: (v) {
                  if (_selectedDob == null) return "Select date of birth";
                  if (_selectedDob!.isAfter(DateTime.now())) {
                    return "Date of birth cannot be in the future";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Timezone
              TextFormField(
                controller: _timezoneController,
                decoration: const InputDecoration(
                  labelText: "Timezone (UTC±hh:mm)",
                  hintText: "e.g., UTC+05:30",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null; // optional
                  if (!_timezoneRegex.hasMatch(v.trim())) {
                    return "Invalid timezone format";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),


              // Save Button
              _saving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              // Logout Button
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
