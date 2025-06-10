import 'package:flutter/material.dart';

class MyPostScreen extends StatelessWidget {
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
        backgroundColor: const Color(0xFF00C3FF),
        centerTitle: true, // Thuộc tính này sẽ căn giữa tiêu đề
        title: const Text(
          'Bài đăng của tôi',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostCard(post: posts[index]);
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

class PostCard extends StatelessWidget {
  final Post post;

  PostCard({required this.post});

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
                    Text(post.title,
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    Text(post.price,
                        style: const TextStyle(color: Colors.black)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 6),
                        Text(post.status,
                            style: const TextStyle(color: Colors.black)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.black),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
