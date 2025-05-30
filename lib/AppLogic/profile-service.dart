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
  Future<void> updateProfile({
    required String uid,
    required String fullName,
    required String email,
    required String phone,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'fullName': fullName,
      'email': email,
      'phone': phone,
    });
  }
  
  /// Changes the user's password.
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
  
  /// Deletes the user's account.
  Future<void> deleteAccount({
    required User user,
    required String password,
  }) async {
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
    // Delete the Firestore document.
    await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
    // Delete the Auth user.
    await user.delete();
  }
  
  /// Logs out the user.
  Future<void> logoutUser() async {
    await FirebaseAuth.instance.signOut();
  }
}