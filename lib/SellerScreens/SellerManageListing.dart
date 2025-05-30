import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import 'ItemPostingOverlay.dart';
import 'ItemEditOverlay.dart';
import '../SellerScreens/ListingTile.dart';
import '../SellerLogic/item_crud.dart';
import '../SellerLogic/seller_listings_service.dart';
import '../SellerLogic/item_model.dart';

class SellerManageListing extends StatefulWidget {
  const SellerManageListing({Key? key}) : super(key: key);

  @override
  State<SellerManageListing> createState() => _SellerManageListingState();
}

class _SellerManageListingState extends State<SellerManageListing> {
  String? _uid;
  late final Future<String> _userNameFuture;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _uid = user.uid;
      // start the live stream
      SellerListingsService.instance.initForOwner(_uid!);
      _userNameFuture = FirebaseFirestore.instance
          .collection('users')
          .doc(_uid!)
          .get()
          .then((snap) => snap.data()?['fullName'] as String? ?? 'User');
    } else {
      _userNameFuture = Future.value('User');
    }
  }

  Future<void> _openAddSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.85,
        child: ItemPostingOverlay(
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
    if (_uid != null) {
      SellerListingsService.instance.initForOwner(_uid!);
    }
  }

  Future<void> _openEditSheet(ItemModel item) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.85,
        child: ItemEditOverlay(
          item: item,
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
    if (_uid != null) {
      SellerListingsService.instance.initForOwner(_uid!);
    }
  }

  void _onTabTapped(int idx) => setState(() => _currentIndex = idx);

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final listingsTab = StreamBuilder<List<ItemModel>>(
      stream: SellerListingsService.instance.listings$,
      builder: (ctx, snap) {
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data!;
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/images/NoUploadedItems_image.png',
                  height: 200,
                ),
                const SizedBox(height: 16),
                const Text(
                  'You haven’t added any items yet.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final item = items[i];
            return ListingTile(
              id: item.id,
              title: item.title,
              price: item.price,
              imageBytes: item.imageBytes,
              onEdit: () => _openEditSheet(item),
              onDelete: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Delete Item?'),
                    content: const Text("This can't be undone."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(c, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await deleteItem(item.id);
                  if (_uid != null) {
                    SellerListingsService.instance.initForOwner(_uid!);
                  }
                }
              },
            );
          },
        );
      },
    );

    Widget placeholder(String t) =>
        Center(child: Text(t, style: const TextStyle(color: Colors.grey)));

    final tabs = [
      listingsTab,
      placeholder('Sales Analytics coming soon'),
      placeholder('Settings coming soon'),
    ];

    return Scaffold(
      backgroundColor: ThriftNestApp.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: FutureBuilder<String>(
          future: _userNameFuture,
          builder: (ctx, snap) {
            final name = snap.data ?? 'User';
            return Text('Hi, $name!',
                style: const TextStyle(
                    color: ThriftNestApp.textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold));
          },
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ThriftNestApp.primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32),
        onPressed: _openAddSheet,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: ThriftNestApp.primaryColor,
        unselectedItemColor: ThriftNestApp.textColor,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
    );
  }
}