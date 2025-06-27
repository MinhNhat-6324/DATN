import 'package:flutter/material.dart';
import 'report_form_screen.dart';
import 'package:front_end/services/bai_dang_service.dart';
import 'package:front_end/services/buildImage.dart';

class ProductDetailsScreen extends StatefulWidget {
  final BaiDang baiDang;
  const ProductDetailsScreen({super.key, required this.baiDang});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? selectedImageUrl;

  @override
  Widget build(BuildContext context) {
    final baiDang = widget.baiDang;
    final defaultImage = baiDang.anhBaiDang.isNotEmpty
        ? buildImageUrl(baiDang.anhBaiDang[0].duongDan)
        : "https://via.placeholder.com/150";
    final imageUrl = selectedImageUrl ?? defaultImage;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0079CF), // Xanh đậm
              Color(0xFF00FFDE), // Xanh nhạt
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppBar(
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
                            builder: (context) => const ReportFormScreen(),
                          ),
                        );
                      }
                    },
                  )
                ],
              ),
              // ẢNH CHÍNH
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.width * 0.7 * (4 / 3),
                margin: const EdgeInsets.symmetric(horizontal: 16),
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
                        child: Icon(Icons.image, size: 80, color: Colors.grey)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // DANH SÁCH ẢNH
              Container(
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
                        onTap: () {
                          setState(() {
                            selectedImageUrl = url;
                          });
                        },
                        child: buildSmallImage(url),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // THÔNG TIN SẢN PHẨM
              Container(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            baiDang.tieuDe,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color(0xFF0079CF),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${baiDang.gia} VNĐ',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoChip(Icons.check_circle_outline,
                            'Độ mới ${baiDang.doMoi}%', Colors.green),
                        _buildInfoChip(Icons.category, '${baiDang.tenNganh}',
                            Colors.blueGrey),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // NÚT LIÊN HỆ
              ElevatedButton(
                onPressed: () {},
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
                    width: MediaQuery.of(context).size.width * 0.6,
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
              ),
              const SizedBox(height: 20),
              const Text(
                'Hoặc',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildContactIcon(Icons.phone_android, () {
                    debugPrint('Gọi điện thoại');
                  }, 'Gọi điện'),
                  const SizedBox(width: 30),
                  _buildContactIcon(Icons.mail_outline, () {
                    debugPrint('Gửi email');
                  }, 'Gửi Email'),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSmallImage(String imageUrl) {
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
              const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactIcon(
      IconData icon, VoidCallback onPressed, String label) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF0079CF), size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
