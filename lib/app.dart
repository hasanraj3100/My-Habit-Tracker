import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:my_habit_tracker/services/local_storage_service.dart';
import 'package:my_habit_tracker/core/constants/app_colors.dart';
import 'core/providers/app_theme_provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/habits/presentation/screens/habit_list_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My Habit Tracker',

        // Light theme
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.backgroundLight,
          cardColor: AppColors.surfaceLight,
          dividerColor: AppColors.borderLight,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: AppColors.textPrimaryLight),
            bodyMedium: TextStyle(color: AppColors.textSecondaryLight),
          ),
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.surfaceLight,
            background: AppColors.backgroundLight,
            error: AppColors.error,
          ),
        ),

        // Dark theme
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: AppColors.primaryDark,
          scaffoldBackgroundColor: AppColors.backgroundDark,
          cardColor: AppColors.surfaceDark,
          dividerColor: AppColors.borderDark,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: AppColors.textPrimaryDark),
            bodyMedium: TextStyle(color: AppColors.textSecondaryDark),
          ),
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primaryDark,
            secondary: AppColors.secondaryDark,
            surface: AppColors.surfaceDark,
            background: AppColors.backgroundDark,
            error: AppColors.errorDark,
          ),
        ),

        // Decide theme based on provider
        themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

        home: const SplashScreenWrapper(),
      ),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () async {
      final storedUserId = await LocalStorageService.getUserId();
      if (storedUserId != null) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.setUserById(storedUserId); // make sure this method exists
      }
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (_showSplash) {
      return const SplashScreen();
    }

    if (auth.user == null) {
      return const LoginScreen();
    } else {
      return const HabitListScreen();
    }
  }
}
