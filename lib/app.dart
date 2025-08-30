import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_habit_tracker/services/local_storage_service.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/habits/presentation/screens/habit_list_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My Habit Tracker',
        theme: ThemeData(primarySwatch: Colors.blue),
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
        authProvider.setUserById(storedUserId); // we need to add this method
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