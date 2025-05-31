import 'package:flutter/material.dart';
import 'item_detail_dialog.dart';
import '../BuyerScreens/buyer_logic.dart';
import 'dart:typed_data'; 
import '../AppLogic/imageConvertor.dart';

class ItemsTab extends StatefulWidget {
  final BuyerLogic buyerLogic;

  const ItemsTab({super.key, required this.buyerLogic});

  @override
  _ItemsTabState createState() => _ItemsTabState();
}

class _ItemsTabState extends State<ItemsTab> {
  @override
  void initState() {
    super.initState();
    // Assuming BuyerLogic is already initialized by BuyerHomePage.
    // If not, widget.buyerLogic.init(_refreshItemsTab) might be called here.
    // Listener for search controller
    widget.buyerLogic.searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.buyerLogic.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    // Call filterProducts and refresh UI
    // The actual filtering logic is within BuyerLogic
    widget.buyerLogic.filterProducts(widget.buyerLogic.searchController.text, _refreshItemsTab);
  }

  void _refreshItemsTab() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the list of filtered products from BuyerLogic
    final List<Map<String, dynamic>> filteredProducts = widget.buyerLogic.filteredProducts;

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: widget.buyerLogic.searchController,
            decoration: const InputDecoration(
              labelText: 'Search items',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            // onChanged is not strictly needed here if using the listener,
            // but can be kept for immediate feedback if preferred over listener-only approach.
            // For this implementation, listener is primary.
          ),
        ),
        // Category Filters
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.buyerLogic.categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: widget.buyerLogic.selectedCategory == cat,
                    onSelected: (isSelected) {
                      if (isSelected) {
                        widget.buyerLogic.selectCategory(cat, _refreshItemsTab);
                      }
                    },
                    selectedColor: Colors.green,
                    labelStyle: TextStyle(
                      color: widget.buyerLogic.selectedCategory == cat ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Items Grid
        Expanded(
          child: filteredProducts.isEmpty
              ? const Center(child: Text('No items match your search/filter.'))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GridView.builder(
                    itemCount: filteredProducts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 3 / 4, // Adjust as needed
                    ),
                    itemBuilder: (_, i) {
                      // Data already includes 'id' and 'ownerId' if populated correctly by BuyerLogic.loadProducts
                      final Map<String, dynamic> dataWithId = filteredProducts[i];
                      
                      // Ensure required fields for display are present with defaults
                      final String title = dataWithId['title'] ?? dataWithId['name'] ?? 'No title';
                      // final String imageUrl = dataWithId['image'] as String? ?? ''; // No longer using imageUrl directly for display logic controller
                      final String price = dataWithId['price']?.toString() ?? '—';
                      final String sellerName = dataWithId['sellerName'] ?? 'Unknown';

                      return GestureDetector(
                        onTap: () => showItemDetailDialog(context, dataWithId, widget.buyerLogic, () {
                           // Optional: callback after dialog closes or item added to cart from dialog
                           // For now, CartScreen manages its own refresh.
                        }),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          clipBehavior: Clip.hardEdge,
                          elevation: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: () {
                                  final String base64String = dataWithId['imageBase64'] as String? ?? '';
                                  if (base64String.isNotEmpty) {
                                    try {
                                      final Uint8List bytes = ImageConverter.base64ToImage(base64String);
                                      return Image.memory(
                                        bytes,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          // Placeholder for corrupt base64 or other memory image errors
                                          return Container(
                                            color: Colors.grey.shade200,
                                            child: Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                color: Colors.grey.shade400,
                                                size: 50,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    } catch (e) {
                                      // Catch errors from base64ToImage if string is invalid
                                      return Container(
                                        color: Colors.grey.shade200,
                                        child: Center(
                                          child: Icon(
                                            Icons.broken_image, // Or Icons.image_not_supported
                                            color: Colors.grey.shade400,
                                            size: 50,
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    // Placeholder if no base64 string is available
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey.shade400,
                                          size: 50,
                                        ),
                                      ),
                                    );
                                  }
                                }(), // Immediately Invoked Function Expression (IIFE) to use logic block
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$$price',
                                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Seller: $sellerName',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
        ),
      ],
    );
  }
}