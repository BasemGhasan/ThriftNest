import 'package:flutter/material.dart';

void showItemDetailDialog(BuildContext context, Map<String, dynamic> data) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(data['title'] ?? 'Details'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((data['image'] as String?)?.isNotEmpty == true)
              Image.network(data['image'] as String),
            const SizedBox(height: 8),
            Text('Price: \$${data['price'] ?? ''}'),
            Text('Category: ${data['category'] ?? ''}'),
            Text('Condition: ${data['condition'] ?? ''}'),
            Text('Location: ${data['location'] ?? ''}'),
            Text('Stage: ${data['sellingStage'] ?? ''}'),
            Text('Seller: ${data['sellerName'] ?? ''}'),
            Text('Contact: ${data['sellerPhoneNumber'] ?? ''}'),
            const SizedBox(height: 8),
            Text(data['description'] ?? '', style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    ),
  );
}