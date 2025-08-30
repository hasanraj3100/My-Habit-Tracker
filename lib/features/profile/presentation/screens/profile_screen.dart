import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>?> _fetchUserData(String userId) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return doc.exists ? doc.data() : null;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserData(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("User data not found"));
          }

          final data = snapshot.data!;
          final dob = (data['date_of_birth'] as Timestamp?)?.toDate();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                ListTile(
                  title: const Text("Nickname"),
                  subtitle: Text(data['nickname'] ?? ''),
                ),
                ListTile(
                  title: const Text("Email"),
                  subtitle: Text(data['email'] ?? ''),
                ),
                ListTile(
                  title: const Text("Gender"),
                  subtitle: Text(data['gender'] ?? ''),
                ),
                ListTile(
                  title: const Text("Date of Birth"),
                  subtitle: Text(dob != null ? DateFormat.yMMMd().format(dob) : ''),
                ),
                ListTile(
                  title: const Text("Timezone"),
                  subtitle: Text(data['timezone'] ?? ''),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
