import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'AppLogic/firebase_options.dart';
import 'CommonScreens/AuthWrapper.dart'; // Import AuthWrapper

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ThriftNestApp()); // Root app
}

class ThriftNestApp extends StatelessWidget {
  const ThriftNestApp({super.key});

  // brand colors (can be moved to a theme file later)
  static const Color backgroundColor = Color(0xFFEFE9DC);
  static const Color primaryColor = Color(0xFF7BA05B);
  static const Color textColor = Color(0xFF2E3C48);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ThriftNest',
      theme: ThemeData( // Keep the theme definition here
        scaffoldBackgroundColor: backgroundColor,
        primaryColor: primaryColor,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primaryColor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
          errorStyle: const TextStyle(color: Colors.red),
          labelStyle: TextStyle(color: textColor),
        ),
        textTheme: const TextTheme(bodyMedium: TextStyle(color: textColor)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: const AuthWrapper(), // AuthWrapper is the new home
    );
  }
}