import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:front_end/model/bai_dang_service.dart';
import 'package:front_end/services/buildImage.dart';
import 'package:front_end/model/chuyen_nganh_service.dart';
import 'package:front_end/model/loai_san_pham_service.dart';
import 'product_details_screen.dart';

class PostListScreen extends StatefulWidget {
  final String title;
  final int idNganh;
  final int? idLoai;
  final String? searchTieuDe;
  final String userId; // ✅ Thêm dòng này

  const PostListScreen({
    super.key,
    required this.title,
    required this.idNganh,
    this.idLoai,
    this.searchTieuDe,
    required this.userId, // ✅ Thêm dòng này
  });

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  late Future<List<BaiDang>> futureBaiDang;
  final TextEditingController _searchController = TextEditingController();

  late int selectedIdNganh;
  int? selectedIdLoai;
  String? searchTieuDe;

  @override
  void initState() {
    super.initState();
    selectedIdNganh = widget.idNganh;
    selectedIdLoai = widget.idLoai ?? -1; // luôn đảm bảo có giá trị
    searchTieuDe = widget.searchTieuDe;
    _searchController.text = widget.searchTieuDe ?? '';

    final hasSearch = searchTieuDe != null && searchTieuDe!.trim().isNotEmpty;

    if (hasSearch) {
      futureBaiDang = getBaiDangTheoNganhLoaiTieuDe(
        selectedIdNganh,
        selectedIdLoai ?? -1,
        searchTieuDe!,
      );
    } else {
      _loadFilteredBaiDang();
    }
  }

  void _loadFilteredBaiDang() {
    setState(() {
      final hasSearch = searchTieuDe != null && searchTieuDe!.trim().isNotEmpty;
      if (hasSearch) {
        futureBaiDang = getBaiDangTheoNganhLoaiTieuDe(
          selectedIdNganh,
          selectedIdLoai ?? -1,
          searchTieuDe!.trim(),
        );
      } else {
        futureBaiDang = getBaiDangTheoNganhVaLoai(
          selectedIdNganh,
          selectedIdLoai ?? -1,
        );
      }
    });
  }

  void _onSearch() {
    searchTieuDe = _searchController.text.trim();
    final hasTitle = searchTieuDe != null && searchTieuDe!.isNotEmpty;
    final hasLoai = selectedIdLoai != null && selectedIdLoai != -1;
    final hasNganh = selectedIdNganh != -1;

    setState(() {
      if (hasTitle) {
        if (!hasLoai && !hasNganh) {
          futureBaiDang = getBaiDangTheoTieuDe(searchTieuDe!);
        } else if (hasLoai && !hasNganh) {
          futureBaiDang = getBaiDangTheoLoaiVaTieuDe(
            selectedIdLoai!,
            searchTieuDe!,
          );
        } else if (hasLoai && hasNganh) {
          futureBaiDang = getBaiDangTheoNganhLoaiTieuDe(
            selectedIdNganh,
            selectedIdLoai!,
            searchTieuDe!,
          );
        } else if (!hasLoai && hasNganh) {
          futureBaiDang = getBaiDangTheoNganhLoaiTieuDe(
            selectedIdNganh,
            -1,
            searchTieuDe!,
          );
        }
      } else {
        if (!hasLoai && !hasNganh) {
          futureBaiDang = getTatCaBaiDang();
        } else if (hasLoai && !hasNganh) {
          futureBaiDang = getBaiDangTheoLoai(selectedIdLoai!);
        } else {
          futureBaiDang = getBaiDangTheoNganhVaLoai(
            selectedIdNganh,
            selectedIdLoai ?? -1,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
        body: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    FutureBuilder<List<Nganh>>(
                      future: getDanhSachNganh(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        final nganhList = snapshot.data!;
                        return PopupMenuButton<Nganh>(
                          icon: const Icon(Icons.list, color: Colors.white),
                          onSelected: (nganh) {
                            selectedIdNganh = nganh.id;
                            _onSearch();
                          },
                          itemBuilder: (context) => nganhList
                              .map((nganh) => PopupMenuItem<Nganh>(
                                    value: nganh,
                                    child: Text(nganh.tenNganh),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.cyan,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Sản phẩm liên quan",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // PopupMenu ngành (chuyển vào đây)
                  ],
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
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: size.width > 600 ? 3 : 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: size.width > 600 ? 0.75 : 0.6,
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
            // BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Tin nhắn'),
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
          children: [
            // PopupMenu Loại sản phẩm (ở bên trái search bar)
            FutureBuilder<List<LoaiSanPham>>(
              future: getDanhSachLoai(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final loaiList = [
                  LoaiSanPham(id: -1, tenLoai: 'Tất cả'),
                  ...snapshot.data!,
                ];
                return PopupMenuButton<LoaiSanPham>(
                  icon: const Icon(Icons.category, color: Colors.blue),
                  onSelected: (loai) {
                    selectedIdLoai = loai.id;
                    _onSearch();
                  },
                  itemBuilder: (context) => loaiList
                      .map((loai) => PopupMenuItem<LoaiSanPham>(
                            value: loai,
                            child: Text(loai.tenLoai),
                          ))
                      .toList(),
                );
              },
            ),

            const SizedBox(width: 8),

            // TextField tìm kiếm
            Expanded(
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) => _onSearch(),
                decoration: const InputDecoration(
                  hintText: "Nhập tên sách muốn tìm",
                  border: InputBorder.none,
                ),
              ),
            ),

            // Nút tìm
            InkWell(
              onTap: _onSearch,
              child: const Icon(Icons.search, color: Colors.blue),
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
              builder: (context) => ProductDetailsScreen(
                baiDang: baiDang,
                idNguoiBaoCao:
                    int.parse(widget.userId), // ✅ truyền vào từ widget.userId
              ),
            ),
          );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final fontSizeBase = constraints.maxWidth * 0.07;
            final fontSizePrice = fontSizeBase * 0.9;

            return Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE6F2FF), Color(0xFFF7EDDC)],
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
                  // Hình ảnh cao hơn
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      imageUrl,
                      height: constraints.maxHeight * 0.5,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 48),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Text bên dưới (dùng Expanded để không tràn)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            baiDang.tenNganh ?? "Chưa rõ ngành",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSizeBase,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            baiDang.tieuDe,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSizeBase + 2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${baiDang.gia} VND",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade700,
                              fontSize: fontSizePrice,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
