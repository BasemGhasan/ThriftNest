import 'package:flutter/material.dart';
import 'package:greentrack/BuyerScreens/buyer_logic.dart'; // Assuming project structure

class CartScreen extends StatefulWidget {
  final BuyerLogic buyerLogic;

  const CartScreen({Key? key, required this.buyerLogic}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void _removeItem(Map<String, dynamic> item) {
    // The refresh callback for buyer_logic.removeFromCart will be handled by
    // the main screen that holds buyer_logic, or buyer_logic itself if it uses a state notifier.
    // For CartScreen, we call setState to ensure this screen rebuilds immediately
    // after an item is removed, reflecting the change in widget.buyerLogic.cart.
    widget.buyerLogic.removeFromCart(item, context, () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = widget.buyerLogic.cart;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
        backgroundColor: Colors.green, // Consistent AppBar color
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.isEmpty
                ? const Center(child: Text("Your cart is empty"))
                : ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      // Assuming item data structure based on previous context
                      final String title = item['name'] ?? item['title'] ?? 'Unnamed Item';
                      final dynamic price = item['price'] ?? 'N/A';

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: ListTile(
                          // You might want to add an image if available:
                          // leading: item['image'] != null ? Image.network(item['image'], width: 50, height: 50, fit: BoxFit.cover) : null,
                          title: Text(title),
                          subtitle: Text('Price: \$${price.toString()}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_shopping_cart, color: Colors.red),
                            onPressed: () {
                              _removeItem(item);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (cart.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  widget.buyerLogic.placeOrder(context, () {
                    if (mounted) {
                      setState(() {}); // Refresh CartScreen UI
                    }
                  });
                },
                child: const Text("Place Order"),
              ),
            ),
        ],
      ),
    );
  }
}
