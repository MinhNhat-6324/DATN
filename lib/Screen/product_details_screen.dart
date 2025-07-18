import 'package:flutter/material.dart';
import 'report_form_screen.dart';
import 'package:front_end/model/bai_dang_service.dart';
import 'package:front_end/services/buildImage.dart';
import 'chat_detail_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final BaiDang baiDang;
  final int idNguoiBaoCao; // 👈 thêm dòng này

  const ProductDetailsScreen({
    super.key,
    required this.baiDang,
    required this.idNguoiBaoCao, // 👈 truyền vào
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? selectedImageUrl;
  List<BaiDang> BaiDangLienQuan = [];
  @override
  void initState() {
    super.initState();
    _loadBaiDangLienQuan();
  }

  void _loadBaiDangLienQuan() async {
    final list = await getBaiDangLienQuan(widget.baiDang.id);
    print("🔍 Số bài liên quan: ${list.length}");
    setState(() => BaiDangLienQuan = list);
  }

  @override
  Widget build(BuildContext context) {
    final baiDang = widget.baiDang;

    final size = MediaQuery.of(context).size;

    String imageUrl;
    if (selectedImageUrl != null && selectedImageUrl!.isNotEmpty) {
      imageUrl = selectedImageUrl!;
    } else if (baiDang.anhBaiDang.isNotEmpty) {
      imageUrl = buildImageUrl(baiDang.anhBaiDang[0].duongDan);
    } else {
      imageUrl = "https://via.placeholder.com/150";
    }

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0079CF), Color(0xFF00FFDE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAppBar(),
                _buildMainImage(imageUrl, size),
                SizedBox(height: size.height * 0.03),
                if (baiDang.anhBaiDang.isNotEmpty)
                  _buildImageGallery(baiDang, size),
                SizedBox(height: size.height * 0.01),
                _buildInfoCard(baiDang, size),
                SizedBox(height: size.height * 0.04),
                _buildContactButton(size),
                const SizedBox(height: 20),
                Divider(
                  thickness: 1,
                  color: Colors.white70,
                  indent: 16,
                  endIndent: 16,
                ),
                const SizedBox(height: 20),
                if (BaiDangLienQuan.isNotEmpty)
                  _buildRelatedSection(BaiDangLienQuan),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
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
            PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.report, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text('Báo cáo bài đăng này'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'report') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportFormScreen(
                    idBaiDang: widget.baiDang.id, // 👈 truyền id bài đăng
                    idNguoiBaoCao:
                        widget.idNguoiBaoCao, // 👈 truyền người báo cáo
                  ),
                ),
              );
            }
          },
        )
      ],
    );
  }

  Widget _buildMainImage(String imageUrl, Size size) {
    return Container(
      width: size.width * 0.6,
      height: size.width * 0.6 * (4 / 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.image, size: 80, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery(BaiDang baiDang, Size size) {
    if (baiDang.anhBaiDang.isEmpty)
      return const SizedBox(); // Ẩn nếu không có ảnh

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: baiDang.anhBaiDang.map((anh) {
            final url = buildImageUrl(anh.duongDan);
            return GestureDetector(
              onTap: () => setState(() => selectedImageUrl = url),
              child: _buildSmallImage(url),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BaiDang baiDang, Size size) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            baiDang.tieuDe,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: size.width * 0.05,
              color: const Color(0xFF0079CF),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 5,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildInfoChip(
                Icons.check_circle_outline,
                'Độ mới ${baiDang.doMoi}%',
                Colors.green,
              ),
              _buildInfoChip(
                Icons.category,
                baiDang.tenNganh ?? 'Chưa rõ ngành',
                Colors.blueGrey,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Hiển thị lớp chuyên ngành nếu idLoai == 1 và idNganh != 8
          if (baiDang.idLoai == 1 && baiDang.idNganh != 8) ...[
            Text(
              '${baiDang.lopChuyenNganh ?? '---'}',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 6),
          ],

// Hiển thị năm xuất bản nếu idLoai == 1
          if (baiDang.idLoai == 1) ...[
            Text(
              'Năm xuất bản: ${baiDang.namXuatBan?.toString() ?? '---'}',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmallImage(String imageUrl) {
    final isSelected = selectedImageUrl == imageUrl;
    return Container(
      width: 90,
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Center(child: Icon(Icons.broken_image)),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(Size size) {
    return ElevatedButton(
      onPressed: () {
        if (widget.baiDang.idTaiKhoan == widget.idNguoiBaoCao) {
          // 🛑 Hiển thị thông báo nếu người đăng là chính mình
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Thông báo'),
              content: const Text('Bài đăng này là của bạn.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          );
        } else {
          // ✅ Chuyển sang trang nhắn tin nếu là người khác
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDetailScreen(
                idBaiDang: widget.baiDang.id,
                idNguoiDang: widget.baiDang.idTaiKhoan,
                idNguoiHienTai: widget.idNguoiBaoCao,
              ),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0079CF), Color(0xFF00FFDE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          alignment: Alignment.center,
          width: size.width * 0.6,
          height: 50,
          child: const Text(
            'Liên hệ trực tiếp',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedSection(List<BaiDang> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Sản phẩm liên quan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 220, // 🔧 tăng chiều cao
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: items
                .take(4)
                .map((baiDang) => _bookItemLienQuan(context, baiDang))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _bookItemLienQuan(BuildContext context, BaiDang baiDang) {
    final imageUrl = baiDang.anhBaiDang.isNotEmpty
        ? buildImageUrl(baiDang.anhBaiDang[0].duongDan)
        : "https://via.placeholder.com/150";

    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(
              baiDang: baiDang,
              idNguoiBaoCao: widget.idNguoiBaoCao,
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.only(left: 16),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
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
            if (baiDang.idLoai == 1) ...[
              if (baiDang.idNganh != 8) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.school, size: 14, color: Colors.blueGrey),
                    const SizedBox(width: 4),
                    Text(
                      baiDang.lopChuyenNganh ?? '---',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              // Hiển thị năm trong mọi trường hợp khi idLoai == 1
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
