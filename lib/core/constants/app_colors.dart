import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF349882);
  static const secondary = Color(0xFF52B5F9);


  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF97316);

  // --- LIGHT THEME ---
  static const backgroundLight = Color(0xFFF8FAFC);  // A slightly cleaner white
  static const navBackgroundLight = Color(0xFF454444);
  static const surfaceLight = Color(0xFFFFFFFF);     // For cards, sheets, etc.
  static const surfaceMutedLight = Color(0xFFF1F5F9); // Softer card backgrounds
  static const borderLight = Color(0xFFE2E8F0);      // For dividers and borders

  static const textPrimaryLight = Color(0xFF0F172A);  // Dark slate for high contrast
  static const textSecondaryLight = Color(0xFF64748B); // Lighter slate for subtitles

  // --- DARK THEME ---
  static const backgroundDark = Color(0xFF0F172A);      // Deep slate blue
  static const surfaceDark = Color(0xFF1E293B);          // Mid-slate for cards
  static const surfaceMutedDark = Color(0xFF334155);    // Lighter slate for variation
  static const borderDark = Color(0xFF334155);          // Borders and dividers

  static const textPrimaryDark = Color(0xFFF1F5F9);      // Soft off-white
  static const textSecondaryDark = Color(0xFF94A3B8);    // Muted text


  static const primaryDark = Color(0xFF4DD8B4);        // A brighter teal for dark backgrounds
  static const secondaryDark = Color(0xFF82CFFF);      // A brighter sky blue

  static const successDark = Color(0xFF4ADE80);        // Brighter green for dark theme
  static const errorDark = Color(0xFFF87171);          // Softer, brighter red
  static const warningDark = Color(0xFFFB923C);        // Brighter orange
}
