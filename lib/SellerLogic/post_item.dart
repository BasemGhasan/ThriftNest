import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../AppLogic/imageConvertor.dart';

/// Top‐level function for `compute()`; converts raw bytes to a Base64 string.
String _bytesToBase64(Uint8List bytes) {
  return ImageConverter.imageToBase64(bytes);
}

/// Creates a Firestore document for a new item, under `items/`.
/// If [imageBytes] is provided, the Base64 encoding is offloaded to an isolate.
/// If [latitude] and [longitude] are non‐null, we store a GeoPoint; otherwise, we
/// write the manual [location] string.
Future<void> submitNewItem({
  required String title,
  required double price,
  required String description,
  required String condition,
  required String category,
  required String location,
  double? latitude,
  double? longitude,
  Uint8List? imageBytes,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw FirebaseAuthException(
      code: 'no-user',
      message: 'You must be signed in to post an item.',
    );
  }
  final ownerId = user.uid;

  // offload image → Base64 if needed
  String? imageBase64;
  if (imageBytes != null) {
    imageBase64 = await compute(_bytesToBase64, imageBytes);
  }

  final data = <String, dynamic>{
    'title':       title,
    'price':       price,
    'description': description,
    'condition':   condition,
    'category':    category,
    'ownerId':     ownerId,
    'createdAt':   FieldValue.serverTimestamp(),
    if (imageBase64 != null) 'imageBase64': imageBase64,

    // location vs. geoPoint
    if (latitude != null && longitude != null)
      'geoPoint': GeoPoint(latitude, longitude)
    else
      'location': location,
  };

  await FirebaseFirestore.instance.collection('items').add(data);
}
