import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> books = List.generate(
    3,
    (index) => {
      "title": "Vật lý đại cương",
      "price": "15.000 VND",
      "image": "images/sach.jpg", // Thay bằng ảnh thực tế nếu có
    },
  );

  final List<Map<String, String>> otoBooks = List.generate(
    3,
    (index) => {
      "title": "Thực tập ô tô 2",
      "price": "15.000 VND",
      "image": "images/sach.jpg", // Thay bằng ảnh thực tế nếu có
    },
  );

  Widget _buildBookCard(Map<String, String> book) {
    return Container(
      width: 230,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 228, 228, 202), // Nền trắng
        borderRadius: BorderRadius.circular(12), // Bo góc
        boxShadow: [
          BoxShadow(
            color: Colors.black12, // Bóng mờ
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(18), // Khoảng cách bên trong
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8), // Bo góc ảnh
            child: Image.asset(
              book["image"]!,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 8),
          Text(
            book["title"]!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 28),
          Text(
            book["price"]!,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Map<String, String>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                  label: Text(title, style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.blue),
              Text("Xem thêm →", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        Container(
          height: 380,
          padding: EdgeInsets.only(left: 16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: items.map(_buildBookCard).toList(),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 74, 138, 192),
      body: Center(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, 20, 16, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0D47A1), // Xanh đậm (trên)
                    Color(0xFF42A5F5), // Xanh nhạt (dưới)
                  ],
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Nhập tên sách muốn tìm',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                    Icon(Icons.view_list, color: Colors.blue),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSection("Sách chung", books),
                    Divider(
                        color: Colors.white70,
                        thickness: 1,
                        indent: 16,
                        endIndent: 16),
                    _buildSection("Công nghệ Ôtô", otoBooks),
                    Divider(
                        color: Colors.white70,
                        thickness: 1,
                        indent: 16,
                        endIndent: 16),
                    _buildSection("Công nghệ thông tin", books),
                    Divider(
                        color: Colors.white70,
                        thickness: 1,
                        indent: 16,
                        endIndent: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Giữ màu nền cố định
        selectedItemColor:
            const Color.fromARGB(255, 12, 12, 209), // Màu icon khi chọn
        unselectedItemColor:
            const Color.fromARGB(255, 12, 12, 209), // Màu icon khi chọn
        backgroundColor:
            const Color.fromARGB(255, 57, 117, 237), // Nền luôn luôn xanh lá
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(
              icon: Icon(Icons.post_add), label: "Đăng bài"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Tin nhắn"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: "Tài khoản"),
        ],
      ),
    );
  }
}
