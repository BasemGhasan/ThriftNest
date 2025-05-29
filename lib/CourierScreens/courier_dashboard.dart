import 'package:flutter/material.dart';
import 'batch_screen.dart';
import 'live_tracking.dart';
import 'proof_of_delivery.dart';
import 'profile_settings.dart';
import 'dispute_chat.dart';

class CourierDashboard extends StatefulWidget {
  const CourierDashboard({super.key});

  @override
  State<CourierDashboard> createState() => _CourierDashboardState();
}

class _CourierDashboardState extends State<CourierDashboard> {
  static const Color backgroundColor = Color(0xFFEFE9DC);
  static const Color primaryColor = Color(0xFF7BA05B);
  static const Color textColor = Color(0xFF2E3C48);

  List<Map<String, dynamic>> deliveries = [
    {
      'id': 'D001',
      'title': 'Parcel #D001',
      'pickup': 'Hostel A',
      'dropoff': 'Library',
      'time': '10:00 AM',
      'status': 'request',
      'pickupCoords': [3.139, 101.686],
      'dropoffCoords': [3.142, 101.690]
    },
    {
      'id': 'D002',
      'title': 'Parcel #D002',
      'pickup': 'Gate 1',
      'dropoff': 'Cafeteria',
      'time': '11:30 AM',
      'status': 'pickup',
      'pickupCoords': [3.138, 101.684],
      'dropoffCoords': [3.140, 101.688]
    },
    {
      'id': 'D003',
      'title': 'Parcel #D003',
      'pickup': 'Block E',
      'dropoff': 'Hostel C',
      'time': '1:00 PM',
      'status': 'active',
      'pickupCoords': [3.141, 101.689],
      'dropoffCoords': [3.137, 101.687]
    },
    {
      'id': 'D004',
      'title': 'Parcel #D004',
      'pickup': 'Cafeteria',
      'dropoff': 'Library',
      'time': 'Yesterday',
      'status': 'completed',
      'pickupCoords': [3.140, 101.688],
      'dropoffCoords': [3.142, 101.690]
    },
  ];

  void updateStatus(String id, String newStatus) {
    setState(() {
      final index = deliveries.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        deliveries[index]['status'] = newStatus;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CourierDashboard()));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CourierProfileSettings()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 20),
              _summaryStats(),
              const SizedBox(height: 10),
              _section("Requests", "request"),
              _section("Pickup Assigned", "pickup"),
              _section("Active Deliveries", "active"),
              _section("Completed Deliveries", "completed"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          'lib/images/ThriftNest_Logo.png',
          height: 40,
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.layers, color: textColor),
              tooltip: "Batch Deliveries",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BatchDeliveriesScreen(deliveries: deliveries),
                  ),
                );
              },
            ),
            const Icon(Icons.notifications_none, color: textColor),
          ],
        ),
      ],
    );
  }

  Widget _summaryStats() {
    final total = deliveries.length;
    final completed = deliveries.where((d) => d['status'] == 'completed').length;
    final active = deliveries.where((d) => d['status'] == 'active').length;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Performance Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 12),
          _statRow("Total Deliveries", total.toString()),
          _statRow("Completed Deliveries", completed.toString()),
          _statRow("Active Deliveries", active.toString()),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: textColor)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
        ],
      ),
    );
  }

  Widget _section(String title, String status) {
    final items = deliveries.where((d) => d['status'] == status).toList();
    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 10),
        ...items.map((item) => _buildCard(item)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> data) {
    final String route = "${data['pickup']} → ${data['dropoff']}";
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'lib/images/ThriftNest_Logo.png',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(data['title'], style: const TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        subtitle: Text(route, style: const TextStyle(color: textColor)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(data['time'], style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
            if (data['status'] == 'request')
              TextButton(
                onPressed: () => updateStatus(data['id'], 'pickup'),
                child: const Text("Accept"),
              )
            else if (data['status'] == 'pickup' || data['status'] == 'active')
              TextButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LiveTracking()),
                  );
                  if (result != null && result is Map<String, dynamic>) {
                    updateStatus(result['id'], result['status']);
                  }
                },
                child: const Text("Track"),
              )
          ],
        ),
      ),
    );
  }
}
