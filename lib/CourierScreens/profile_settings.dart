import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CourierProfileSettings extends StatefulWidget {
  const CourierProfileSettings({super.key});

  @override
  State<CourierProfileSettings> createState() => _CourierProfileSettingsState();
}

class _CourierProfileSettingsState extends State<CourierProfileSettings> {
  static const Color backgroundColor = Color(0xFFEFE9DC);
  static const Color primaryColor = Color(0xFF7BA05B);
  static const Color textColor = Color(0xFF2E3C48);

  File? profileImage;
  final picker = ImagePicker();

  final nameController = TextEditingController(text: "Courier Basem");
  final emailController = TextEditingController(text: "courier@example.com");
  final passwordController = TextEditingController(text: "password123");

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  void saveProfile() {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // For now just print (or simulate save to Firebase/local storage)
    print("Saved: $name, $email, $password");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Manage Account"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: pickImage,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: profileImage != null
                          ? FileImage(profileImage!)
                          : const AssetImage('lib/Images/ThriftNest_Logo.png')
                              as ImageProvider,
                    ),
                    const SizedBox(height: 10),
                    const Text("Picture", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Text("Change", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: saveProfile,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
