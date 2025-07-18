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
  late String selectedNganhName;
  @override
  void initState() {
    super.initState();
    selectedIdNganh = widget.idNganh;
    selectedIdLoai = widget.idLoai ?? -1;
    selectedNganhName = widget.title; // ban đầu
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
    final screenWidth = MediaQuery.of(context).size.width;
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
              // Lọc chuyên ngành
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
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
                            setState(() {
                              selectedIdNganh = nganh.id;
                              selectedNganhName = nganh.tenNganh;
                            });
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
                      child: Text(
                        selectedNganhName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Lọc ngành
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft, // <-- canh lề trái
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.cyan, width: 1),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // <-- chỉ vừa nội dung
                      children: [
                        FutureBuilder<List<LoaiSanPham>>(
                          future: getDanhSachLoai(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox();
                            final loaiList = [
                              LoaiSanPham(id: -1, tenLoai: 'Tất cả'),
                              ...snapshot.data!,
                            ];
                            return PopupMenuButton<LoaiSanPham>(
                              onSelected: (loai) {
                                setState(() {
                                  selectedIdLoai = loai.id;
                                });
                                _onSearch();
                              },
                              color: Colors.white,
                              itemBuilder: (context) => loaiList
                                  .map((loai) => PopupMenuItem<LoaiSanPham>(
                                        value: loai,
                                        child: Text(loai.tenLoai),
                                      ))
                                  .toList(),
                              child: Row(
                                mainAxisSize:
                                    MainAxisSize.min, // <-- vừa icon + text
                                children: [
                                  Text(
                                    selectedIdLoai == -1
                                        ? "Tất cả loại"
                                        : loaiList
                                            .firstWhere(
                                              (l) => l.id == selectedIdLoai,
                                              orElse: () => LoaiSanPham(
                                                  id: -1, tenLoai: 'Tất cả'),
                                            )
                                            .tenLoai,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down,
                                      color: Colors.white),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Danh sách bài đăng
              Expanded(
                child: FutureBuilder<List<BaiDang>>(
                  future: futureBaiDang,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Lỗi: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Không có bài đăng.'));
                    }

                    final baiDangList = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        itemCount: baiDangList.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              MediaQuery.of(context).size.width > 600 ? 3 : 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio:
                              MediaQuery.of(context).size.width > 600
                                  ? 0.75
                                  : 0.6,
                        ),
                        itemBuilder: (context, index) {
                          final baiDang = baiDangList[index];
                          final duongDan = baiDang.anhBaiDang.isNotEmpty
                              ? baiDang.anhBaiDang[0].duongDan
                              : '';
                          final imageUrl = buildImageUrl(duongDan).isNotEmpty
                              ? buildImageUrl(duongDan)
                              : "https://via.placeholder.com/150";

                          return _bookItem(
                              context, baiDang, imageUrl, screenWidth);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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

  Widget _bookItem(BuildContext context, BaiDang baiDang, String imageUrl,
      double screenWidth) {
            final chiHienTieuDeVaAnh = baiDang.idLoai != 1;
    final laBaiDangChung = baiDang.idNganh == 8;
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
        width: screenWidth * 0.35,
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
                  child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                      ),
                    )
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
            if (!chiHienTieuDeVaAnh && !laBaiDangChung) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school, size: 14, color: Colors.blueGrey),
                  const SizedBox(width: 4),
                  Text(
                    baiDang.lopChuyenNganh ?? 'Không rõ',
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
            if (!chiHienTieuDeVaAnh) ...[
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
          ],
        ),
      ),
    );
  }
}
