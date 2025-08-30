import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nicknameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String gender = 'Male';
  DateTime? dateOfBirth;
  bool agreeTerms = false;
  bool isLoading = false;

  String get timezone => DateTime.now().timeZoneName;

  // Validators
  String? validateNickname(String? value) {
    if (value == null || value.trim().length < 3) {
      return 'Nickname must be at least 3 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Must contain uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Must contain lowercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Must contain a number';
    return null;
  }

  Future<void> _selectDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(1900),
      lastDate: today,
    );
    if (picked != null) {
      setState(() => dateOfBirth = picked);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must agree to terms and conditions")),
      );
      return;
    }
    if (dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select your date of birth")),
      );
      return;
    }

    setState(() => isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Sign up in Firebase Auth
      await authProvider.signUp(emailController.text.trim(), passwordController.text.trim());

      // Save profile info to Firestore
      await authProvider.registerUserProfile(
        nickname: nicknameController.text.trim(),
        gender: gender,
        timezone: timezone,
        dateOfBirth: dateOfBirth!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful!")),
      );

      if (mounted) {
        Navigator.of(context).pop(); // go back to SplashWrapper for reactive navigation
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nicknameController,
                decoration: const InputDecoration(labelText: "Nickname"),
                validator: validateNickname,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                validator: validatePassword,
                obscureText: true,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: gender,
                items: const [
                  DropdownMenuItem(value: "Male", child: Text("Male")),
                  DropdownMenuItem(value: "Female", child: Text("Female")),
                  DropdownMenuItem(value: "Other", child: Text("Other")),
                ],
                onChanged: (value) => setState(() => gender = value!),
                decoration: const InputDecoration(labelText: "Gender"),
              ),
              const SizedBox(height: 10),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: dateOfBirth == null
                      ? "Date of Birth"
                      : DateFormat.yMMMd().format(dateOfBirth!),
                ),
                onTap: _selectDate,
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                value: agreeTerms,
                onChanged: (value) => setState(() => agreeTerms = value ?? false),
                title: const Text("Agree to our terms and conditions"),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _register,
                child: const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
