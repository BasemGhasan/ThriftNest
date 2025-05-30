// lib/courierScreens/courier_dashboard.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'available_deliveries.dart';
import 'my_deliveries.dart';

class CourierDashboard extends StatefulWidget {
  const CourierDashboard({Key? key}) : super(key: key);

  @override
  State<CourierDashboard> createState() => _CourierDashboardState();
}

class _CourierDashboardState extends State<CourierDashboard> {
  int _currentIndex = 0;
  late final Future<String> _userNameFuture;
  
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userNameFuture = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((snap) => snap.data()?['fullName'] as String? ?? 'Courier');
    } else {
      _userNameFuture = Future.value('Courier');
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final tabs = [
      const AvailableDeliveries(),
      const MyDeliveries(),
      _buildStatsTab(),
      _buildSettingsTab(),
    ];

    return Scaffold(
      backgroundColor: ThriftNestApp.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: FutureBuilder<String>(
          future: _userNameFuture,
          builder: (context, snapshot) {
            final name = snapshot.data ?? 'Courier';
            return Text(
              'Hi, $name!',
              style: const TextStyle(
                color: ThriftNestApp.textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: ThriftNestApp.primaryColor,
              size: 28,
            ),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),// Add this as a floating action button in courier_dashboard.dart
floatingActionButton: FloatingActionButton(
  onPressed: () async {
    try {
      // Create a test delivery request
      await FirebaseFirestore.instance.collection('deliveryRequests').add({
        'itemId': 'test_item_${DateTime.now().millisecondsSinceEpoch}',
        'itemTitle': 'Test iPhone 12 Pro',
        'sellerId': 'test_seller_123',
        'sellerName': 'Ahmad Rahman',
        'sellerPhone': '+60123456789',
        'buyerId': 'test_buyer_456', 
        'buyerName': 'Sarah Lee',
        'buyerPhone': '+60198765432',
        'pickupAddress': 'APU University, Technology Park Malaysia',
        'deliveryAddress': 'Sunway University, Bandar Sunway',
        'courierId': null,
        'courierName': null,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'acceptedAt': null,
        'deliveredAt': null,
        'specialInstructions': 'Handle with care - electronic item',
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Test delivery created!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  backgroundColor: Colors.orange,
  child: const Icon(Icons.add_box),
),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: ThriftNestApp.primaryColor,
        unselectedItemColor: ThriftNestApp.textColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Available',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'My Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Delivery Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}