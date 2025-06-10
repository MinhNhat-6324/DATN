import 'package:flutter/material.dart';

class Chitietsanphamscreen extends StatelessWidget {
  const Chitietsanphamscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 106, 173),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
              PopupMenuItem(value: 'delete', child: Text('Xóa')),
            ],
            onSelected: (value) {},
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            width: 120, // Chiều rộng ảnh thu nhỏ
            height: 180, // Chiều cao ảnh thu nhỏ
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 40, 33, 240),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const Image(
                image: AssetImage('images/logo.png'),
                //height: 250,
                //width: 250,
              ),
            ),
          ),
          const SizedBox(height: 26),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50, // Màu nền xanh nhẹ
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white, // Viền trắng quanh khung
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildSmallImage(
                    'https://lib.caothang.edu.vn/book_images/16037.jpg'),
                buildSmallImage(
                    'https://lib.caothang.edu.vn/book_images/16037.jpg'),
                buildSmallImage(
                    'https://lib.caothang.edu.vn/book_images/16037.jpg'),
                buildSmallImage(
                    'https://lib.caothang.edu.vn/book_images/16037.jpg'),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: const [
                Text(
                  'Vật Lý Đại Cương',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '15.000 VNĐ',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Cũ 75%',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('Sách/ Chung',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C6FF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {},
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Liên hệ trực tiếp'),
          ),
          const SizedBox(height: 12),
          const Text('Hoặc', style: TextStyle(color: Colors.white)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.phone_android, color: Colors.white),
              ),
              const SizedBox(width: 20),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.mail_outline, color: Colors.white),
              ),
            ],
          )
        ],
      ),
    );
  }
}

Widget buildSmallImage(String imageUrl) {
  return Container(
    width: 80,
    height: 110,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: Colors.white, // màu nền cho viền
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: Colors.grey.shade300, // màu viền
        width: 2, // độ dày viền
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: Offset(0, 2),
        )
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
      ),
    ),
  );
}
