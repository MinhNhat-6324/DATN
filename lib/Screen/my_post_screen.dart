import 'package:flutter/material.dart';
import 'update_post_screen.dart';
class MyPostScreen extends StatelessWidget {
  final List<Post> posts = [
    Post(
      title: 'Vật lý đại cương - Cơ nhiệt',
      price: '15,000 VNĐ',
      status: 'Sẵn sàng',
      imageUrl: 'https://lib.caothang.edu.vn/book_images/16037.jpg', // Ví dụ ảnh sách
    ),
    Post(
      title: 'Vật lý đại cương - Cơ nhiệt',
      price: '15,000 VNĐ',
      status: 'Đang giao dịch',
      imageUrl: 'https://lib.caothang.edu.vn/book_images/16037.jpg', // Ví dụ ảnh điện thoại
    ),
    Post(
      title: 'Vật lý đại cương - Cơ nhiệt',
      price: '15,000 VNĐ',
      status: 'Hoàn thành',
      imageUrl: 'https://lib.caothang.edu.vn/book_images/16037.jpg', // Ví dụ ảnh bàn phím
    ),
    Post(
      title: 'Vật lý đại cương - Cơ nhiệt',
      price: '15,000 VNĐ',
      status: 'Hoàn thành',
      imageUrl: 'https://lib.caothang.edu.vn/book_images/16037.jpg', // Ví dụ ảnh truyện tranh
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Nền xám nhạt cho toàn bộ màn hình
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Bài viết của tôi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        // Thêm nút quay lại
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Icon mũi tên quay lại màu trắng
          onPressed: () {
            // Kiểm tra xem có thể pop route hiện tại không
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop(); // Quay lại màn hình trước đó
            } else {
              // Xử lý nếu không có màn hình nào để quay lại (ví dụ: đây là màn hình gốc)
              // Có thể chuyển hướng đến màn hình chính hoặc đơn giản là không làm gì.
              print('Không có màn hình nào để quay lại.');
            }
          },
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0), // Padding tổng thể cho ListView
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostCard(post: posts[index]);
          },
        ),
      ),
    );
  }
}

class Post {
  final String title;
  final String price;
  final String status;
  final String imageUrl;

  Post({
    required this.title,
    required this.price,
    required this.status,
    required this.imageUrl,
  });
}

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Sẵn sàng':
        return Colors.green.shade600;
      case 'Đang giao dịch':
        return Colors.orange.shade700;
      case 'Hoàn thành':
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  // Helper method to get status icon
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Sẵn sàng':
        return Icons.check_circle;
      case 'Đang giao dịch':
        return Icons.compare_arrows;
      case 'Hoàn thành':
        return Icons.done_all;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(post.status);
    final statusIcon = _getStatusIcon(post.status);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Khoảng cách giữa các card
      color: Colors.white, // Nền card màu trắng
      elevation: 4, // Thêm đổ bóng
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Bo tròn góc card
      ),
      child: Container( // Thêm Container bao quanh Card để đặt màu nền riêng cho phần nội dung Card
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9), // Màu nền nhẹ nhàng cho từng bài viết
          borderRadius: BorderRadius.circular(12), // Đảm bảo bo tròn góc khớp với Card
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Padding bên trong card
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phần ảnh
              ClipRRect(
                borderRadius: BorderRadius.circular(8), // Bo tròn góc ảnh
                child: Image.network(
                  post.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image, color: Colors.grey[400], size: 40),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Phần thông tin bài viết
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.price,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          post.status,
                          style: TextStyle(color: statusColor, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Nút cài đặt (PopupMenuButton)
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    onSelected: (String value) {
                      print('Bạn đã chọn: $value cho bài viết ${post.title}');
                      if (value == 'edit') {
                          Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const UpdatePostScreen()),
                      );
                      } else if (value == 'delete') {
                        // Logic xóa
                      } else if (value == 'change_status') {
                        // Logic thay đổi trạng thái
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Color(0xFF0079CF)),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'change_status',
                        child: Row(
                          children: [
                            Icon(Icons.published_with_changes, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('Đổi trạng thái'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa bài viết'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}