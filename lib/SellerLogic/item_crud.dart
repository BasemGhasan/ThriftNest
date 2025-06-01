// lib/SellerLogic/item_crud.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../AppLogic/imageConvertor.dart';
import 'package:flutter/foundation.dart';

/// Deletes the Firestore document for [itemId].
/// Throws if the delete fails.
Future<void> deleteItem(String itemId) async {
  await FirebaseFirestore.instance
      .collection('items')
      .doc(itemId)
      .delete();
}

/// Updates the Firestore document for [itemId] with the given fields.
/// Any parameter left null will not be updated.
/// If [imageBytes] is provided, it will be converted to Base64 off the UI
/// thread before writing to Firestore.
Future<void> updateItem({
  required String itemId,
  String? title,
  double? price,
  String? description,
  String? condition,
  String? category,
  String? location,
  Uint8List? imageBytes,
 String? sellingStage,
}) async {
  // Build the map of fields to update
  final data = <String, dynamic>{};
  if (title != null) data['title'] = title;
  if (price != null) data['price'] = price;
  if (description != null) data['description'] = description;
  if (condition != null) data['condition'] = condition;
  if (category != null) data['category'] = category;
  if (location != null) data['location'] = location;
  if (sellingStage != null) data['sellingStage'] = sellingStage;

  // If an image was supplied, encode it first off the UI thread:
  if (imageBytes != null) {
    final base64Str = await compute(
      (Uint8List bytes) => ImageConverter.imageToBase64(bytes),
      imageBytes,
    );
    data['imageBase64'] = base64Str;
  }

  if (data.isEmpty) return; // nothing to update

  await FirebaseFirestore.instance
      .collection('items')
      .doc(itemId)
      .update(data);
}

