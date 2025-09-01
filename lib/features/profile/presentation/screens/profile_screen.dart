import 'package:flutter/material.dart';
import 'package:my_habit_tracker/core/extensions%20/theme_extension.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/profile_repository.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late ProfileProvider provider;

  @override
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid;
      if (userId != null) {
        provider = ProfileProvider(ProfileRepository(userId));
        provider.loadProfile();
        setState(() {}); // trigger rebuild after provider init
      }
    });
  }


  void _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    Navigator.of(context).pop();
  }

  Future<void> _pickDob() async {
    DateTime initialDate = provider.selectedDob ?? DateTime(2000);
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) provider.updateDob(date);
  }

  @override
  Widget build(BuildContext context) {
    if (provider.userData == null && provider.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (provider.userData == null) {
      return const Scaffold(body: Center(child: Text("User data not found")));
    }

    return ChangeNotifierProvider.value(
      value: provider,
      child: Consumer<ProfileProvider>(
        builder: (context, p, _) {
          return Scaffold(
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: Text(
                      "My Profile",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        ProfileFields.nicknameField(context, p.nicknameController),
                        const SizedBox(height: 16),
                        ProfileFields.emailField(context, p.userData!['email'] ?? ''),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: p.selectedGender,
                          decoration: InputDecoration(
                            labelText: "Gender",
                            prefixIcon: const Icon(Icons.transgender),
                            filled: true,
                            fillColor: context.colors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                              BorderSide(color: context.colors.surfaceMuted, width: 1),
                            ),
                          ),
                          items: p.genderOptions
                              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) p.updateGender(value);
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: p.dobController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Date of Birth",
                            prefixIcon: const Icon(Icons.calendar_today),
                            filled: true,
                            fillColor: context.colors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: context.colors.surfaceMuted, width: 1),
                            ),
                          ),
                          onTap: _pickDob,
                          validator: (v) {
                            if (p.selectedDob == null) return "Select date of birth";
                            if (p.selectedDob!.isAfter(DateTime.now())) {
                              return "Date of birth cannot be in the future";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: p.timezoneController,
                          decoration: InputDecoration(
                            labelText: "Timezone (UTC±hh:mm)",
                            hintText: "e.g., UTC+05:30",
                            prefixIcon: const Icon(Icons.access_time),
                            filled: true,
                            fillColor: context.colors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: context.colors.surfaceMuted, width: 1),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            if (!p.timezoneRegex.hasMatch(v.trim())) {
                              return "Invalid timezone format";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        p.saving
                            ? const Center(child: CircularProgressIndicator())
                            : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final success = await p.saveProfile();
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Profile updated successfully.")),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Failed to update profile.")),
                                  );
                                }
                              }
                            },
                            icon: Icon(Icons.save, color: context.colors.textPrimary),
                            label: Text(
                              "Save Changes",
                              style: TextStyle(color: context.colors.textPrimary),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _logout,
                            icon: Icon(Icons.logout, color: context.colors.textPrimary),
                            label: Text(
                              "Logout",
                              style: TextStyle(color: context.colors.textPrimary),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colors.error,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
