
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<void> _handleForgotPassword() async {
    String? email = _emailController.text.trim();

    if (email.isEmpty) {
      // If email field is empty, show a dialog to get email
      email = await showDialog<String>(
        context: context,
        builder: (BuildContext dialogContext) {
          final TextEditingController emailDialogController = TextEditingController();
          return AlertDialog(
            title: const Text('Reset Password'),
            content: TextField(
              controller: emailDialogController,
              decoration: const InputDecoration(hintText: "Enter your email address"),
              keyboardType: TextInputType.emailAddress,
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(dialogContext).pop(null); // Close dialog, return null
                },
              ),
              TextButton(
                child: const Text('Submit'),
                onPressed: () {
                  Navigator.of(dialogContext).pop(emailDialogController.text.trim()); // Close dialog, return email
                },
              ),
            ],
          );
        },
      );
    }

    if (email == null || email.isEmpty) {
      // User cancelled dialog or entered nothing
      if (mounted) { // Check if widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email address is required to reset password.')),
        );
      }
      return;
    }

    // Basic email format validation
    final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailPattern.hasMatch(email)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid email address.')),
        );
      }
      return;
    }
    
    // Show loading indicator while sending email
    if (mounted) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
                return const Center(child: CircularProgressIndicator());
            },
        );
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) { // Check mounted after await
        Navigator.of(context).pop(); // Dismiss loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset email sent to $email. Please check your inbox.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) { // Check mounted after await
        Navigator.of(context).pop(); // Dismiss loading indicator
        String errorMessage = 'An error occurred. Please try again.';
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is not valid.';
        }
        // Consider logging e.message or e.code for debugging
        debugPrint('Forgot password error: ${e.code} - ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
       if (mounted) { // Check mounted after await
        Navigator.of(context).pop(); // Dismiss loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
        );
      }
    }
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextButton(
                    onPressed: _handleForgotPassword,
                    child: const Text('Forgot password?'),
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
