// lib/AppLogic/signup.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../SellerScreens/SellerManageListing.dart';
import 'package:thirft_nest/BuyerHomePage.dart';
import '../courierScreens/courier_dashboard.dart';

Future<void> signUp({
  required String fullName,
  required String email,
  required String password,
  required String phone,
  required String role,
  required BuildContext context,
}) async {
  try {
    // 1) Create user in Firebase Auth
    final cred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    final uid = cred.user!.uid;

    // 2) Save extra profile fields + role to Firestore
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'fullName':  fullName,
      'email':     email,
      'phone':     phone,
      'role':      role,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 3) Show a congrats message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 Congratulations, $fullName! You signed up as a $role.'),
        duration: const Duration(seconds: 2),
      ),
    );

    // 4) Give the user a moment to see the SnackBar
    await Future.delayed(const Duration(milliseconds: 800));

    // 5) Redirect based on role, or show error if unrecognized
    if (role == 'Seller') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SellerManageListing()),
      );
    } else if (role == 'Buyer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BuyerApp()),
      );
    } else if (role == 'Courier') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CourierDashboard()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unrecognized role: $role')),
      );
      return;
    }
  } on FirebaseAuthException catch (e) {
    final message = e.message ?? 'Signup failed. Please try again.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
