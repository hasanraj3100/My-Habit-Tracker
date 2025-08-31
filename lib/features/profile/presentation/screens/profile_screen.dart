import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../services/local_storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _loading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userId = authProvider.user?.uid;
    _loadFromCacheOrFirestore();
  }

  // Try local storage,  if missing, fetch from Firestore once
  Future<void> _loadFromCacheOrFirestore() async {
    if (_userId == null) return;

    final cachedData = await LocalStorageService.getUserData();
    if (cachedData != null) {
      setState(() {
        _userData = cachedData;
        _loading = false;
      });
    } else {
      await _fetchFromFirestore();
    }
  }

  Future<void> _fetchFromFirestore() async {
    if (_userId == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(_userId).get();
      if (doc.exists) {
        final data = doc.data()!;

        // Convert Firestore Timestamp to String
        if (data['date_of_birth'] is Timestamp) {
          data['date_of_birth'] =
              (data['date_of_birth'] as Timestamp).toDate().toIso8601String();
        }
        if (data['created_at'] is Timestamp) {
          data['created_at'] =
              (data['created_at'] as Timestamp).toDate().toIso8601String();
        }

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


  Future<void> _onRefresh() async {
    await _fetchFromFirestore();
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


    DateTime? dob;
    final dobRaw = _userData!['date_of_birth'];
    if (dobRaw != null) {
      dob = DateTime.tryParse(dobRaw.toString());
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              title: const Text("Nickname"),
              subtitle: Text(_userData!['nickname'] ?? ''),
            ),
            ListTile(
              title: const Text("Email"),
              subtitle: Text(_userData!['email'] ?? ''),
            ),
            ListTile(
              title: const Text("Gender"),
              subtitle: Text(_userData!['gender'] ?? ''),
            ),
            ListTile(
              title: const Text("Date of Birth"),
              subtitle: Text(dob != null ? DateFormat.yMMMd().format(dob) : ''),
            ),
            ListTile(
              title: const Text("Timezone"),
              subtitle: Text(_userData!['timezone'] ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}
