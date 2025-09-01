import 'package:flutter/material.dart';
import 'package:my_habit_tracker/core/extensions%20/theme_extension.dart';

class ProfileFields {
  static TextFormField nicknameField(
      BuildContext context,
      TextEditingController controller,
      ) {
    final colors = context.colors;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: "Nickname",
        prefixIcon: const Icon(Icons.person),
        filled: true,
        fillColor: colors.surface, // adaptive
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.surfaceMuted, width: 1),
        ),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return "Enter nickname";
        if (v.trim().length < 3) return "Name must be at least 3 characters";
        return null;
      },
    );
  }

  static TextFormField emailField(BuildContext context, String email) {
    final colors = context.colors;

    return TextFormField(
      initialValue: email,
      decoration: InputDecoration(
        labelText: "Email",
        prefixIcon: const Icon(Icons.email),
        filled: true,
        fillColor: colors.surface, // adaptive
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.surfaceMuted, width: 1),
        ),
      ),
      readOnly: true,
    );
  }
}
