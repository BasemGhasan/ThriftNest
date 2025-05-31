import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import role-specific dashboards\
import '../../SellerScreens/SellerManageListing.dart';
import '../../BuyerScreens/BuyerHomePage.dart';
import '../../CourierScreens/courier_dashboard.dart';
import 'LoginScreen.dart'; // For logging out or going back

class VerifyEmailScreen extends StatefulWidget {
  final String userRole; // Passed from signUp function

  const VerifyEmailScreen({super.key, required this.userRole});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isSendingVerification = false;
  bool _canResendEmail = true;
  Timer? _timer;
  int _resendCooldown = 60; // Cooldown in seconds
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    // Check if user is already verified (e.g., if they verified then came back to this screen)
    if (FirebaseAuth.instance.currentUser?.emailVerified ?? false) {
      _navigateToDashboard();
      return;
    }

    // Periodically check email verification status
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user?.emailVerified ?? false) {
        timer.cancel();
        _cooldownTimer?.cancel(); // Cancel cooldown timer if active
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Email successfully verified! Welcome, ${user?.displayName ?? user?.email}!')),
          );
          _navigateToDashboard();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    setState(() {
      _canResendEmail = false;
      _resendCooldown = 60; // Reset cooldown duration
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown == 0) {
        timer.cancel();
        if (mounted) {
          setState(() => _canResendEmail = true);
        }
      } else {
        if (mounted) {
          setState(() => _resendCooldown--);
        }
      }
    });
  }

  Future<void> _sendVerificationEmail() async {
    if (!_canResendEmail) return;

    setState(() => _isSendingVerification = true);
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent. Please check your inbox (and spam folder).')),
        );
      }
      _startResendCooldown(); // Start cooldown after successful send
    } catch (e) {
      debugPrint("Error resending verification email: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resend verification email: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingVerification = false);
      }
    }
  }

  Future<void> _navigateToDashboard() async {
    // Fetch user details again in case they were updated, though role comes from widget.userRole
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) { // Should not happen if emailVerified is true
        _handleLogout();
        return;
    }

    // Use widget.userRole passed from signup
    String roleToUse = widget.userRole;

    if (roleToUse.isEmpty && mounted) { // Fallback if role wasn't passed or is empty
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        roleToUse = (userDoc.data() as Map<String, dynamic>?)?['role'] as String? ?? '';
    }
    
    if (!mounted) return;

    Widget destination;
    if (roleToUse == 'Seller') {
      destination = const SellerManageListing();
    } else if (roleToUse == 'Buyer') {
      destination = const BuyerHomePage();
    } else if (roleToUse == 'Courier') {
      destination = const CourierDashboard();
    } else {
      // Fallback or error: Role not found, navigate to login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User role not found. Please log in again. Role: "$roleToUse"')),
      );
      _handleLogout(); // Log out and go to login screen
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => destination),
      (Route<dynamic> route) => false, // Remove all previous routes
    );
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
    );
  }


  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'your email address';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cancel and Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'A verification email has been sent to:',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                userEmail,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'Please click the link in the email to verify your account. If you don\'t see it, check your spam folder.',
                textAlign: TextAlign.center,
              ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0), // Button padding
                  ),
                  onPressed: (_isSendingVerification || !_canResendEmail) ? null : _sendVerificationEmail,
                  child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isSendingVerification
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                      : const Icon(Icons.email),
                    const SizedBox(width: 12), // Space between icon and text
                    Text(
                    _canResendEmail ? 'Resend Verification Email' : 'Resend in $_resendCooldown s',
                    ),
                  ],
                  ),
                ),
                const SizedBox(height: 16),
               TextButton(
                child: const Text('Already Verified? Check Status & Continue'),
                onPressed: () async {
                  await FirebaseAuth.instance.currentUser?.reload();
                  if (FirebaseAuth.instance.currentUser?.emailVerified ?? false) {
                     if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Email successfully verified!')),
                        );
                        _navigateToDashboard();
                     }
                  } else {
                     if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Email not verified yet. Please check your email or resend.')),
                        );
                     }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
