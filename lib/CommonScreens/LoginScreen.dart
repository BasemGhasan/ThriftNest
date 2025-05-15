import 'package:flutter/material.dart';

import 'onboarding.dart';

class ThriftNestApp extends StatelessWidget {
  const ThriftNestApp({Key? key}) : super(key: key);

  // brand colours
  static const Color backgroundColor = Color(0xFFEFE9DC);
  static const Color primaryColor    = Color(0xFF7BA05B);
  static const Color textColor       = Color(0xFF2E3C48);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThriftNest',
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        primaryColor: primaryColor,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: textColor),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primaryColor),
          ),
          labelStyle: TextStyle(color: textColor),
        ),
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
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // responsive sizing
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final logoH  = sh * 0.12;
    final fieldW = sw * 0.88;
    final vSpace = sh * 0.025;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThriftNestApp.primaryColor),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const OnboardingScreen()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: vSpace * 2),

              // logo
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'lib/images/ThriftNest_Logo.png',
                  height: logoH,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: vSpace),

              // title
              const Text(
                'Log In',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: ThriftNestApp.textColor,
                ),
              ),

              SizedBox(height: vSpace * 1.5),

              // email field
              SizedBox(
                width: fieldW,
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                  ),
                ),
              ),

              SizedBox(height: vSpace),

              // password field
              SizedBox(
                width: fieldW,
                child: TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                ),
              ),

              // forgot password link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: navigate to password recovery
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    textStyle: const TextStyle(fontSize: 14),
                    foregroundColor: ThriftNestApp.primaryColor,
                  ),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      decorationThickness: 2,
                    ),
                  ),
                ),
              ),

              SizedBox(height: vSpace * 2),

              // Sign In button
              SizedBox(
                width: fieldW,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: perform login
                  },
                  child: const Text('Log In'),
                ),
              ),

              SizedBox(height: vSpace),
            ],
          ),
        ),
      ),
    );
  }
}