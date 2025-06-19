import 'package:flutter/material.dart';

class ChatDetailScreen extends StatelessWidget {
  final String userName;
  final String? avatarAsset ; 

  const ChatDetailScreen({
    super.key,
    required this.userName,
    this.avatarAsset, 
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), 
      appBar: AppBar(
        titleSpacing: 0, 
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
              backgroundImage: avatarAsset != null
                  ? AssetImage(avatarAsset!)
                  : null, 
              child: avatarAsset == null
                  ? Icon(Icons.person, color: Colors.grey[600])
                  : null, 
            ),
            const SizedBox(width: 10),
            Text(
              userName, 
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0079CF), 
                Color(0xFF00FFDE),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0, 
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0079CF), 
              Color(0xFF00FFDE), 
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.4], 
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: const [
                  Align(
                    alignment: Alignment.centerRight,
                    child: MessageBubble(
                      text: 'Chào anh',
                      time: '8:50',
                      isMe: true,
                    ),
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: MessageBubble(
                      text: 'Chào bạn, có chuyện gì không?',
                      time: '8:52',
                      isMe: false, 
                    ),
                  ),
                  SizedBox(height: 10),
                   Align(
                    alignment: Alignment.centerRight,
                    child: MessageBubble(
                      text: 'Tôi muốn mua sách Vật Lí đại cương anh đang bán?',
                      time: '8:55',
                      isMe: true,
                    ),
                  ),
                ],
              ),
            ),
            _buildInputBox(), 
          ],
        ),
      ),
    );
  }

  Widget _buildInputBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.grey),
            onPressed: () {
              debugPrint('Nhấn biểu tượng camera');
            },
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn ...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF0F2F5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.sentiment_satisfied_alt, color: Colors.grey),
            onPressed: () {
              debugPrint('Nhấn biểu tượng cảm xúc');
            },
          ),
        ],
      ),
    );
  }
}

// Widget riêng cho từng tin nhắn
class MessageBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xFFE0F7FA) : const Color(0xFFE0E0E0), // Màu xanh nhạt hoặc xám nhạt
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(4),
              bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(12),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isMe ? Colors.blue.shade900 : Colors.black87,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}