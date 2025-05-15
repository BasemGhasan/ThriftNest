import 'package:flutter/material.dart';

import 'onboarding.dart';  

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // responsive sizing
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final logoH   = sh * 0.12;
    final fieldW  = sw * 0.88;
    final vSpace  = sh * 0.025;

    return Scaffold(
      // transparent AppBar with back arrow to onboarding
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThriftNestApp.primaryColor),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const OnboardingScreen(),
              ),
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
                'Register',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: ThriftNestApp.textColor,
                ),
              ),

              SizedBox(height: vSpace * 1.5),

              // Full Name
              SizedBox(
                width: fieldW,
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                  ),
                ),
              ),

              SizedBox(height: vSpace),

              // Email Address
              SizedBox(
                width: fieldW,
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                  ),
                ),
              ),

              SizedBox(height: vSpace),

              // Password
              SizedBox(
                width: fieldW,
                child: TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                ),
              ),

              SizedBox(height: vSpace),

              // Verify Password
              SizedBox(
                width: fieldW,
                child: TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Verify Password',
                  ),
                ),
              ),

              SizedBox(height: vSpace),

              // Phone Number
              SizedBox(
                width: fieldW,
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                  ),
                ),
              ),

              SizedBox(height: vSpace * 2),

              // Continue button
              SizedBox(
                width: fieldW,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: advance to next signup step or home
                  },
                  child: const Text('Continue'),
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
