// lib/CourierScreens/courier_statistics.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../courierLogic/delivery_service.dart';
import '../courierLogic/delivery_model.dart';

class CourierStatistics extends StatelessWidget {
  const CourierStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return const Center(
        child: Text('Please log in to view statistics'),
      );
    }

    return Scaffold(
      backgroundColor: ThriftNestApp.backgroundColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('deliveryRequests')
            .where('courierId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error loading statistics'),
                  SizedBox(height: 8),
                  Text('${snapshot.error}', style: TextStyle(fontSize: 12)),
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
                  Text('Loading your statistics...'),
                ],
              ),
            );
          }

          print('📊 Total documents found: ${snapshot.data!.docs.length}');
          
          // Convert documents to delivery objects with error handling
          final deliveries = <DeliveryRequest>[];
          for (var doc in snapshot.data!.docs) {
            try {
              final delivery = DeliveryRequest.fromDoc(doc as DocumentSnapshot<Map<String, dynamic>>);
              deliveries.add(delivery);
              print('✅ Parsed delivery: ${delivery.itemTitle} - Status: ${delivery.status}');
            } catch (e) {
              print('❌ Error parsing delivery ${doc.id}: $e');
            }
          }

          // Calculate statistics with debugging
          final totalDeliveries = deliveries.length;
          final completedDeliveries = deliveries
              .where((d) => d.status == DeliveryStatus.delivered)
              .length;
          final activeDeliveries = deliveries
              .where((d) => d.status == DeliveryStatus.accepted || 
                           d.status == DeliveryStatus.inTransit)
              .length;
          final cancelledDeliveries = deliveries
              .where((d) => d.status == DeliveryStatus.cancelled)
              .length;
          final pendingDeliveries = deliveries
              .where((d) => d.status == DeliveryStatus.pending)
              .length;

          print('📈 Statistics: Total=$totalDeliveries, Completed=$completedDeliveries, Active=$activeDeliveries, Cancelled=$cancelledDeliveries, Pending=$pendingDeliveries');

          // Calculate completion rate
          final completionRate = totalDeliveries > 0 
              ? (completedDeliveries / totalDeliveries * 100).toStringAsFixed(1)
              : '0.0';

          // Calculate earnings (RM 5 per completed delivery)
          final totalEarnings = completedDeliveries * 5.0;

          // Get completed deliveries for recent list
          final recentCompletedDeliveries = deliveries
              .where((d) => d.status == DeliveryStatus.delivered && d.deliveredAt != null)
              .toList();
          
          // Sort by delivery date (most recent first)
          recentCompletedDeliveries.sort((a, b) => 
              b.deliveredAt!.compareTo(a.deliveredAt!));

          // Show debug info if no data
          if (totalDeliveries == 0) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Delivery Statistics',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ThriftNestApp.textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.info, size: 64, color: Colors.blue),
                          SizedBox(height: 16),
                          Text(
                            'No Delivery History',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'You haven\'t accepted any deliveries yet. Go to the Available tab to start accepting delivery requests!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          SizedBox(height: 16),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delivery Statistics',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ThriftNestApp.textColor,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Deliveries',
                        value: totalDeliveries.toString(),
                        icon: Icons.local_shipping,
                        color: ThriftNestApp.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Completed',
                        value: completedDeliveries.toString(),
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Active',
                        value: activeDeliveries.toString(),
                        icon: Icons.directions_run,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Cancelled',
                        value: cancelledDeliveries.toString(),
                        icon: Icons.cancel,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Performance Card
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
                          'Performance',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ThriftNestApp.textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: ThriftNestApp.primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Completion Rate: $completionRate%',
                              style: const TextStyle(
                                fontSize: 16,
                                color: ThriftNestApp.textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: double.parse(completionRate) / 100,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ThriftNestApp.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Earnings Card
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
                          'Earnings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ThriftNestApp.textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.attach_money,
                              color: Colors.green,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Total Earned: RM ${totalEarnings.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'RM 5.00 per completed delivery',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Recent Completed Deliveries
                if (completedDeliveries > 0) ...[
                  const Text(
                    'Recent Completed Deliveries',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThriftNestApp.textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...deliveries
                      .where((d) => d.status == DeliveryStatus.delivered)
                      .take(5)
                      .map((delivery) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              title: Text(delivery.itemTitle),
                              subtitle: Text(
                                'Delivered: ${_formatDate(delivery.deliveredAt!)}',
                              ),
                              trailing: const Text(
                                'RM 5.00',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}