
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../AppLogic/imageConvertor.dart';
import '../BuyerScreens/buyer_logic.dart'; // Import BuyerLogic

void showItemDetailDialog(
  BuildContext context,
  Map<String, dynamic> data,
  BuyerLogic buyerLogic,
  VoidCallback refreshCart, // Callback to refresh UI that shows cart state
) {
  final _formKey = GlobalKey<FormState>();
  bool assignCourier = false;
  final TextEditingController deliveryLocationController = TextEditingController();
  final TextEditingController specialInstructionsController = TextEditingController();

  // Dispose controllers when the dialog is disposed, though this is tricky
  // because the dialog's lifecycle isn't directly tied to a widget's dispose method here.
  // A more robust solution might involve converting showItemDetailDialog to a StatefulWidget.
  // For now, we'll rely on them being garbage collected when the dialog closes and they go out of scope.

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return AlertDialog(
          title: Text(data['title'] ?? 'Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image display logic
                if (data['imageBase64'] != null && (data['imageBase64'] as String).isNotEmpty)
                  Image.memory(ImageConverter.base64ToImage(data['imageBase64'] as String))
                else if (data['image'] != null && (data['image'] as String).isNotEmpty)
                  Image.network(data['image'] as String)
                else
                  Image.asset(
                    'lib/Images/placeholder.png',
                    height: 150,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 150);
                    },
                  ),
                const SizedBox(height: 8),
                Text('Price: \$${data['price'] ?? ''}'),
                Text('Category: ${data['category'] ?? ''}'),
                Text('Condition: ${data['condition'] ?? ''}'),
                Text('Location: ${data['location'] ?? ''}'),
                Text('Stage: ${data['sellingStage'] ?? ''}'),
                Text('Seller: ${data['sellerName'] ?? ''}'),
                Text('Contact: ${data['sellerPhoneNumber'] ?? ''}'),
                const SizedBox(height: 8),
                Text(data['description'] ?? '', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Assign a Courier?"),
                    Switch(
                      value: assignCourier,
                      onChanged: (bool value) {
                        setState(() {
                          assignCourier = value;
                        });
                      },
                    ),
                  ],
                ),
                if (assignCourier)
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: deliveryLocationController,
                          decoration: const InputDecoration(labelText: 'Delivery Location'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a delivery location';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: specialInstructionsController,
                          decoration: const InputDecoration(labelText: 'Special Instructions (Optional)'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ElevatedButton(
              onPressed: () {
                Map<String, dynamic> itemToAdd = Map.from(data); // Create a mutable copy

                if (assignCourier) {
                  if (_formKey.currentState!.validate()) {
                    itemToAdd['assignCourier'] = true;
                    itemToAdd['deliveryLocation'] = deliveryLocationController.text;
                    itemToAdd['specialInstructions'] = specialInstructionsController.text;
                  } else {
                    // If validation fails, show a message and don't proceed
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in all required delivery details.')),
                    );
                    return; // Stop further execution
                  }
                } else {
                  itemToAdd['assignCourier'] = false;
                }

                buyerLogic.addToCart(itemToAdd, context, refreshCart);
                // Optionally, pop the dialog after adding to cart
                // Navigator.pop(context);
              },
              child: const Text("Add to Cart"),
            ),
          ],
        );
      },
    ),
  );
}