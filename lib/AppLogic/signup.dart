import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../CommonScreens/VerifyEmailScreen.dart'; // For email verification screen

Future<void> signUp({
  required String fullName,
  required String email,
  required String password,
  required String phone,
  required String role,
  required BuildContext context,
}) async {
  try {
    final cred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    
    final User? firebaseUser = cred.user;

    if (firebaseUser == null) {
      // Handle error: user creation somehow failed silently or user is null
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup failed: Could not get user details.')),
      );
      return;
    }

    // Send verification email
    try {
      await firebaseUser.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification email sent to $email. Please check your inbox (and spam folder).'),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      debugPrint("Error sending verification email: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not send verification email: ${e.toString()}')),
      );
    }

    // Create Firestore document for the user
    final uid = firebaseUser.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role, // Role is important
      'createdAt': FieldValue.serverTimestamp(),
      // 'emailVerified': firebaseUser.emailVerified // This will be false initially
    });

    // Navigate to VerifyEmailScreen, passing the role for later redirection
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => VerifyEmailScreen(userRole: role)), // Pass the role
    );

  } on FirebaseAuthException catch (e) {
    final message = e.message ?? 'Signup failed. Please try again.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
