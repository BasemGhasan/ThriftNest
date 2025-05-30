// lib/SellerLogic/Item_model.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A simple Dart model for one “item” document.
class ItemModel {
  final String id;
  final String title;
  final double price;
  final String description;
  final String condition;
  final String category;
  final String location;
  final String ownerId;
  final DateTime createdAt;
  final String? imageBase64;
  final String sellingStage;

  ItemModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.condition,
    required this.category,
    required this.location,
    required this.ownerId,
    required this.createdAt,
    this.imageBase64,
    required this.sellingStage,
  });

  /// Build from a Firestore document snapshot.
  factory ItemModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ItemModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      price: (data['price'] as num).toDouble(),
      description: data['description'] as String? ?? '',
      condition: data['condition'] as String? ?? '',
      category: data['category'] as String? ?? '',
      location: data['location'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageBase64: data['imageBase64'] as String?,
      sellingStage: data['sellingStage'] as String? ?? 'On Sale',
    );
  }

  /// If there is an attached Base64 image, decode it to raw bytes.
  Uint8List? get imageBytes =>
      imageBase64 == null ? null : base64Decode(imageBase64!);
}
