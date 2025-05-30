import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'items_tab.dart';
import 'placeholder.dart';
import '../CommonScreens/ProfileManagementScreen.dart';

class BuyerHomePage extends StatefulWidget {
  const BuyerHomePage({super.key});

  @override
  State<BuyerHomePage> createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> {
  int _currentIndex = 0;
  late Future<String> _nameFuture;

  @override
  void initState() {
    super.initState();
    // fetch current user's name from Firestore
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _nameFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((doc) {
      final data = doc.data() ?? {};
      return (data['name'] as String?)
          ?? (data['fullName'] as String?)
          ?? 'User';
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      const ItemsTab(),
      const PlaceholderTab(icon: Icons.list_alt, label: 'Orders coming soon'),
      const PlaceholderTab(icon: Icons.favorite_border, label: 'Favorites coming soon'),
      ProfileManagementScreen(), 
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
    );
  }
}