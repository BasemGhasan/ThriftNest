// lib/screens/signup.dart

import 'package:flutter/material.dart';
import '../AppLogic/signup.dart'; 
import '../main.dart';
import 'onboarding.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verifyPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedRole;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _verifyPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your full name';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your email';
    final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailPattern.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Please enter a password';
    if (v.length < 8) return 'Password must be at least 8 characters long';
    final letterDigit = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)');
    if (!letterDigit.hasMatch(v)) {
      return 'Password must include at least one letter and one number';
    }
    return null;
  }

  String? _validateVerify(String? v) {
    if (v == null || v.isEmpty) return 'Please re-enter your password';
    if (v != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.isEmpty) return 'Please enter your phone number';
    if (!RegExp(r'^\d+$').hasMatch(v)) {
      return 'Phone number must contain only digits';
    }
    return null;
  }

  String? _validateRole(String? v) {
    if (v == null || v.isEmpty) return 'Please select a role';
    return null;
  }

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      final role = _selectedRole!;

      signUp(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        role: role, // ← pass it here
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final logoH = sh * 0.12;
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
                    controller: _fullNameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: _validateName,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ),
                SizedBox(height: vSpace),

                // Email Address
                SizedBox(
                  width: fieldW,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                    ),
                    validator: _validateEmail,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ),
                SizedBox(height: vSpace),

                // Password
                SizedBox(
                  width: fieldW,
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: _validatePassword,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ),
                SizedBox(height: vSpace),

                // Verify Password
                SizedBox(
                  width: fieldW,
                  child: TextFormField(
                    controller: _verifyPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Verify Password',
                    ),
                    validator: _validateVerify,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ),
                SizedBox(height: vSpace),

                // Phone Number
                SizedBox(
                  width: fieldW,
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                    ),
                    validator: _validatePhone,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ),
                SizedBox(height: vSpace),

                // Role dropdown
                SizedBox(
                  width: fieldW,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Role'),
                    value: _selectedRole,
                    items:
                        ['Seller', 'Buyer', 'Courier']
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              ),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => _selectedRole = val),
                    validator: _validateRole,
                  ),
                ),

                SizedBox(height: vSpace * 2),

                // Continue button
                SizedBox(
                  width: fieldW,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _onContinue,
                    child: const Text('Continue'),
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
