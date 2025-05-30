import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ← relative imports, matching your project tree exactly
import '../SellerScreens/SellerManageListing.dart';
import '../BuyerScreens/BuyerHomePage.dart';
import '../CourierScreens/courier_dashboard.dart';

Future<void> logIn({
  required String email,
  required String password,
  required BuildContext context,
}) async {
  try {
    final cred = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(cred.user!.uid)
        .get();
    final data = snap.data();
    final role = data?['role'] as String?;
    final name = data?['fullName'] as String? ?? 'User';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Welcome back, $name!'),
        duration: const Duration(seconds: 1),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 800));

    if (role == 'Seller') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SellerManageListing()),
      );
    } else if (role == 'Courier') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CourierDashboard()),
      );
    } else if (role == 'Buyer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BuyerHomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unrecognized role: ${role ?? 'None'}')),
      );
    }
  } on FirebaseAuthException catch (e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No account found for that email.';
        break;
      case 'wrong-password':
      case 'invalid-email':
      case 'invalid-credential':
        message = 'Wrong email or password.';
        break;
      default:
        message = 'Login failed. Please try again.';
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
