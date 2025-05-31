import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'onboarding.dart'; // For OnboardingScreen

import '../../SellerScreens/SellerManageListing.dart';
import '../../BuyerScreens/BuyerHomePage.dart';
import '../../CourierScreens/courier_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in
          User firebaseUser = snapshot.data!;
          // Directly proceed to RoleBasedRedirect, ignoring emailVerified status for already logged-in users
          return RoleBasedRedirect(userId: firebaseUser.uid);
        } else {
          // User is not logged in
          return const OnboardingScreen();
        }
      },
    );
  }
}

// Helper widget to fetch role and redirect
class RoleBasedRedirect extends StatelessWidget {
  final String userId;
  const RoleBasedRedirect({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          debugPrint("Error fetching user role in RoleBasedRedirect: ${snapshot.error}");
          return const OnboardingScreen(); // Fallback
        }
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final role = data['role'] as String?;
          switch (role) {
            case 'Seller':
              return const SellerManageListing();
            case 'Buyer':
              return const BuyerHomePage();
            case 'Courier':
              return const CourierDashboard();
            default:
              // Unknown role
              debugPrint("Unknown role in RoleBasedRedirect: $role for userId: $userId");
              return const OnboardingScreen(); // Fallback
          }
        } else {
          // User document not found in Firestore
          debugPrint("User document not found in RoleBasedRedirect for userId: $userId");
          return const OnboardingScreen(); // Fallback
        }
      },
    );
  }
}