import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/habits/presentation/screens/habit_list_screen.dart';

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

class SplashScreenWrapper extends StatelessWidget {
  const SplashScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // While Firebase is still initializing, show splash
        if (auth.user == null) {
          return const LoginScreen();
        } else {
          return const HabitListScreen();
        }
      },
    );
  }
}
