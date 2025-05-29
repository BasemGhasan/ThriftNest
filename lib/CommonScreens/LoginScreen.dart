
import 'package:flutter/material.dart';
import '../AppLogic/login.dart';    
import 'onboarding.dart';           
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey            = GlobalKey<FormState>();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your email';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Please enter your password';
    return null;
  }

  void _onSignIn() {
    if (_formKey.currentState!.validate()) {
      logIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // responsive sizing
    final sw     = MediaQuery.of(context).size.width;
    final sh     = MediaQuery.of(context).size.height;
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
              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
          child: Form(
            key: _formKey,
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
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                    ),
                    validator: _validateEmail,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ),

                SizedBox(height: vSpace),

                // password field
                SizedBox(
                  width: fieldW,
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                    validator: _validatePassword,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ),

                SizedBox(height: vSpace * 2),

                // Sign In button
                SizedBox(
                  width: fieldW,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _onSignIn,
                    child: const Text('Sign In'),
                  ),
                ),

                SizedBox(height: vSpace),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
