import 'package:flutter/material.dart';

class BatchDeliveriesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> deliveries;

  const BatchDeliveriesScreen({super.key, required this.deliveries});

  @override
  State<BatchDeliveriesScreen> createState() => _BatchDeliveriesScreenState();
}

class _BatchDeliveriesScreenState extends State<BatchDeliveriesScreen> {
  static const Color backgroundColor = Color(0xFFEFE9DC);
  static const Color primaryColor = Color(0xFF7BA05B);
  static const Color textColor = Color(0xFF2E3C48);

  late List<Map<String, dynamic>> batchList;

  @override
  void initState() {
    super.initState();
    _groupBatchDeliveries();
  }

  void _groupBatchDeliveries() {
    final requests = widget.deliveries.where((d) => d['status'] == 'request').toList();

    // Simulated batch: deliveries with same dropoff
    batchList = requests.where((d) => d['dropoff'] == 'Library').toList();
    batchList.sort((a, b) => a['time'].compareTo(b['time']));
  }

  void _acceptAllBatch() {
    for (var d in batchList) {
      d['status'] = 'pickup';
    }

    Navigator.pop(context, batchList); // return updated batch list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Batch Delivery Planning"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: batchList.isEmpty
          ? const Center(
              child: Text("No batchable deliveries available.",
                  style: TextStyle(color: textColor)))
          : Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Grouped by drop-off location: Library",
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: batchList.length,
                      itemBuilder: (context, index) {
                        final d = batchList[index];
                        return Card(
                          color: Colors.white,
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(d['title'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, color: textColor)),
                            subtitle: Text(
                              "From ${d['pickup']} to ${d['dropoff']} at ${d['time']}",
                              style: const TextStyle(color: textColor),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _acceptAllBatch,
                    child: const Text("Accept All as Batch"),
                  )
                ],
              ),
            ),
    );
  }
}
