import 'package:flutter/material.dart';
import 'post_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'product_details_screen.dart';
import 'package:front_end/services/bai_dang_service.dart';
import 'package:front_end/services/buildImage.dart';
import 'post_list_screen.dart';
import 'package:front_end/services/chuyen_nganh_service.dart';
import 'package:front_end/services/loai_san_pham_service.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0079CF), Color(0xFF00FFDE)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: currentIndex,
          children: [
            HomeTab(userId: widget.userId),
            const PostScreen(),
            const ChatScreen(),
            const ProfileScreen(),
          ],
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
}

class HomeTab extends StatefulWidget {
  final String userId;
  const HomeTab({super.key, required this.userId});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Future<List<BaiDang>> futureBaiDangNganh;
  late Future<List<Nganh>> futureDanhSachNganh;
  late Future<List<LoaiSanPham>> futureLoaiList;

  String selectedTenNganh = 'Công nghệ thông tin';
  int selectedIdNganh = 1;
  LoaiSanPham? selectedLoai;
  LoaiSanPham? selectedLoaiChung;

  List<BaiDang> dataChung = [];

  @override
  void initState() {
    super.initState();
    selectedLoaiChung = LoaiSanPham(id: -1, tenLoai: 'Tất cả');
    futureDanhSachNganh = getDanhSachNganh();
    futureLoaiList = getDanhSachLoai();
    _fetchBaiDangChung();
    _fetchBaiDangNganh();
  }

  void _fetchBaiDangChung() {
    getBaiDangTheoNganhVaLoai(6, selectedLoaiChung?.id ?? -1).then((data) {
      setState(() {
        dataChung = data;
      });
    });
  }

  void _fetchBaiDangNganh() {
    final loaiId = selectedLoai?.id ?? -1;
    futureBaiDangNganh = getBaiDangTheoNganhVaLoai(selectedIdNganh, loaiId);
  }

  void _chonNganh(Nganh nganh) {
    setState(() {
      selectedTenNganh = nganh.tenNganh;
      selectedIdNganh = nganh.id;
      selectedLoai = LoaiSanPham(id: -1, tenLoai: 'Tất cả');
      _fetchBaiDangNganh();
    });
  }

  void _chonLoai(LoaiSanPham loai) {
    setState(() {
      selectedLoai = loai;
      _fetchBaiDangNganh();
    });
  }

  void _chonLoaiChung(LoaiSanPham loai) {
    setState(() {
      selectedLoaiChung = loai;
      _fetchBaiDangChung();
    });
  }

  Widget _buildSearchBar(BuildContext context) {
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
            FutureBuilder<List<Nganh>>(
              future: futureDanhSachNganh,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return IconButton(
                    icon: const Icon(Icons.error, color: Colors.red),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Lỗi tải ngành: ${snapshot.error}")),
                      );
                    },
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("Không có ngành");
                }

                final nganhList =
                    snapshot.data!.where((nganh) => nganh.id != 6).toList();
                return PopupMenuButton<Nganh>(
                  icon: const Icon(Icons.list, color: Colors.blue),
                  onSelected: _chonNganh,
                  itemBuilder: (BuildContext context) {
                    return nganhList
                        .map((nganh) => PopupMenuItem<Nganh>(
                              value: nganh,
                              child: Text(nganh.tenNganh),
                            ))
                        .toList();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
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
                  items: dataChung.take(4).map((baiDang) {
                    final duongDan = baiDang.anhBaiDang.isNotEmpty
                        ? baiDang.anhBaiDang[0].duongDan
                        : '';
                    final imageUrl = buildImageUrl(duongDan).isNotEmpty
                        ? buildImageUrl(duongDan)
                        : "https://via.placeholder.com/150";
                    return _bookItem(context, baiDang, imageUrl);
                  }).toList(),
                  onLoaiSelected: _chonLoaiChung,
                  showPlaceholder: dataChung.isEmpty,
                  onViewMore: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostListScreen(
                          title: "Sách chung",
                          idNganh: 6,
                          idLoai: selectedLoaiChung?.id ?? -1,
                        ),
                      ),
                    );
                  },
                ),
                FutureBuilder<List<BaiDang>>(
                  future: futureBaiDangNganh,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text("Lỗi bài đăng: ${snapshot.error}"));
                    }

                    final baiDangNganh = snapshot.data?.take(4).toList() ?? [];

                    return _buildCategorySection(
                      context: context,
                      title: "Ngành $selectedTenNganh",
                      color: Colors.indigo,
                      items: baiDangNganh.map((baiDang) {
                        final duongDan = baiDang.anhBaiDang.isNotEmpty
                            ? baiDang.anhBaiDang[0].duongDan
                            : '';
                        final imageUrl = buildImageUrl(duongDan).isNotEmpty
                            ? buildImageUrl(duongDan)
                            : "https://via.placeholder.com/150";
                        return _bookItem(context, baiDang, imageUrl);
                      }).toList(),
                      onLoaiSelected: _chonLoai,
                      showPlaceholder: baiDangNganh.isEmpty,
                      onViewMore: () {
                        print(
                            "🔍 Xem thêm ngành: $selectedTenNganh | idNganh: $selectedIdNganh | idLoai: ${selectedLoai?.id ?? -1}");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostListScreen(
                              title: "Ngành $selectedTenNganh",
                              idNganh: selectedIdNganh,
                              idLoai: selectedLoai?.id ?? -1,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildCategorySection({
  required BuildContext context,
  required String title,
  required Color color,
  required List<Widget> items,
  Function(LoaiSanPham)? onLoaiSelected,
  bool showPlaceholder = false,
  VoidCallback? onViewMore,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FutureBuilder<List<LoaiSanPham>>(
                  future: getDanhSachLoai(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    final loaiList = [
                      LoaiSanPham(id: -1, tenLoai: 'Tất cả'),
                      ...snapshot.data!
                    ];

                    return PopupMenuButton<LoaiSanPham>(
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.white),
                      onSelected: onLoaiSelected,
                      itemBuilder: (context) => loaiList
                          .map((loai) => PopupMenuItem<LoaiSanPham>(
                                value: loai,
                                child: Text(loai.tenLoai),
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
            TextButton(
              onPressed: onViewMore,
              child: const Text("Xem thêm →",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      if (showPlaceholder)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              "Không có bài đăng nào trong mục này",
              style:
                  TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
            ),
          ),
        )
      else
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

Widget _bookItem(BuildContext context, BaiDang baiDang, String imageUrl) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsScreen(baiDang: baiDang),
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
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            baiDang.tieuDe,
            style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "${baiDang.gia} VND",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}
