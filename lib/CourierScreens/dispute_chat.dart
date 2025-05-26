import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DisputeChatScreen extends StatefulWidget {
  final String orderId;

  const DisputeChatScreen({super.key, required this.orderId});

  @override
  State<DisputeChatScreen> createState() => _DisputeChatScreenState();
}

class _DisputeChatScreenState extends State<DisputeChatScreen> {
  static const Color backgroundColor = Color(0xFFEFE9DC);
  static const Color primaryColor = Color(0xFF7BA05B);
  static const Color textColor = Color(0xFF2E3C48);

  final TextEditingController messageController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  final List<Map<String, dynamic>> messages = [
    {
      'sender': 'Buyer',
      'text': 'Hi, I didn’t receive the charger with my laptop.',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
    },
    {
      'sender': 'Courier',
      'text': 'Let me check with the seller.',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 4)),
    },
    {
      'sender': 'Seller',
      'text': 'It was included in the box when I handed it over.',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 3)),
    },
  ];

  void sendMessage() {
    String text = messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({
        'sender': 'Courier',
        'text': text,
        'timestamp': DateTime.now(),
      });
      messageController.clear();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  Widget buildBubble(Map<String, dynamic> msg) {
    bool isCourier = msg['sender'] == 'Courier';
    bool isBuyer = msg['sender'] == 'Buyer';
    bool isSeller = msg['sender'] == 'Seller';

    Color bubbleColor =
        isCourier ? primaryColor : isBuyer ? Colors.grey[200]! : Colors.orange[100]!;

    CrossAxisAlignment alignment =
        isCourier ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          constraints: const BoxConstraints(maxWidth: 280),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${msg['sender']}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCourier ? Colors.white : textColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                msg['text'],
                style: TextStyle(
                  color: isCourier ? Colors.white : Colors.black,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  DateFormat.Hm().format(msg['timestamp']),
                  style: TextStyle(
                    fontSize: 10,
                    color: isCourier ? Colors.white70 : Colors.black45,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Dispute: ${widget.orderId}"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: messages.length,
              itemBuilder: (context, index) => buildBubble(messages[index]),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: primaryColor,
                  onPressed: sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
