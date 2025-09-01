import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

extension AppThemeColors on BuildContext {
  _ThemeColors get colors => Theme.of(this).brightness == Brightness.dark
      ? _ThemeColors.dark()
      : _ThemeColors.light();
}

class _ThemeColors {
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color primary;
  final Color secondary;
  final Color success;
  final Color error;
  final Color warning;

  _ThemeColors.light()
      : background = AppColors.backgroundLight,
        surface = AppColors.surfaceLight,
        surfaceMuted = AppColors.surfaceMutedLight,
        border = AppColors.borderLight,
        textPrimary = AppColors.textPrimaryLight,
        textSecondary = AppColors.textSecondaryLight,
        primary = AppColors.primary,
        secondary = AppColors.secondary,
        success = AppColors.success,
        error = AppColors.error,
        warning = AppColors.warning;

  _ThemeColors.dark()
      : background = AppColors.backgroundDark,
        surface = AppColors.surfaceDark,
        surfaceMuted = AppColors.surfaceMutedDark,
        border = AppColors.borderDark,
        textPrimary = AppColors.textPrimaryDark,
        textSecondary = AppColors.textSecondaryDark,
        primary = AppColors.primaryDark,
        secondary = AppColors.secondaryDark,
        success = AppColors.successDark,
        error = AppColors.errorDark,
        warning = AppColors.warningDark;
}
