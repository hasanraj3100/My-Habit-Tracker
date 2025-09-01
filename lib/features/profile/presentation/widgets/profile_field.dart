import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileFields {
  static TextFormField nicknameField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: "Nickname",
        prefixIcon: const Icon(Icons.person),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.surfaceMuted, width: 1),
        ),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return "Enter nickname";
        if (v.trim().length < 3) return "Name must be at least 3 characters";
        return null;
      },
    );
  }

  static TextFormField emailField(String email) {
    return TextFormField(
      initialValue: email,
      decoration: InputDecoration(
        labelText: "Email",
        prefixIcon: const Icon(Icons.email),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.surfaceMuted, width: 1),
        ),
      ),
      readOnly: true,
    );
  }
}
