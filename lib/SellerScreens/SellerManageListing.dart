// lib/SellerScreens/SellerManageListing.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import 'ItemPostingOverlay.dart';
import 'ItemEditOverlay.dart';
import '../SellerScreens/ListingTile.dart';
import '../SellerLogic/item_crud.dart';
import '../SellerLogic/seller_listings_service.dart';
import '../SellerLogic/Item_model.dart';
import '../SellerScreens/ItemDetailOverlay.dart';

class SellerManageListing extends StatefulWidget {
  const SellerManageListing({super.key});

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
        child: ItemPostingOverlay(onClose: () => Navigator.of(context).pop()),
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
        child: ItemEditOverlay(item: item, onClose: () => Navigator.of(context).pop()),
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

    // Tab 0: Manage Listings (On Sale + On Delivery)
    final manageTab = StreamBuilder<List<ItemModel>>(
      stream: SellerListingsService.instance.listings$,
      builder: (ctx, snap) {
        if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final items      = snap.data!;
        final onSale     = items.where((it) => it.sellingStage == 'On Sale').toList();
        final onDelivery = items.where((it) => it.sellingStage == 'On Delivery').toList();

        if (onSale.isEmpty && onDelivery.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('lib/images/NoUploadedItems_image.png', height: 200),
                const SizedBox(height: 16),
                const Text(
                  'You haven’t added any items yet.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 80, top: 16),
          children: [
            // ─── On Sale ───────────────────────────────────────
            Row(children: [
              const Expanded(child: Divider(thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('On Sale',
                    style: TextStyle(
                        color: ThriftNestApp.textColor, fontWeight: FontWeight.bold)),
              ),
              const Expanded(child: Divider(thickness: 1)),
            ]),
            const SizedBox(height: 8),

            if (onSale.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Text('No items on sale.')),
              )
            else
              ...onSale.map((item) => ListingTile(
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
                            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(c, true),  child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await deleteItem(item.id);
                        SellerListingsService.instance.initForOwner(_uid!);
                      }
                    },
                  )),

            const SizedBox(height: 24),

            // ─── On Delivery ────────────────────────────────────
            Row(children: [
              const Expanded(child: Divider(thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('On Delivery',
                    style: TextStyle(
                        color: ThriftNestApp.textColor, fontWeight: FontWeight.bold)),
              ),
              const Expanded(child: Divider(thickness: 1)),
            ]),
            const SizedBox(height: 8),

            if (onDelivery.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Text('No items on delivery.')),
              )
            else
              ...onDelivery.map((item) => ListingTile(
                    id: item.id,
                    title: item.title,
                    price: item.price,
                    imageBytes: item.imageBytes,
                    onEdit: null,
                    onDelete: null,
                  )),
          ],
        );
      },
    );

    // Tab 1: Sales History (Sold items)
    final historyTab = StreamBuilder<List<ItemModel>>(
      stream: SellerListingsService.instance.listings$,
      builder: (ctx, snap) {
        if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final sold = snap.data!.where((it) => it.sellingStage == 'Sold').toList();

        if (sold.isEmpty) {
          return const Center(child: Text('No sold items yet.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80, top: 16),
          itemCount: sold.length,
          itemBuilder: (ctx, i) {
            final item = sold[i];
            return GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => FractionallySizedBox(
                    heightFactor: 0.85,
                    child: ItemDetailOverlay(item: item),
                  ),
                );
              },
              child: ListingTile(
                id: item.id,
                title: item.title,
                price: item.price,
                imageBytes: item.imageBytes,
                onEdit: null,
                onDelete: null,
              ),
            );
          },
        );
      },
    );

    // Tab 2: Settings placeholder
    Widget placeholder(String t) =>
        Center(child: Text(t, style: const TextStyle(color: Colors.grey)));
    final tabs = [
      manageTab,
      historyTab,
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
      body: IndexedStack(index: _currentIndex, children: tabs),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ThriftNestApp.primaryColor,
        shape: const CircleBorder(),
        onPressed: _openAddSheet,
        child: const Icon(Icons.add, size: 32),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: ThriftNestApp.primaryColor,
        unselectedItemColor: ThriftNestApp.textColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
