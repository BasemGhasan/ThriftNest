// lib/integration/purchase_handler.dart
// This is an example of how to integrate delivery requests with purchases

import 'package:cloud_firestore/cloud_firestore.dart';
import '../courierLogic/delivery_service.dart';

class PurchaseHandler {
  /// This function should be called when a buyer successfully purchases an item
  /// For now, this is a sample implementation - in a real app, this would be 
  /// triggered after payment confirmation
  static Future<void> handlePurchase({
    required String itemId,
    required String buyerId,
    required String sellerId,
  }) async {
    try {
      // Get buyer information
      final buyerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(buyerId)
          .get();
      final buyerData = buyerDoc.data()!;

      // Get seller information
      final sellerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(sellerId)
          .get();
      final sellerData = sellerDoc.data()!;

      // Get item information
      final itemDoc = await FirebaseFirestore.instance
          .collection('items')
          .doc(itemId)
          .get();
      final itemData = itemDoc.data()!;

      // Create delivery request
      await DeliveryService.createDeliveryRequest(
        itemId: itemId,
        itemTitle: itemData['title'] ?? 'Unknown Item',
        sellerId: sellerId,
        sellerName: sellerData['fullName'] ?? 'Unknown Seller',
        sellerPhone: sellerData['phone'] ?? 'No Phone',
        buyerId: buyerId,
        buyerName: buyerData['fullName'] ?? 'Unknown Buyer',
        buyerPhone: buyerData['phone'] ?? 'No Phone',
        pickupAddress: itemData['location'] ?? 'Unknown Location',
        deliveryAddress: 'Buyer Address (To be implemented)', // TODO: Get actual buyer address
        specialInstructions: 'Handle with care',
      );

      print('✅ Delivery request created successfully for item: ${itemData['title']}');
    } catch (e) {
      print('❌ Error creating delivery request: $e');
      rethrow;
    }
  }

  /// Test function to create sample delivery requests for testing courier functionality
  static Future<void> createSampleDeliveryRequests() async {
    final sampleRequests = [
      {
        'itemId': 'sample_item_1',
        'itemTitle': 'iPhone 12 Pro',
        'sellerId': 'seller_123',
        'sellerName': 'John Doe',
        'sellerPhone': '+60123456789',
        'buyerId': 'buyer_456',
        'buyerName': 'Jane Smith',
        'buyerPhone': '+60198765432',
        'pickupAddress': 'APU University, Technology Park Malaysia',
        'deliveryAddress': 'Sunway University, Bandar Sunway',
        'specialInstructions': 'Please handle with extra care - fragile item',
      },
      {
        'itemId': 'sample_item_2',
        'itemTitle': 'MacBook Air M1',
        'sellerId': 'seller_789',
        'sellerName': 'Ahmad Rahman',
        'sellerPhone': '+60187654321',
        'buyerId': 'buyer_101',
        'buyerName': 'Sarah Lee',
        'buyerPhone': '+60112345678',
        'pickupAddress': 'UTAR Kampar Campus, Perak',
        'deliveryAddress': 'UM University, Kuala Lumpur',
        'specialInstructions': 'Call before pickup and delivery',
      },
      {
        'itemId': 'sample_item_3',
        'itemTitle': 'Gaming Chair',
        'sellerId': 'seller_202',
        'sellerName': 'David Tan',
        'sellerPhone': '+60176543210',
        'buyerId': 'buyer_303',
        'buyerName': 'Lisa Wong',
        'buyerPhone': '+60134567890',
        'pickupAddress': 'Taylor\'s University, Subang Jaya',
        'deliveryAddress': 'INTI University, Nilai',
        'specialInstructions': 'Heavy item - may need assistance',
      },
    ];

    for (final request in sampleRequests) {
      try {
        await DeliveryService.createDeliveryRequest(
          itemId: request['itemId']!,
          itemTitle: request['itemTitle']!,
          sellerId: request['sellerId']!,
          sellerName: request['sellerName']!,
          sellerPhone: request['sellerPhone']!,
          buyerId: request['buyerId']!,
          buyerName: request['buyerName']!,
          buyerPhone: request['buyerPhone']!,
          pickupAddress: request['pickupAddress']!,
          deliveryAddress: request['deliveryAddress']!,
          specialInstructions: request['specialInstructions'],
        );
        print('✅ Created sample delivery request: ${request['itemTitle']}');
      } catch (e) {
        print('❌ Error creating sample request for ${request['itemTitle']}: $e');
      }
    }
  }
}