import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'items_tab.dart';
import 'placeholder.dart'; // Assuming this is still used for Favorites
import '../CommonScreens/ProfileManagementScreen.dart';
import 'package:greentrack/BuyerScreens/cart_screen.dart'; // Import CartScreen
import 'package:greentrack/BuyerScreens/buyer_logic.dart'; // Import BuyerLogic

class BuyerHomePage extends StatefulWidget {
  const BuyerHomePage({super.key});

  @override
  State<BuyerHomePage> createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> {
  int _currentIndex = 0;
  late Future<String> _nameFuture;
  final BuyerLogic _buyerLogic = BuyerLogic(); // Instantiate BuyerLogic

  @override
  void initState() {
    super.initState();
    // Initialize BuyerLogic (loads products, profile, etc.)
    _buyerLogic.init(() {
      if (mounted) {
        setState(() {});
      }
    });

    // fetch current user's name for AppBar
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _nameFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((doc) {
      final data = doc.data() ?? {};
      // Use name from BuyerLogic's controllers if available and populated by init,
      // otherwise fallback to direct fetch or default.
      // This assumes _buyerLogic.nameController might be populated by _buyerLogic.init()
      if (_buyerLogic.nameController.text.isNotEmpty) {
        return _buyerLogic.nameController.text;
      }
      return (data['name'] as String?) ?? (data['fullName'] as String?) ?? 'User';
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      ItemsTab(buyerLogic: _buyerLogic), // Pass BuyerLogic to ItemsTab
      CartScreen(buyerLogic: _buyerLogic), // Replace Placeholder with CartScreen
      const PlaceholderTab(icon: Icons.favorite_border, label: 'Favorites coming soon'), // Keep placeholder for now
      ProfileManagementScreen(), // Assuming ProfileManagementScreen doesn't need BuyerLogic directly or gets it differently
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: FutureBuilder<String>(
          future: _nameFuture,
          builder: (context, snapshot) {
            final name = snapshot.data ?? 'User';
            return Text('Hi, $name!');
          },
        ),
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'), // Updated icon and label
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Profile'),
        ],
      ),
    );
  }
}