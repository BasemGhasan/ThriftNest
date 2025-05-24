import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../CommonScreens/onboarding.dart';

class SellerManageListing extends StatefulWidget {
  const SellerManageListing({Key? key}) : super(key: key);

  @override
  State<SellerManageListing> createState() => _SellerManageListingState();
}

class _SellerManageListingState extends State<SellerManageListing> {
  int _currentIndex = 0;
  late final Future<String> _userNameFuture;

  @override
  void initState() {
    super.initState();
    _userNameFuture = _fetchUserName();
  }

  Future<String> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'User';
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return doc.data()?['fullName'] as String? ?? 'User';
  }

  Widget _buildPlaceholder(double logoH, [String message = '']) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'lib/images/NoUploadedItems_image.png',
            height: logoH * 3,
            fit: BoxFit.contain,
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: ThriftNestApp.textColor,
                fontSize: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    final logoH = sh * 0.12;
    final tabs = [
      _buildPlaceholder(logoH),
      _buildPlaceholder(logoH, 'Sales Analytics coming soon'),
      _buildPlaceholder(logoH, 'Chats coming soon'),
      _buildPlaceholder(logoH, 'Settings coming soon'),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,  // removes back arrow
        centerTitle: false,
        title: FutureBuilder<String>(
          future: _userNameFuture,
          builder: (context, snapshot) {
            final name = snapshot.data ?? 'User';
            return Text(
              'Hi, $name !',
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
              size: 28,  // larger icon
              color: ThriftNestApp.primaryColor,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: tabs[_currentIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: ThriftNestApp.primaryColor,
        child: const Icon(Icons.add),
        onPressed: () {
          // TODO: navigate to add item screen
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: ThriftNestApp.primaryColor,
        unselectedItemColor: ThriftNestApp.textColor,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '',
          ),
        ],
      ),
    );
  }
}
