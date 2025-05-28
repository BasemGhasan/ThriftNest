// lib/AppLogic/login.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../SellerScreens/SellerManageListing.dart';
import 'package:thirft_nest/BuyerHomePage.dart';
import '../courierScreens/courier_dashboard.dart';

Future<void> logIn({
  required String email,
  required String password,
  required BuildContext context,
}) async {
  try {
    // 1) Sign in
    final cred = await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: email, password: password);

    // 2) Fetch profile from Firestore
    final snap = await FirebaseFirestore.instance
      .collection('users')
      .doc(cred.user!.uid)
      .get();
    final data = snap.data();
    final role = data?['role'] as String? ?? 'Buyer';  // default if missing
    final name = data?['fullName'] as String? ?? 'User';

    // 3) Welcome SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Welcome back, $name!'),
        duration: const Duration(seconds: 1),
      ),
    );

    // 4) Delay briefly so user can read the message
    await Future.delayed(const Duration(milliseconds: 800));

    // 5) Redirect based on role
    Widget nextScreen;
    switch (role) {
      case 'Seller':
        nextScreen = const SellerManageListing();
        break;
      case 'Courier':
        nextScreen = const CourierDashboard();
        break;
      case 'Buyer':
        nextScreen = BuyerApp();
      default:
        nextScreen = const CourierDashboard();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }
  on FirebaseAuthException catch (e) {
    // existing error mapping
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No account found for that email.';
        break;
      case 'wrong-password':
      case 'invalid-email':
      case 'invalid-credential': // catch web case too
        message = 'Wrong email or password. Please try again.';
        break;
      default:
        message = 'Login failed. Please check your credentials.';
    }
    ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));
  }
}
