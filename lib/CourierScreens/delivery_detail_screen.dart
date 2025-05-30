// lib/courierScreens/delivery_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Remove url_launcher import for now - we'll add it back after fixing dependencies
// import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../courierLogic/delivery_service.dart';
import '../courierLogic/delivery_model.dart';

class DeliveryDetailScreen extends StatefulWidget {
  final DeliveryRequest delivery;
  final bool isMyDelivery;

  const DeliveryDetailScreen({
    Key? key,
    required this.delivery,
    this.isMyDelivery = false,
  }) : super(key: key);

  @override
  State<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends State<DeliveryDetailScreen> {
  bool _isLoading = false;

  Future<void> _acceptDelivery() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // Get courier name from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final courierName = userDoc.data()?['fullName'] as String? ?? 'Courier';

      await DeliveryService.acceptDelivery(
        widget.delivery.id,
        user.uid,
        courierName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Delivery accepted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting delivery: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startDelivery() async {
    setState(() => _isLoading = true);
    try {
      await DeliveryService.startDelivery(widget.delivery.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📦 Delivery started!'),
            backgroundColor: Colors.blue,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting delivery: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _completeDelivery() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Delivery'),
        content: const Text('Are you sure you want to mark this delivery as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await DeliveryService.completeDelivery(widget.delivery.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Delivery completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing delivery: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelDelivery() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Delivery'),
        content: const Text('Are you sure you want to cancel this delivery? It will be returned to the available list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await DeliveryService.cancelDelivery(widget.delivery.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery cancelled and returned to available list'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling delivery: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Temporarily disable phone call functionality until url_launcher is fixed
  Future<void> _makePhoneCall(String phoneNumber) async {
    // Show a simple dialog with the phone number for now
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call Contact'),
        content: Text('Phone: $phoneNumber\n\nPhone calling will be enabled once url_launcher is properly configured.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThriftNestApp.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Delivery Details',
          style: TextStyle(
            color: ThriftNestApp.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ThriftNestApp.textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Info Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.delivery.itemTitle,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ThriftNestApp.textColor,
                            ),
                          ),
                        ),
                        _buildStatusChip(widget.delivery.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Created: ${_formatDate(widget.delivery.createdAt)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (widget.delivery.acceptedAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Accepted: ${_formatDate(widget.delivery.acceptedAt!)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Location Details Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Route Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ThriftNestApp.textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLocationRow(
                      icon: Icons.location_on,
                      title: 'Pickup Location',
                      address: widget.delivery.pickupAddress,
                      color: ThriftNestApp.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 1,
                      color: Colors.grey.shade300,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    const SizedBox(height: 16),
                    _buildLocationRow(
                      icon: Icons.place,
                      title: 'Delivery Location',
                      address: widget.delivery.deliveryAddress,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Contact Info Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ThriftNestApp.textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildContactRow(
                      icon: Icons.person,
                      title: 'Seller',
                      name: widget.delivery.sellerName,
                      phone: widget.delivery.sellerPhone,
                    ),
                    const SizedBox(height: 12),
                    _buildContactRow(
                      icon: Icons.person_outline,
                      title: 'Buyer',
                      name: widget.delivery.buyerName,
                      phone: widget.delivery.buyerPhone,
                    ),
                  ],
                ),
              ),
            ),

            if (widget.delivery.specialInstructions != null &&
                widget.delivery.specialInstructions!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Special Instructions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThriftNestApp.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.delivery.specialInstructions!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: ThriftNestApp.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons
            if (!widget.isMyDelivery && widget.delivery.status == DeliveryStatus.pending)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _acceptDelivery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThriftNestApp.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Accept Delivery',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

            if (widget.isMyDelivery && widget.delivery.status == DeliveryStatus.accepted) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _startDelivery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Start Delivery',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _cancelDelivery,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Cancel Delivery',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],

            if (widget.isMyDelivery && widget.delivery.status == DeliveryStatus.inTransit) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _completeDelivery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Complete Delivery',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(DeliveryStatus status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case DeliveryStatus.accepted:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        label = 'ACCEPTED';
        break;
      case DeliveryStatus.inTransit:
        backgroundColor = ThriftNestApp.primaryColor.withOpacity(0.2);
        textColor = ThriftNestApp.primaryColor;
        label = 'IN TRANSIT';
        break;
      case DeliveryStatus.delivered:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        label = 'DELIVERED';
        break;
      case DeliveryStatus.cancelled:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        label = 'CANCELLED';
        break;
      default:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        label = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required String title,
    required String address,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
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

  Widget _buildContactRow({
    required IconData icon,
    required String title,
    required String name,
    required String phone,
  }) {
    return Row(
      children: [
        Icon(icon, color: ThriftNestApp.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThriftNestApp.textColor,
                ),
              ),
              Text(
                phone,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _makePhoneCall(phone),
          icon: Icon(
            Icons.phone,
            color: ThriftNestApp.primaryColor,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}