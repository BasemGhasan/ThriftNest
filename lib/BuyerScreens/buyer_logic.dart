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
  final List<String> categories = ['All', 'Vehicles', 'Furniture', 'Clothes', 'Accessories', 'Electronics', 'Services', 'Others'];
  String selectedCategory = 'All';

  List<Map<String, dynamic>> cart = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize products and profile, then rebuild UI.
  Future<void> init(VoidCallback refresh) async {
    await loadProducts();
    await loadProfile();
    // cart should be loaded from persistence if needed, for now it's in-memory
    refresh();
  }

  /// Fetch all products from Firestore.
  Future<void> loadProducts() async {
    final snapshot = await _firestore.collection('items').get(); // Changed to 'items'
    allProducts = snapshot.docs.map((doc) {
      // Create a mutable copy of doc.data() to avoid modifying the original snapshot data
      Map<String, dynamic> data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id; // Ensure item ID is included
      
      // Ensure ownerId is correctly assigned and is a string
      data['ownerId'] = (data['ownerId'] is String ? data['ownerId'] : '') as String;
      
      // Remove the old 'image' key if it was for URLs and no longer the primary source
      data.remove('image'); 
      // Fetch and store the base64 string from Firestore field 'imageBase64'
      data['imageBase64'] = (doc.data()['imageBase64'] is String ? doc.data()['imageBase64'] : '') as String;
      
      return data;
    }).toList();
    filteredProducts = List.from(allProducts);
  }

  /// Add item to cart.
  void addToCart(Map<String, dynamic> item, BuildContext context, VoidCallback refresh) {
    if (item['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item has no ID, cannot add to cart.")),
      );
      return;
    }
    bool itemExists = cart.any((cartItem) => cartItem['id'] == item['id']);
    if (itemExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item already in cart")),
      );
    } else {
      cart.add(item);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item added to cart")),
      );
    }
    refresh();
  }

  /// Remove item from cart.
  void removeFromCart(Map<String, dynamic> item, BuildContext context, VoidCallback refresh) {
    if (item['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item has no ID, cannot remove from cart.")),
      );
      return;
    }
    cart.removeWhere((cartItem) => cartItem['id'] == item['id']);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Item removed from cart")),
    );
    refresh();
  }

  double getCartTotalPrice() {
    double total = 0.0;
    for (var item in cart) {
      if (item['price'] is num) {
        total += (item['price'] as num).toDouble();
      }
    }
    return total;
  }

  /// Apply text + category filters.
  void filterProducts(String search, VoidCallback refresh) {
    final query = search.toLowerCase();
    filteredProducts = allProducts.where((p) {
      // Use 'title' for searching, as per typical item structure
      final title = (p['title'] as String? ?? '').toLowerCase();
      final matchesTitle = title.contains(query);
      final category = p['category'] as String? ?? '';
      final matchesCategory = selectedCategory == 'All' || category == selectedCategory;
      return matchesTitle && matchesCategory;
    }).toList();
    refresh();
  }

  /// Change current category and refilter.
  void selectCategory(String category, VoidCallback refresh) {
    selectedCategory = category;
    filterProducts(searchController.text, refresh);
  }

  /// Show product detail in a scrollable dialog.
  // Note: The original openProduct is replaced by showItemDetailDialog from item_detail_dialog.dart
  // If openProduct is still used elsewhere, it might need adjustment or removal.
  // For now, I'm assuming showItemDetailDialog is the primary way to show details.

  Future<void> placeOrder(BuildContext context, VoidCallback refreshCart) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in. Cannot place order.")),
      );
      return;
    }

    try {
      // Fetch current buyer's details
      String finalBuyerName;
      String finalBuyerPhone;

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();

      String fetchedName = 'Unknown Buyer';
      String fetchedPhone = 'No Phone';

      if (userData != null) {
        // Try fullName first, then name
        if (userData['fullName'] is String && (userData['fullName'] as String).isNotEmpty) {
          fetchedName = userData['fullName'] as String;
        } else if (userData['name'] is String && (userData['name'] as String).isNotEmpty) {
          fetchedName = userData['name'] as String;
        }

        // Fetch phone
        if (userData['phone'] is String && (userData['phone'] as String).isNotEmpty) {
          fetchedPhone = userData['phone'] as String;
        }
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Buyer profile details not found in Firestore.")),
        );
        // Keep default 'Unknown Buyer' and 'No Phone' if no userData
      }

      // Use controller values as a fallback if fetched values are still default AND controller values are not empty
      finalBuyerName = (nameController.text.isNotEmpty && fetchedName == 'Unknown Buyer')
                               ? nameController.text
                               : fetchedName;
      finalBuyerPhone = (phoneController.text.isNotEmpty && fetchedPhone == 'No Phone')
                                ? phoneController.text
                                : fetchedPhone;
      
      final List<Map<String, dynamic>> cartCopy = List.from(cart);

      for (final item in cartCopy) {
        final orderData = {
          'buyerId': userId,
          'buyerName': finalBuyerName, // Use resolved name
          'buyerPhone': finalBuyerPhone, // Use resolved phone
          'createdAt': Timestamp.now(),
          'itemTitle': item['title'] ?? item['name'] ?? 'N/A', // Ensure title/name field
          'itemId': item['id'],
          'sellerName': item['sellerName'] ?? 'N/A', // Assuming these fields exist
          'sellerPhoneNumber': item['sellerPhoneNumber'] ?? 'N/A',
          'sellerId': item['ownerId'] ?? 'N/A', // Assuming ownerId is seller's user ID
          'totalPrice': item['price'], 
          // Include delivery details if they were added to the item in cart
          'assignCourier': item['assignCourier'] ?? false,
          'deliveryLocation': item['deliveryLocation'],
          'specialInstructions': item['specialInstructions'],
        };

        await _firestore.collection('orders').add(orderData);

        if (item['assignCourier'] == true && 
            item['deliveryLocation'] != null && 
            (item['deliveryLocation'] as String).isNotEmpty) {
          
          final deliveryRequestData = {
            'acceptedAt': null,
            'buyerId': userId,
            'buyerName': finalBuyerName, // Corrected to use finalBuyerName
            'buyerPhone': finalBuyerPhone, // Corrected to use finalBuyerPhone
            'courierId': null,
            'courierName': null,
            'createdAt': Timestamp.now(),
            'deliveredAt': null,
            'deliveryAddress': item['deliveryLocation'],
            'itemTitle': item['title'] ?? item['name'] ?? 'N/A',
            'itemId': item['id'],
            'pickupAddress': item['location'] ?? 'N/A', // Original item location
            'sellerName': item['sellerName'] ?? 'N/A',
            'sellerPhone': item['sellerPhoneNumber'] ?? 'N/A',
            'sellerId': item['ownerId'] ?? 'N/A',
            'specialInstructions': item['specialInstructions'] ?? '',
            'status': "pending",
          };
          await _firestore.collection('deliveryRequests').add(deliveryRequestData);
        }
      }

      cart.clear();
      refreshCart();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully!")),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to place order: ${e.toString()}")),
      );
    }
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