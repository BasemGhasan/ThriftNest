import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../AppLogic/profile-service.dart';
import '../CommonScreens/onboarding.dart';

class ProfileManagementScreen extends StatefulWidget {
  @override
  _ProfileManagementScreenState createState() => _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  late final TextEditingController _deleteConfirmPasswordController;

  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _deleteConfirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    _deleteConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        Map<String, dynamic> data = await _profileService.loadUserData(user.uid);
        if (data.isNotEmpty) {
          _fullNameController.text = data['fullName'] ?? '';
          _emailController.text = data['email'] ?? user.email ?? '';
          _phoneNumberController.text = data['phone'] ?? '';
        } else {
          _emailController.text = user.email ?? '';
        }
      } catch (e) {
        print("Error loading user data: $e");
        _emailController.text = user.email ?? '';
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_profileFormKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await _profileService.updateProfile(
            uid: user.uid,
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneNumberController.text.trim(),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully!')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: $e')),
          );
          print("Error updating profile: $e");
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user logged in. Please log in again.')),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    if (_passwordFormKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await _profileService.changePassword(
            user: user,
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password updated successfully!')),
          );
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmNewPasswordController.clear();
          _passwordFormKey.currentState?.reset();
        } on FirebaseAuthException catch (e) {
          String errorMessage = 'Failed to change password.';
          if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
            errorMessage = 'Incorrect current password. Please try again.';
          } else if (e.code == 'weak-password') {
            errorMessage = 'The new password is too weak.';
          } else if (e.code == 'requires-recent-login') {
            errorMessage = 'This operation requires recent authentication. Please log out and log in again.';
          }
          print('Error changing password: ${e.toString()} (Code: ${e.code})');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    }
  }

  Future<void> _logoutUser() async {
    try {
      await _profileService.logoutUser();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged out successfully.')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => OnboardingScreen()),
        (route) => false,
      );
    } catch (e) {
      print('Error logging out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed. Please try again.')),
      );
    }
  }
  
  void _promptUserForDeleteConfirmation() {
    _deleteConfirmPasswordController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final GlobalKey<FormState> dialogFormKey = GlobalKey<FormState>();
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Delete Account?'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('This action is permanent and cannot be undone.'),
                    Text('Please enter your password to confirm deletion.'),
                    SizedBox(height: 15),
                    Form(
                      key: dialogFormKey,
                      child: TextFormField(
                        controller: _deleteConfirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: isLoading ? null : () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    child: isLoading 
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Confirm Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: isLoading ? null : () async {
                      if (dialogFormKey.currentState!.validate()) {
                        setStateDialog(() {
                          isLoading = true;
                        });
                        User? user = FirebaseAuth.instance.currentUser;
                        if (user == null || user.email == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('User session error. Please log in again.')),
                          );
                          setStateDialog(() { isLoading = false; });
                          Navigator.of(dialogContext).pop();
                          return;
                        }
                        try {
                          await _profileService.deleteAccount(
                            user: user,
                            password: _deleteConfirmPasswordController.text,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Account deleted successfully.')),
                          );
                          Navigator.of(dialogContext).pop();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => OnboardingScreen()),
                            (route) => false,
                          );
                        } on FirebaseAuthException catch (e) {
                          String errorMessage = 'Failed to delete account.';
                          if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
                            errorMessage = 'Incorrect password. Please try again.';
                          } else if (e.code == 'requires-recent-login') {
                            errorMessage = 'This operation requires recent authentication. Please log out and log in again.';
                          }
                          print('Delete Account Error: ${e.toString()} (Code: ${e.code})');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(errorMessage)),
                          );
                        } catch (e) {
                          print('Generic Delete Account Error: ${e.toString()}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('An unexpected error occurred.')),
                          );
                        } finally {
                          setStateDialog(() {
                            isLoading = false;
                          });
                        }
                      }
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            // Add 'Manage Profile' as a section title
            Text(
              'Manage Profile',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 20),
            Form(
              key: _profileFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(labelText: 'Full Name'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter your full name'
                        : null,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Please enter your email';
                      final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                      if (!emailPattern.hasMatch(v.trim()))
                        return 'Enter a valid email address';
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Please enter your phone number';
                      if (!RegExp(r'^\+?[0-9\s\-()]{7,}$').hasMatch(v))
                        return 'Enter a valid phone number';
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 180,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      child: Text('Update Profile'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Text('Change Password', style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 10),
            Form(
              key: _passwordFormKey,
              child: Column(
                children: [
                  TextFormField(
                  controller: _currentPasswordController,
                  decoration: InputDecoration(labelText: 'Current Password'),
                  obscureText: true,
                  validator: (v) => (v == null || v.isEmpty)
                    ? 'Please enter your current password'
                    : null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty)
                    return 'Please enter a new password';
                    if (v.length < 8)
                    return 'Password must be at least 8 characters long';
                    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(v))
                    return 'Password must include at least one letter and one number';
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                  controller: _confirmNewPasswordController,
                  decoration: InputDecoration(labelText: 'Confirm New Password'),
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty)
                    return 'Please confirm your new password';
                    if (v != _newPasswordController.text)
                    return 'Passwords do not match';
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    onPressed: _changePassword,
                    child: Text('Change Password'),
                    style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    ),
                  ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _logoutUser,
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: _promptUserForDeleteConfirmation,
              child: Text('Delete Account', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
