import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'AppLogic/firebase_options.dart';
import 'CommonScreens/onboarding.dart';
Future <void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ThriftNestApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const ThriftNestApp(),
      
    );
  }
}
