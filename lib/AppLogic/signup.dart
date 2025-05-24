// lib/AppLogic/signup.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../SellerScreens/SellerManageListing.dart';
// import '../BuyerScreens/buyer_home.dart';
// import '../CourierScreens/courier_home.dart';

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
        duration: Duration(seconds: 2),
      ),
    );

    // 4) Redirect based on role
    Widget nextScreen;
    switch (role) {
      case 'Seller':
        nextScreen = const SellerManageListing();
        break;
      // case 'Buyer':
      //   nextScreen = const BuyerHomePlaceholder();
      //   break;
      // case 'Courier':
      //   nextScreen = const CourierHomePlaceholder();
      //   break;
      default:
        nextScreen = const SellerManageListing();
    }

    // give the user a moment to see the SnackBar
    await Future.delayed(const Duration(milliseconds: 800));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );

  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? 'Signup failed.'))
    );
  }
}
