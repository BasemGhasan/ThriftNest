// lib/courierScreens/available_deliveries.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../courierLogic/delivery_service.dart';
import '../courierLogic/delivery_model.dart';
import 'delivery_detail_screen.dart';

class AvailableDeliveries extends StatelessWidget {
  const AvailableDeliveries({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThriftNestApp.backgroundColor,
      body: StreamBuilder<List<DeliveryRequest>>(
        stream: DeliveryService.getAvailableDeliveries(),
        builder: (context, snapshot) {
          print('🔍 StreamBuilder state: ${snapshot.connectionState}');
          print('🔍 Has data: ${snapshot.hasData}');
          print('🔍 Has error: ${snapshot.hasError}');
          if (snapshot.hasError) {
            print('❌ Error: ${snapshot.error}');
          }
          if (snapshot.hasData) {
            print('📦 Deliveries count: ${snapshot.data!.length}');
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Force refresh by rebuilding widget
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const AvailableDeliveries()),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading deliveries...'),
                ],
              ),
            );
          }

          final deliveries = snapshot.data!;

          if (deliveries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_shipping,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Available Deliveries',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for new delivery requests',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // The stream will automatically refresh
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: deliveries.length,
              itemBuilder: (context, index) {
                final delivery = deliveries[index];
                return DeliveryCard(
                  delivery: delivery,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeliveryDetailScreen(
                          delivery: delivery,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DeliveryCard extends StatelessWidget {
  final DeliveryRequest delivery;
  final VoidCallback onTap;

  const DeliveryCard({
    Key? key,
    required this.delivery,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      delivery.itemTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ThriftNestApp.textColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'PENDING',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildLocationRow(
                icon: Icons.location_on,
                label: 'Pickup',
                address: delivery.pickupAddress,
                isPickup: true,
              ),
              const SizedBox(height: 8),
              _buildLocationRow(
                icon: Icons.place,
                label: 'Delivery',
                address: delivery.deliveryAddress,
                isPickup: false,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'From: ${delivery.sellerName}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(delivery.createdAt),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required String label,
    required String address,
    required bool isPickup,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: isPickup ? ThriftNestApp.primaryColor : Colors.red,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 14,
                  color: ThriftNestApp.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}