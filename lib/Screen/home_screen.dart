import 'package:flutter/material.dart';
import 'timKiemSanPhamScreen.dart';
import 'post_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'chiTietSanPhamScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const HomeTab(),
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
        _buildSearchBar(context),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              _buildCategorySection(
                context: context,
                title: "Sách chung",
                color: Colors.cyan,
                items: List.generate(
                  5,
                  (_) => _bookItem(
                    context,
                    "Vật lý đại cương",
                    "15.000 VND",
                    "https://lib.caothang.edu.vn/book_images/16037.jpg",
                  ),
                ),
              ),
              _buildCategorySection(
                context: context,
                title: "Công nghệ Oto",
                color: Colors.lightBlue,
                items: List.generate(
                  5,
                  (_) => _bookItem(
                    context,
                    "Thực tập ô tô 2",
                    "15.000 VND",
                    "https://lib.caothang.edu.vn/book_images/34004.jpg",
                  ),
                ),
              ),
              _buildCategorySection(
                context: context,
                title: "Công nghệ thông tin",
                color: Colors.teal,
                items: List.generate(
                  5,
                  (_) => _bookItem(
                    context,
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

  static Widget _buildSearchBar(BuildContext context) {
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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const TimKiemSanPhamScreen(title: "Tìm kiếm"),
                  ),
                );
              },
              child: const Icon(Icons.search, color: Colors.blue),
            ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TimKiemSanPhamScreen(title: value),
                  ),
                );
              },
              itemBuilder: (BuildContext context) => const [
                PopupMenuItem<String>(value: 'Tất cả', child: Text('Tất cả')),
                PopupMenuItem<String>(value: 'CN Oto', child: Text('CN Oto')),
                PopupMenuItem<String>(value: 'CNTT', child: Text('CNTT')),
                PopupMenuItem<String>(value: 'Cơ Khí', child: Text('Cơ Khí')),
                PopupMenuItem<String>(value: 'Kế toán', child: Text('Kế toán')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildCategorySection({
    required BuildContext context,
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimKiemSanPhamScreen(title: title),
                    ),
                  );
                },
                child: const Text(
                  "Xem thêm →",
                  style: TextStyle(color: Colors.white),
                ),
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

  static Widget _bookItem(
    BuildContext context,
    String title,
    String price,
    String imageUrl,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Chitietsanphamscreen(),
          ),
        );
      },
      child: Container(
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
      ),
    );
  }
}
