import 'package:flutter/material.dart';
import 'post_screen.dart';
import 'profile_screen.dart';
import 'product_details_screen.dart';
import 'package:front_end/model/bai_dang_service.dart';
import 'package:front_end/services/buildImage.dart';
import 'post_list_screen.dart';
import 'package:front_end/model/chuyen_nganh_service.dart';
import 'package:front_end/model/loai_san_pham_service.dart';
import 'package:front_end/model/sinh_vien.dart';

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
            PostScreen(userId: widget.userId),
            ProfileScreen(userId: widget.userId),
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

  String selectedTenNganh = '';

  int selectedIdNganh = 1;
  LoaiSanPham? selectedLoai;
  LoaiSanPham? selectedLoaiChung;

  List<BaiDang> dataChung = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureBaiDangNganh = Future.value([]);
    selectedLoaiChung = LoaiSanPham(id: -1, tenLoai: 'Tất cả');
    futureDanhSachNganh = getDanhSachNganh();
    futureLoaiList = getDanhSachLoai();

    _fetchBaiDangNganh();
    _fetchNganhTheoUser();
    _fetchBaiDangChung();
    print("Ngành được chọn: $selectedTenNganh");
  }

  Future<void> _fetchBaiDangChung() async {
    final data = await getBaiDangTheoNganhVaLoai(8, selectedLoaiChung?.id ?? -1,
        limit: 4);
    setState(() {
      dataChung = data;
    });
  }

  Future<void> _fetchBaiDangNganh() async {
    final loaiId = selectedLoai?.id ?? -1;
    final data =
        await getBaiDangTheoNganhVaLoai(selectedIdNganh, loaiId, limit: 4);
    setState(() {
      futureBaiDangNganh = Future.value(data);
    });
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _fetchBaiDangChung(),
      _fetchBaiDangNganh(),
    ]);
  }

  void _chonNganh(Nganh nganh) {
    setState(() {
      selectedTenNganh = nganh.tenNganh;
      selectedIdNganh = nganh.id;
      selectedLoai = LoaiSanPham(id: -1, tenLoai: 'Tất cả');
    });
    _fetchBaiDangNganh();
  }

  void _chonLoaiChung(LoaiSanPham loai) {
    setState(() => selectedLoaiChung = loai);
    _fetchBaiDangChung();
  }

  void _fetchNganhTheoUser() async {
    try {
      final userId = int.tryParse(widget.userId);
      if (userId == null) return;

      final sinhVien = await fetchSinhVienById(userId);

      final idChuyenNganh = sinhVien?.chuyenNganh;

      final dsNganh = await getDanhSachNganh();
      final nganh = dsNganh.firstWhere(
        (n) => n.id == idChuyenNganh,
        orElse: () => Nganh(id: idChuyenNganh ?? -1, tenNganh: "Không rõ"),
      );

      setState(() {
        selectedIdNganh = nganh.id;
        selectedTenNganh = nganh.tenNganh;
        selectedLoai = LoaiSanPham(id: -1, tenLoai: 'Tất cả');
      });

      _fetchBaiDangNganh();
    } catch (e) {
      print("Lỗi khi lấy ngành sinh viên: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Column(
        children: [
          _buildSearchBar(context, screenWidth),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
                children: [
                  _buildCategorySection(
                    context: context,
                    title: "Sách chung",
                    color: Colors.cyan,
                    screenWidth: screenWidth,
                    items: dataChung.take(4).map((baiDang) {
                      final duongDan = baiDang.anhBaiDang.isNotEmpty
                          ? baiDang.anhBaiDang[0].duongDan
                          : '';
                      final imageUrl = buildImageUrl(duongDan).isNotEmpty
                          ? buildImageUrl(duongDan)
                          : "https://via.placeholder.com/150";
                      return _bookItem(context, baiDang, imageUrl, screenWidth);
                    }).toList(),
                    onLoaiSelected: _chonLoaiChung,
                    showPlaceholder: dataChung.isEmpty,
                    onViewMore: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostListScreen(
                            title: "Sách chung",
                            idNganh: 8,
                            idLoai: selectedLoaiChung?.id ?? -1,
                            searchTieuDe: null,
                            userId: widget.userId,
                          ),
                        ),
                      );
                    },
                  ),
                  FutureBuilder<List<BaiDang>>(
                    future: futureBaiDangNganh,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox();
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text("Lỗi bài đăng: ${snapshot.error}"));
                      }

                      final baiDangNganh =
                          snapshot.data?.take(4).toList() ?? [];

                      return _buildCategorySection(
                        context: context,
                        title: selectedTenNganh.isEmpty
                            ? 'Chuyên ngành của bạn'
                            : selectedTenNganh,
                        color: Colors.indigo,
                        screenWidth: screenWidth,
                        items: baiDangNganh.map((baiDang) {
                          final duongDan = baiDang.anhBaiDang.isNotEmpty
                              ? baiDang.anhBaiDang[0].duongDan
                              : '';
                          final imageUrl = buildImageUrl(duongDan).isNotEmpty
                              ? buildImageUrl(duongDan)
                              : "https://via.placeholder.com/150";
                          return _bookItem(
                              context, baiDang, imageUrl, screenWidth);
                        }).toList(),
                        onLoaiSelected: _chonNganh,
                        showPlaceholder: baiDangNganh.isEmpty,
                        onViewMore: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostListScreen(
                                title: "Ngành $selectedTenNganh",
                                idNganh: selectedIdNganh,
                                idLoai: selectedLoai?.id ?? -1,
                                searchTieuDe: null,
                                userId: widget.userId,
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
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, double screenWidth) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) => _onSearch(), // <<< giống PostListScreen
                decoration: const InputDecoration(
                  hintText: "Nhập tên sách muốn tìm",
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.blue),
              onPressed: _onSearch, // <<< giống PostListScreen
            ),
          ],
        ),
      ),
    );
  }

  void _onSearch() {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) return;

    final isChung = selectedIdNganh == 8;
    final isTatCaNganh = selectedIdNganh == -1;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostListScreen(
          title: isTatCaNganh
              ? 'Tất cả chuyên ngành'
              : (isChung ? 'Sách chung' : 'Ngành $selectedTenNganh'),
          idNganh: isTatCaNganh ? -1 : selectedIdNganh,
          idLoai:
              isChung ? selectedLoaiChung?.id ?? -1 : selectedLoai?.id ?? -1,
          searchTieuDe: keyword,
          userId: widget.userId,
        ),
      ),
    );
  }

  Widget _bookItem(BuildContext context, BaiDang baiDang, String imageUrl,
      double screenWidth) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              baiDang: baiDang,
              idNguoiBaoCao: int.parse(widget.userId),
            ),
          ),
        );
      },
      child: Container(
        width: screenWidth * 0.5,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  // Điều chỉnh để ảnh hiển thị lớn hơn và chứa toàn bộ ảnh
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit
                        .contain, // Thay đổi từ BoxFit.cover sang BoxFit.contain
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                baiDang.tieuDe,
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, size: 14, color: Colors.blueGrey),
                const SizedBox(width: 4),
                Text(
                  "${baiDang.lopChuyenNganh ?? 'Không rõ'}",
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today,
                    size: 14, color: Colors.blueGrey),
                const SizedBox(width: 4),
                Text(
                  "Năm: ${baiDang.namXuatBan?.toString() ?? '---'}",
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection({
    required BuildContext context,
    required String title,
    required Color color,
    required List<Widget> items,
    required double screenWidth,
    required Function onLoaiSelected,
    bool showPlaceholder = false,
    VoidCallback? onViewMore,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
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
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
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
                style: TextStyle(
                    color: Colors.white70, fontStyle: FontStyle.italic),
              ),
            ),
          )
        else
          SizedBox(
            height: 240,
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
}
