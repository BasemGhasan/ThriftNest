import 'package:flutter/material.dart';
import '../main.dart';
import 'LoginScreen.dart';
import 'SignupScreen.dart';

class Onboarding extends StatelessWidget {
  const Onboarding ({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ThriftNest',
      theme: ThemeData(
        scaffoldBackgroundColor: ThriftNestApp.backgroundColor,
        primaryColor: ThriftNestApp.primaryColor,

        // — Add this block here —
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: ThriftNestApp.primaryColor),
          ),
          // RED error styling:
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
          errorStyle: const TextStyle(color: Colors.red),
          labelStyle: TextStyle(color: ThriftNestApp.textColor),
        ),

        // — end of added block —
        textTheme: const TextTheme(bodyMedium: TextStyle(color: ThriftNestApp.textColor)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ThriftNestApp.primaryColor,
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
      home: const OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // use MediaQuery to obtain sizes
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final logoHeight = screenHeight * 0.15;
    final illustrationWidth = screenWidth * 0.8;
    final illustrationHeight = screenHeight * 0.43;
    final buttonWidth = screenWidth * 0.65;
    final verticalSpacing = screenHeight * 0.02;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- LOGO + APP NAME ---
              Center(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'lib/images/ThriftNest_Logo.png',
                        height: logoHeight,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: verticalSpacing),
                    const Text(
                      'ThriftNest',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: ThriftNestApp.textColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: verticalSpacing),
              // --- ONBOARDING ILLUSTRATION ---
              Container(
                height: illustrationHeight,
                width: illustrationWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.asset(
                  'lib/images/Onboarding_image.png',
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: verticalSpacing * 2.5),
              // --- DESCRIPTION TEXT ---
              const Text(
                'A mobile app designed for university students to easily buy and sell secondhand items.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: ThriftNestApp.textColor,
                ),
              ),
              SizedBox(height: verticalSpacing * 1.5),
              // --- GET STARTED BUTTONS ---
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: buttonWidth,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text('Log in'),
                    ),
                  ),
                  SizedBox(height: verticalSpacing),
                  SizedBox(
                    height: 50,
                    width: buttonWidth,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text('Sign up'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
