// lib/courierLogic/delivery_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum DeliveryStatus {
  pending,
  accepted,
  inTransit,
  delivered,
  cancelled
}

class DeliveryRequest {
  final String id;
  final String itemId;
  final String itemTitle;
  final String sellerId;
  final String sellerName;
  final String sellerPhone;
  final String buyerId;
  final String buyerName;
  final String buyerPhone;
  final String pickupAddress;
  final String deliveryAddress;
  final String? courierId;
  final String? courierName;
  final DeliveryStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? deliveredAt;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String? specialInstructions;

  DeliveryRequest({
    required this.id,
    required this.itemId,
    required this.itemTitle,
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhone,
    required this.buyerId,
    required this.buyerName,
    required this.buyerPhone,
    required this.pickupAddress,
    required this.deliveryAddress,
    this.courierId,
    this.courierName,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.deliveredAt,
    this.pickupLatitude,
    this.pickupLongitude,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.specialInstructions,
  });

  factory DeliveryRequest.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return DeliveryRequest(
      id: doc.id,
      itemId: data['itemId'] as String? ?? '',
      itemTitle: data['itemTitle'] as String? ?? '',
      sellerId: data['sellerId'] as String? ?? '',
      sellerName: data['sellerName'] as String? ?? '',
      sellerPhone: data['sellerPhone'] as String? ?? '',
      buyerId: data['buyerId'] as String? ?? '',
      buyerName: data['buyerName'] as String? ?? '',
      buyerPhone: data['buyerPhone'] as String? ?? '',
      pickupAddress: data['pickupAddress'] as String? ?? '',
      deliveryAddress: data['deliveryAddress'] as String? ?? '',
      courierId: data['courierId'] as String?,
      courierName: data['courierName'] as String?,
      status: _parseStatus(data['status'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      acceptedAt: (data['acceptedAt'] as Timestamp?)?.toDate(),
      deliveredAt: (data['deliveredAt'] as Timestamp?)?.toDate(),
      pickupLatitude: (data['pickupLatitude'] as num?)?.toDouble(),
      pickupLongitude: (data['pickupLongitude'] as num?)?.toDouble(),
      deliveryLatitude: (data['deliveryLatitude'] as num?)?.toDouble(),
      deliveryLongitude: (data['deliveryLongitude'] as num?)?.toDouble(),
      specialInstructions: data['specialInstructions'] as String?,
    );
  }

  static DeliveryStatus _parseStatus(String? status) {
    switch (status) {
      case 'pending':
        return DeliveryStatus.pending;
      case 'accepted':
        return DeliveryStatus.accepted;
      case 'inTransit':
        return DeliveryStatus.inTransit;
      case 'delivered':
        return DeliveryStatus.delivered;
      case 'cancelled':
        return DeliveryStatus.cancelled;
      default:
        return DeliveryStatus.pending;
    }
  }

  String get statusString {
    switch (status) {
      case DeliveryStatus.pending:
        return 'pending';
      case DeliveryStatus.accepted:
        return 'accepted';
      case DeliveryStatus.inTransit:
        return 'inTransit';
      case DeliveryStatus.delivered:
        return 'delivered';
      case DeliveryStatus.cancelled:
        return 'cancelled';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemTitle': itemTitle,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerPhone': sellerPhone,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerPhone': buyerPhone,
      'pickupAddress': pickupAddress,
      'deliveryAddress': deliveryAddress,
      'courierId': courierId,
      'courierName': courierName,
      'status': statusString,
      'createdAt': FieldValue.serverTimestamp(),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'deliveryLatitude': deliveryLatitude,
      'deliveryLongitude': deliveryLongitude,
      'specialInstructions': specialInstructions,
    };
  }
}