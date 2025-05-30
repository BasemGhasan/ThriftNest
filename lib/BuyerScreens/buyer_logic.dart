import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;
import 'package:firebase_auth/firebase_auth.dart';

class BuyerLogic {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? imageUrl;
  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> filteredProducts = [];
  final List<String> categories = ['All', 'Clothes', 'Electronics', 'Books', 'Home'];
  String selectedCategory = 'All';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize products and profile, then rebuild UI.
  Future<void> init(VoidCallback refresh) async {
    await loadProducts();
    await loadProfile();
    refresh();
  }

  /// Fetch all products from Firestore.
  Future<void> loadProducts() async {
    final snapshot = await _firestore.collection('products').get();
    allProducts = snapshot.docs
        .map((doc) => doc.data())
        .toList();
    filteredProducts = List.from(allProducts);
  }

  /// Apply text + category filters.
  void filterProducts(String search, VoidCallback refresh) {
    final query = search.toLowerCase();
    filteredProducts = allProducts.where((p) {
      final name = (p['name'] as String? ?? '').toLowerCase();
      final matchesName = name.contains(query);
      final cat = p['category'] as String? ?? '';
      final matchesCat = selectedCategory == 'All' || cat == selectedCategory;
      return matchesName && matchesCat;
    }).toList();
    refresh();
  }

  /// Change current category and refilter.
  void selectCategory(String category, VoidCallback refresh) {
    selectedCategory = category;
    filterProducts(searchController.text, refresh);
  }

  /// Show product detail in a scrollable dialog.
  void openProduct(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item['name'] as String? ?? 'Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if ((item['image'] as String?)?.isNotEmpty == true)
                Image.network(item['image'] as String, fit: BoxFit.cover),
              const SizedBox(height: 12),
              Text("Price: \$${item['price'] ?? '0.00'}"),
              const SizedBox(height: 10),
              Text(item['description'] as String? ?? "No description"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  /// Load current user's profile into controllers.
  Future<void> loadProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      nameController.text = data['name'] as String? ?? '';
      phoneController.text = data['phone'] as String? ?? '';
      imageUrl = data['photo'] as String?;
    }
  }

  /// Save edited profile back to Firestore.
  Future<void> saveProfile(VoidCallback refresh, BuildContext context) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).set({
      'name': nameController.text,
      'phone': phoneController.text,
      'photo': imageUrl ?? '',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated")),
    );
    refresh();
  }

  /// Pick an image and upload to Firebase Storage.
  Future<void> pickAndUploadPhoto(VoidCallback refresh) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final ref = _storage.ref().child("users/$uid/profile.jpg");
    await ref.putFile(File(picked.path));
    imageUrl = await ref.getDownloadURL();
    refresh();
  }

  /// Build the profile editor widget.
  Widget buildProfileEditor(BuildContext context, VoidCallback refresh) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => pickAndUploadPhoto(refresh),
              child: CircleAvatar(
                radius: 40,
                backgroundImage:
                    imageUrl != null ? NetworkImage(imageUrl!) : null,
                child: imageUrl == null
                    ? const Icon(Icons.add_a_photo)
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => saveProfile(refresh, context),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
