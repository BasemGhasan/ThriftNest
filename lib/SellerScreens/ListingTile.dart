// lib/SellerScreens/ListingTile.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../main.dart';
import '../AppLogic/imageConvertor.dart';
import '../SellerLogic/item_crud.dart';
import '../SellerLogic/Item_model.dart';

/// A single row in the seller’s “Manage Listings” screen.
/// Renders a thumbnail (from Base64), title, price, and Edit/Delete buttons.
class ListingTile extends StatelessWidget {
  final String id;
  final String title;
  final double price;
  final Uint8List? imageBytes;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ListingTile({
    Key? key,
    required this.id,
    required this.title,
    required this.price,
    this.imageBytes,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  /// Build a ListingTile straight from your Firestore document data.
  factory ListingTile.fromMap(Map<String, dynamic> data, String id) {
    Uint8List? bytes;
    if (data['imageBase64'] is String) {
      try {
        bytes = ImageConverter.base64ToImage(data['imageBase64'] as String);
      } catch (_) {
        bytes = null;
      }
    }
    return ListingTile(
      id: id,
      title: data['title'] as String? ?? '',
      price: (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0,
      imageBytes: bytes,
      onEdit: () async {
        // TODO: launch your edit form, then...
        // await updateItem(...);
      },
      onDelete: () async {
        await deleteItem(id);
        // StreamBuilder will refresh automatically
      },
    );
  }

  /// Simplifies creating a tile directly from your model.
  static ListingTile fromModel(
    ItemModel item, {
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return ListingTile(
      id: item.id,
      title: item.title,
      price: item.price,
      imageBytes: item.imageBytes,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 64,
                height: 64,
                color: Colors.grey[200],
                child: imageBytes != null
                    ? Image.memory(
                        imageBytes!,
                        fit: BoxFit.cover,
                        width: 64,
                        height: 64,
                      )
                    : const Icon(Icons.image, size: 40, color: Colors.grey),
              ),
            ),

            const SizedBox(width: 16),

            // title & price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ThriftNestApp.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // Edit / Delete buttons
            Row(
              children: [
                if (onEdit != null)
                  TextButton(
                    onPressed: onEdit,
                    style: TextButton.styleFrom(
                      backgroundColor: ThriftNestApp.primaryColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        color: ThriftNestApp.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (onEdit != null && onDelete != null)
                  const SizedBox(width: 8),
                if (onDelete != null)
                  TextButton(
                    onPressed: onDelete,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
