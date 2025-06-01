import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  /// Loads user data from Firestore.
  Future<Map<String, dynamic>> loadUserData(String uid) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>? ?? {};
    } else {
      return {};
    }
  }
  
  /// Updates the user's profile in Firestore.
  Future<bool> updateProfile({
    required String uid,
    required String fullName,
    required String email, // New email from the form
    required String phone,
  }) async {
    User? user = FirebaseAuth.instance.currentUser;
    bool emailVerificationSent = false;

    if (user == null) {
      throw Exception("User not logged in.");
    }

    // Prepare data for Firestore update (non-email fields first)
    Map<String, dynamic> firestoreUpdateData = {
      'fullName': fullName,
      'phone': phone,
    };

    try {
      // Check if the email is being changed
      if (email.trim().toLowerCase() != user.email?.toLowerCase()) {
        await user.verifyBeforeUpdateEmail(email.trim());
        emailVerificationSent = true;
      }

      if (!emailVerificationSent) {
        firestoreUpdateData['email'] = email.trim();
      } else {
      }


      if (firestoreUpdateData.keys.any((key) => 
            key == 'fullName' || 
            key == 'phone' || 
            (key == 'email' && !emailVerificationSent))) {
          await FirebaseFirestore.instance.collection('users').doc(uid).update(firestoreUpdateData);
      }


      return emailVerificationSent;

    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      print('FirebaseAuthException in updateProfile: ${e.code} - ${e.message}');
      if (e.code == 'email-already-in-use') {
        throw Exception('The new email address is already in use by another account.');
      } else if (e.code == 'requires-recent-login') {
        throw Exception('This operation is sensitive and requires recent authentication. Please log out and log back in before trying again.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The new email address is not valid.');
      }
      throw Exception('An error occurred while updating your email: ${e.message}');
    } catch (e) {
      print('Generic error in updateProfile: ${e.toString()}');
      throw Exception('An unexpected error occurred while updating your profile.');
    }
  }

  Future<void> changePassword({
    required User user,
    required String currentPassword,
    required String newPassword,
  }) async {
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> deleteAccount({
    required User user,
    required String password,
  }) async {
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
    await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
    await user.delete();
  }

  Future<void> logoutUser() async {
    await FirebaseAuth.instance.signOut();
  }
}