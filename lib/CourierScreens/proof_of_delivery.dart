import 'package:flutter/material.dart';

class ProofOfDelivery extends StatelessWidget {
  const ProofOfDelivery({super.key});

  static const Color backgroundColor = Color(0xFFEFE9DC);
  static const Color primaryColor = Color(0xFF7BA05B);
  static const Color textColor = Color(0xFF2E3C48);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Proof of Delivery"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Placeholder box for photo / signature
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  "Photo or Signature Placeholder",
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Take Photo Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Photo capture triggered")),
                );
              },
              child: const Text("Take Photo"),
            ),
            const SizedBox(height: 16),
            
            // Confirm Delivery Button
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Delivery confirmed")),
                );
              },
              child: const Text("Confirm Delivery"),
            ),
          ],
        ),
      ),
    );
  }
}
