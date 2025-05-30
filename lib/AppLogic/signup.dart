import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ← relative imports again
import '../SellerScreens/SellerManageListing.dart';
import '../BuyerScreens/BuyerHomePage.dart';
import '../CourierScreens/courier_dashboard.dart';

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
    final uid = cred.user!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('🎉 $fullName, you’ve signed up successfully as a $role!'),
        duration: const Duration(seconds: 2),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 800));

    if (role == 'Seller') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SellerManageListing()),
      );
    } else if (role == 'Buyer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BuyerHomePage()),
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
    }
  } on FirebaseAuthException catch (e) {
    final message = e.message ?? 'Signup failed. Please try again.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
