import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:my_habit_tracker/features/habits/presentation/providers/habit_provider.dart';
import 'features/habits/presentation/providers/quote_provider.dart';
import 'firebase_options.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => QuoteProvider()..fetchQuotes()), // 👈 fetch 5 quotes at startup
      ],
      child: const MyApp(),
    ),
  );
}
