import 'package:flutter/material.dart';
import '../BuyerScreens/buyer_logic.dart'; // Assuming project structure

class CartScreen extends StatefulWidget {
  final BuyerLogic buyerLogic;

  const CartScreen({Key? key, required this.buyerLogic}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _buildPriceDetails(BuyerLogic buyerLogic) {
    String details = "Includes: Items total (\$${buyerLogic.getCartItemsSubtotal().toStringAsFixed(2)})";
    if (buyerLogic.getDeliveryFee() > 0) {
      details += " + Delivery fee (\$${buyerLogic.getDeliveryFee().toStringAsFixed(2)})";
    }
    return details;
  }

  void _removeItem(Map<String, dynamic> item) {
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
          if (cart.isNotEmpty) ...[ // Use collection if to group multiple widgets based on a condition
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end, // Align text to the right
                children: [
                  Text(
                    'Items Subtotal: \$${widget.buyerLogic.getCartItemsSubtotal().toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (widget.buyerLogic.getDeliveryFee() > 0) ...[
                    SizedBox(height: 4),
                    Text(
                      'Delivery Fee: \$${widget.buyerLogic.getDeliveryFee().toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Divider(),
                  Text(
                    'Grand Total: \$${widget.buyerLogic.getGrandTotalPrice().toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  // Detailed breakdown (smaller, gray)
                  Text(
                    _buildPriceDetails(widget.buyerLogic), // Helper function for clarity
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
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
        ],
      ),
    );
  }
}