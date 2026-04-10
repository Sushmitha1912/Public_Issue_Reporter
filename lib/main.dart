import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PublicReporterApp());
}

class PublicReporterApp extends StatelessWidget {
  const PublicReporterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Public Issue Reporter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}