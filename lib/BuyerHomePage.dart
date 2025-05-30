import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thirft_nest/buyer_logic.dart';


class BuyerHomePage extends StatefulWidget {
  const BuyerHomePage({super.key});

  @override
  State<BuyerHomePage> createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> {
  final BuyerLogic logic = BuyerLogic();
  int _currentIndex = 0;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logic.init(() {
        if (!mounted) return;
        setState(() {});
      });
    });
  }

  void _showCategoryModal() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          children: logic.categories.map((cat) {
            return ChoiceChip(
              label: Text(cat),
              selected: logic.selectedCategory == cat,
              onSelected: (_) {
                logic.selectCategory(cat, () {
                  if (mounted) setState(() {});
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Stream of this buyer's orders from Firestore. You can adapt the field names
  /// to whatever your seller pushes under `orders` collection.
  Stream<QuerySnapshot> get _ordersStream {
    final uid = _auth.currentUser?.uid;
    return _firestore
        .collection('orders')
        .where('buyerId', isEqualTo: uid)
        .snapshots();
  }

  Widget _buildOrdersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _ordersStream,
      builder: (context, snap) {
        if (snap.hasError) return const Center(child: Text('Error loading orders'));
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('No orders yet.'));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (ctx, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(data['itemName'] ?? 'Unnamed item'),
                subtitle: Text('Seller: ${data['sellerName'] ?? 'Unknown'}\n'
                    'Contact: ${data['sellerPhone'] ?? 'N/A'}'),
                trailing: Text('\$${data['price'] ?? '—'}'),
                onTap: () {
                  // TODO: open order details
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHomeTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // Search bar
          TextField(
            controller: logic.searchController,
            onChanged: (v) => logic.filterProducts(v, () {
              if (mounted) setState(() {});
            }),
            decoration: InputDecoration(
              hintText: 'Search items',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Browse by Category
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.grid_view),
              label: const Text('Browse by Category'),
              style: OutlinedButton.styleFrom(
                shape: const StadiumBorder(),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
              onPressed: _showCategoryModal,
            ),
          ),
          const SizedBox(height: 20),
          // Promotion banner
          Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight,
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: AssetImage('lib/images/promotion_banner.png'),
                fit: BoxFit.cover,
              ),
            ),
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Secondhand Deals',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Grid of items
          Expanded(
            child: logic.filteredProducts.isEmpty
                ? const Center(child: Text('No products available.'))
                : GridView.builder(
                    itemCount: logic.filteredProducts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 3 / 4,
                    ),
                    itemBuilder: (context, i) {
                      final item = logic.filteredProducts[i];
                      return GestureDetector(
                        onTap: () => logic.openProduct(context, item),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Image
                              Expanded(
                                child: item['image'] != null
                                    ? Image.network(item['image'],
                                        fit: BoxFit.cover)
                                    : Container(
                                        color: Colors.grey.shade200),
                              ),
                              // Name & price
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${item['price'] ?? ''}',
                                      style: const TextStyle(
                                          color: Colors.green),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _buildHomeTab(),
      _buildOrdersTab(),   // replaced chat with orders
      const Center(child: Icon(Icons.favorite_border)),  // favorites placeholder
      const Center(child: Text('Settings')),             // settings placeholder
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Hi! Alhussain'),
        // removed notification icon
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) {
          if (!mounted) return;
          setState(() => _currentIndex = idx);
        },
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
