import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:front_end/services/bai_dang_service.dart';
import 'package:front_end/services/buildImage.dart';
import 'package:front_end/services/chuyen_nganh_service.dart';
import 'package:front_end/services/loai_san_pham_service.dart';
import 'product_details_screen.dart';

class PostListScreen extends StatefulWidget {
  final String title;
  final int idNganh;
  final int? idLoai; // 👈 Thêm loại sản phẩm

  const PostListScreen({
    super.key,
    required this.title,
    required this.idNganh,
    this.idLoai,
  });

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  late Future<List<BaiDang>> futureBaiDang;

  @override
  void initState() {
    super.initState();
    futureBaiDang = getBaiDangTheoNganhVaLoai(
        widget.idNganh, widget.idLoai); // 👈 Gọi API theo ngành và loại
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.cyan,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    child: const Text(
                      "Sản phẩm liên quan",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<List<BaiDang>>(
                  future: futureBaiDang,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Lỗi: \${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Không có bài đăng.'));
                    }

                    final baiDangList = snapshot.data!;

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        itemCount: baiDangList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.6,
                        ),
                        itemBuilder: (context, index) {
                          final baiDang = baiDangList[index];
                          final duongDan = baiDang.anhBaiDang.isNotEmpty
                              ? baiDang.anhBaiDang[0].duongDan
                              : '';
                          final imageUrl = buildImageUrl(duongDan).isNotEmpty
                              ? buildImageUrl(duongDan)
                              : "https://via.placeholder.com/150";

                          return _buildItem(context, baiDang, imageUrl);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) {
            Navigator.pop(context);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF0065F8),
          selectedItemColor: const Color(0xFF00CAFF),
          unselectedItemColor: const Color(0xFF00CAFF),
          selectedLabelStyle: const TextStyle(color: Colors.white),
          unselectedLabelStyle: const TextStyle(color: Colors.white),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_box), label: 'Đăng bài'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Tin nhắn'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: 'Tài khoản'),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: const [
            Icon(Icons.search, color: Colors.blue),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Nhập tên sách muốn tìm",
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, BaiDang baiDang, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(baiDang: baiDang),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE6F2FF), Color.fromARGB(255, 247, 237, 220)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade100, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      baiDang.tenNganh ?? "Chưa rõ ngành",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      baiDang.tieuDe,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${baiDang.gia} VND",
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
