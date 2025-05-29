import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'AppLogic/firebase_options.dart';
import 'CommonScreens/onboarding.dart';
Future <void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Onboarding());
}

class ThriftNestApp extends StatelessWidget {
  const ThriftNestApp({super.key});

  // brand colors
  static const Color backgroundColor = Color(0xFFEFE9DC);
  static const Color primaryColor = Color(0xFF7BA05B);
  static const Color textColor = Color(0xFF2E3C48);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const ThriftNestApp(),
      
    );
  }
}
