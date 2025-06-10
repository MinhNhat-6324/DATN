import 'package:flutter/material.dart';
import 'post_screen.dart';
import 'chat_green.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> screens = [
    HomeTab(),
    PostScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00C6FF),
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0065F8),
        selectedItemColor: const Color(0xFF00CAFF),
        unselectedItemColor: const Color(0xFF00CAFF),
        selectedLabelStyle: const TextStyle(color: Colors.white),
        unselectedLabelStyle: const TextStyle(color: Colors.white),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Đăng bài'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Tin nhắn'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              _buildCategorySection(
                title: "Sách chung",
                color: Colors.cyan,
                items: List.generate(
                  5,
                  (_) => _bookItem(
                    "Vật lý đại cương",
                    "15.000 VND",
                    "https://lib.caothang.edu.vn/book_images/16037.jpg",
                  ),
                ),
              ),
              _buildCategorySection(
                title: "Công nghệ Oto",
                color: Colors.lightBlue,
                items: List.generate(
                  5,
                  (_) => _bookItem(
                    "Thực tập ô tô 2",
                    "15.000 VND",
                    "https://lib.caothang.edu.vn/book_images/34004.jpg",
                  ),
                ),
              ),
              _buildCategorySection(
                title: "Công nghệ thông tin",
                color: Colors.teal,
                items: List.generate(
                  5,
                  (_) => _bookItem(
                    "C++ cơ bản",
                    "20.000 VND",
                    "https://images.unsplash.com/photo-1517433456452-f9633a875f6f",
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.blue),
            const SizedBox(width: 8),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Nhập tên sách muốn tìm",
                  border: InputBorder.none,
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.list, color: Colors.blue),
              onSelected: (value) {
                print('Danh mục được chọn: $value');
                // Gọi setState và lọc dữ liệu ở đây nếu cần
              },
              itemBuilder: (BuildContext context) => const [
                PopupMenuItem<String>(
                  value: 'Tất cả',
                  child: Text('Tất cả'),
                ),
                PopupMenuItem<String>(
                  value: 'CN Oto',
                  child: Text('CN Oto'),
                ),
                PopupMenuItem<String>(
                  value: 'CNTT',
                  child: Text('CNTT'),
                ),
                PopupMenuItem<String>(
                  value: 'Cơ Khí',
                  child: Text('Cơ Khí'),
                ),
                PopupMenuItem<String>(
                  value: 'Kế toán',
                  child: Text('Kế toán'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildCategorySection({
    required String title,
    required Color color,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text("Xem thêm →",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: items
                .map((e) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: e,
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  static Widget _bookItem(String title, String price, String imageUrl) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            price,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
