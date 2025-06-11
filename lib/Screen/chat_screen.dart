import 'package:flutter/material.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E9), // Nền xám nhạt cho toàn bộ màn hình
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Tin nhắn', // Đổi tiêu đề AppBar
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
        backgroundColor: Colors.transparent, // Đảm bảo background là trong suốt để gradient hiển thị
        elevation: 0, // Bỏ đổ bóng của AppBar
      ),
      body: ListView(
        children: [
          _buildChatItem(
            context,
            userName: 'Nguyễn Vũ Minh Nhật',
            lastMessage: 'Chào anh.',
            avatarAsset: 'https://cdn-icons-png.flaticon.com/512/4140/4140037.png',
          ),
          _buildChatItem(
            context,
            userName: 'Hỷ Châu Quang Phúc',
            lastMessage: 'Hello bạn.',
            avatarAsset: 'https://cdn-icons-png.flaticon.com/512/4140/4140037.png',
          ),
          // Thêm các _buildChatItem khác nếu có
        ],
      ),
    );
  }

  Widget _buildChatItem(
    BuildContext context, {
    required String userName,
    required String lastMessage,
    required String avatarAsset,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(userName: userName),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.white, // Nền trắng cho mỗi item
          borderRadius: BorderRadius.circular(12), // Bo tròn góc
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2), // Đổ bóng nhẹ
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28, // Kích thước avatar
                  backgroundColor: Colors.grey[200], // Màu nền avatar nếu ảnh không tải
                  backgroundImage: NetworkImage(avatarAsset), // Sử dụng AssetImage
                  onBackgroundImageError: (exception, stackTrace) {
                    debugPrint('Lỗi tải ảnh avatar: $exception');
                    // Fallback to a default icon or blank avatar
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333), // Màu chữ đậm hơn
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lastMessage,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}