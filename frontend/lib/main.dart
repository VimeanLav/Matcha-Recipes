import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'screens/auth_gate_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('Firebase projectId: ${Firebase.app().options.projectId}');

  // Supabase
  await Supabase.initialize(
    url: 'https://wodgfunkywgacmbcxbtt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndvZGdmdW5reXdnYWNtYmN4YnR0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk2OTEwNzcsImV4cCI6MjA5NTI2NzA3N30.TBw_m9re-HBOm7JGH8803oVKpfiI80stG9KyKDQzfJQ',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Matcha Recipes',

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C8A56),
          surface: const Color(0xFFFBFAF4),
        ),

        scaffoldBackgroundColor: const Color(0xFFFBFAF4),

        textTheme: const TextTheme(
          displaySmall: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            height: 1.08,
            color: Color(0xFF263025),
          ),

          headlineMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6A7169),
          ),
        ),
      ),

      home: const AuthGateScreen(),
    );
  }
}