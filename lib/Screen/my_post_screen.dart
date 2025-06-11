import 'package:flutter/material.dart';
import 'update_post_screen.dart';

class MyPostScreen extends StatefulWidget {
  const MyPostScreen({super.key});

  @override
  State<MyPostScreen> createState() => _MyPostScreenState();
}

class _MyPostScreenState extends State<MyPostScreen> {
  final List<Post> posts = [
    Post(title: 'Vật lý đại cương', price: '15,000 VNĐ', status: 'Sẵn sàng'),
    Post(
        title: 'Vật lý đại cương',
        price: '15,000 VNĐ',
        status: 'Đang giao dịch'),
    Post(title: 'Vật lý đại cương', price: '15,000 VNĐ', status: 'Hoàn thành'),
    Post(title: 'Vật lý đại cương', price: '15,000 VNĐ', status: 'Hoàn thành'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Bài đăng của tôi',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0079CF), Color(0xFF00FFDE)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostCard(
            post: posts[index],
            onEdit: () async {
              // Đây là nơi bạn có thể nhận dữ liệu đã chỉnh sửa nếu muốn
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdatePostScreen(),
                ),
              );
              setState(() {}); // Làm mới nếu cần cập nhật UI
            },
          );
        },
      ),
    );
  }
}

class Post {
  final String title;
  final String price;
  final String status;

  Post({required this.title, required this.price, required this.status});
}

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onEdit;

  const PostCard({super.key, required this.post, required this.onEdit});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      color: const Color(0xFFF6F1E9),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              width: 120,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset('images/logo.png', fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 140,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 151, 230, 239),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.post.title,
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    Text(widget.post.price,
                        style: const TextStyle(color: Colors.black)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 6),
                        Text(widget.post.status,
                            style: const TextStyle(color: Colors.black)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.settings, color: Colors.black),
              onSelected: (value) {
                if (value == 'edit') {
                  widget.onEdit();
                } else if (value == 'in_progress') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đang giao dịch...')),
                  );
                } else if (value == 'delete') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xoá bài viết')),
                  );
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Chỉnh sửa'),
                ),
                const PopupMenuItem<String>(
                  value: 'in_progress',
                  child: Text('Đang giao dịch'),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Xoá'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
