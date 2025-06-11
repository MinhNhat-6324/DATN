import 'package:flutter/material.dart';

class ChatDetailScreen extends StatelessWidget {
  final String userName; // Tên người dùng của cuộc trò chuyện này
  final String? avatarAsset ; // Đường dẫn đến ảnh avatar của người dùng khác

  const ChatDetailScreen({
    super.key,
    required this.userName,
    this.avatarAsset, // Có thể truyền avatar từ màn hình trước
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Nền xám nhạt cho toàn bộ màn hình
      appBar: AppBar(
        // Nút quay lại mặc định đã có trong AppBar
        titleSpacing: 0, // Bỏ khoảng cách mặc định của title
        title: Row(
          children: [
            CircleAvatar(
              radius: 20, // Kích thước avatar nhỏ trong AppBar
              backgroundColor: Colors.grey[200],
              backgroundImage: avatarAsset != null
                  ? AssetImage(avatarAsset!)
                  : null, // Sử dụng AssetImage nếu có
              child: avatarAsset == null
                  ? Icon(Icons.person, color: Colors.grey[600])
                  : null, // Icon mặc định nếu không có avatar
            ),
            const SizedBox(width: 10),
            Text(
              userName, // Hiển thị tên người dùng đang trò chuyện
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18, // Điều chỉnh font size cho phù hợp
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0079CF), // Xanh đậm
                Color(0xFF00FFDE), // Xanh nhạt
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        backgroundColor: Colors.transparent, // Đảm bảo AppBar trong suốt để gradient hiển thị
        elevation: 0, // Bỏ đổ bóng
        iconTheme: const IconThemeData(color: Colors.white), // Đổi màu icon quay lại thành trắng
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0079CF), // Xanh đậm ở trên
              Color(0xFF00FFDE), // Xanh nhạt dần ở dưới
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.4], // Điều chỉnh dừng màu để phần dưới là xanh nhạt/trong suốt hơn
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: const [
                  // Tin nhắn gửi đi (màu xanh nhạt)
                  Align(
                    alignment: Alignment.centerRight,
                    child: MessageBubble(
                      text: 'Chào anh',
                      time: '8:50',
                      isMe: true, // Tin nhắn của bạn
                    ),
                  ),
                  SizedBox(height: 10),
                  // Tin nhắn nhận được (màu xám nhạt)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: MessageBubble(
                      text: 'Chào bạn, có chuyện gì không?',
                      time: '8:52',
                      isMe: false, // Tin nhắn của người khác
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
                  // Thêm nhiều tin nhắn khác ở đây
                ],
              ),
            ),
            _buildInputBox(), // Hộp nhập tin nhắn
          ],
        ),
      ),
    );
  }

  Widget _buildInputBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white, // Nền trắng cho hộp nhập tin nhắn
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.grey),
            onPressed: () {
              // Xử lý khi nhấn biểu tượng camera
              debugPrint('Nhấn biểu tượng camera');
            },
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn ...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0), // Bo tròn góc
                  borderSide: BorderSide.none, // Bỏ viền
                ),
                filled: true,
                fillColor: const Color(0xFFF0F2F5), // Nền xám nhạt cho TextField
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.sentiment_satisfied_alt, color: Colors.grey),
            onPressed: () {
              // Xử lý khi nhấn biểu tượng cảm xúc
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
  final bool isMe; // true nếu là tin nhắn của mình, false nếu là của người khác

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