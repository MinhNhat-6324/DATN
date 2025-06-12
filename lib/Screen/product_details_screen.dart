import 'package:flutter/material.dart';
import 'report_form_screen.dart';
class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Toàn bộ màn hình có gradient nền
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0079CF), // Xanh đậm ở trên
              Color(0xFF00FFDE), // Xanh nhạt dần ở dưới
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.4],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // AppBar tùy chỉnh
              AppBar(
                backgroundColor: Colors.transparent, // Nền trong suốt
                elevation: 0, // Bỏ đổ bóng
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
                              builder: (context) => const ReportFormScreen()),
                        );
                      }
                    },
                  )
                ],
              ),
              // Hình ảnh sản phẩm chính
              Container(
                width: MediaQuery.of(context).size.width * 0.7, // Chiều rộng 70% màn hình
                height: MediaQuery.of(context).size.width * 0.7 * (4 / 3), // <--- Đã thay đổi tỷ lệ khung hình ở đây để thành khung dọc
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16), // Bo tròn góc lớn hơn
                  color: Colors.white, // Nền trắng cho khung ảnh
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Đổ bóng rõ hơn
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    'https://lib.caothang.edu.vn/book_images/16037.jpg', // Thay đổi bằng đường dẫn ảnh thực tế của bạn
                    fit: BoxFit.contain, // Giữ nguyên để ảnh nằm gọn trong khung
                    errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Icon(Icons.image, size: 80, color: Colors.grey)), // Icon lỗi nếu ảnh không tải được
                  ),
                ),
              ),
              const SizedBox(height: 24), // Tăng khoảng cách
              // Khu vực các ảnh nhỏ dạng thanh cuộn ngang
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4), // Padding hợp lý
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9), // Nền trắng trong suốt nhẹ
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade300, // Viền xám nhạt
                    width: 1,
                  ),
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
                    children: List.generate(
                      5, // Tăng số lượng ảnh mẫu để thấy hiệu ứng cuộn
                      (index) => buildSmallImage(
                          'https://lib.caothang.edu.vn/book_images/16037.jpg'), // Ảnh mẫu
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24), // Tăng khoảng cách
              // Khu vực thông tin sản phẩm
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20), // Tăng padding để nội dung thoáng hơn
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
                  crossAxisAlignment: CrossAxisAlignment.start, // Căn trái
                  children: [
                    const Text(
                      'Vật Lý Đại Cương',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22, // Tăng kích thước chữ
                        color: Color(0xFF0079CF), // Màu xanh đậm tương tự AppBar
                      ),
                    ),
                    const SizedBox(height: 12), // Khoảng cách nhỏ
                    const Text(
                      '15.000 VNĐ',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18, // Tăng kích thước chữ
                        fontWeight: FontWeight.bold, // In đậm giá
                      ),
                    ),
                    const SizedBox(height: 16), // Khoảng cách lớn hơn
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Căn đều 2 bên
                      children: [
                        _buildInfoChip(
                            Icons.check_circle_outline, 'Cũ 75%', Colors.green),
                        _buildInfoChip(
                            Icons.category, 'Sách/ Chung', Colors.blueGrey),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30), // Khoảng cách cuối cùng trước nút
              // Nút "Liên hệ trực tiếp"
              ElevatedButton(
                onPressed: () {
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero, // Đặt padding về 0 để gradient chiếm toàn bộ nút
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Bo tròn góc nút
                  ),
                  elevation: 5, // Đổ bóng cho nút
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0079CF),
                        Color(0xFF00FFDE),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width * 0.6, // Chiều rộng tương đối
                    height: 50, // Chiều cao cố định
                    child: const Text(
                      'Liên hệ trực tiếp',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18), // Tăng kích thước chữ
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Khoảng cách
              const Text(
                'Hoặc',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20), // Khoảng cách
              // Các icon liên hệ
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildContactIcon(Icons.phone_android, () {
                    // Gọi điện thoại
                    debugPrint('Gọi điện thoại');
                  }, 'Gọi điện'),
                  const SizedBox(width: 30),
                  _buildContactIcon(Icons.mail_outline, () {
                    // Gửi mail
                    debugPrint('Gửi email');
                  }, 'Gửi Email'),
                ],
              ),
              const SizedBox(height: 40), // Khoảng cách cuối cùng
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper cho các ảnh nhỏ trong thanh cuộn
  Widget buildSmallImage(String imageUrl) {
    return Container(
      width: 90, // Tăng kích thước ảnh nhỏ
      height: 120, // Tăng kích thước ảnh nhỏ (tỷ lệ 4:3 dọc)
      margin: const EdgeInsets.symmetric(horizontal: 6), // Giảm khoảng cách ngang
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Bo tròn góc
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // Đổ bóng nhẹ nhàng hơn
            blurRadius: 5,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10), // Bo tròn bên trong
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain, // Giữ nguyên để ảnh không bị cắt
          errorBuilder: (context, error, stackTrace) =>
              const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
        ),
      ),
    );
  }

  // Widget helper cho các chip thông tin (cũ/mới, danh mục)
  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), // Nền màu nhẹ
        borderRadius: BorderRadius.circular(20), // Bo tròn hình chip
        border: Border.all(color: color, width: 1), // Viền cùng màu
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

  // Widget helper cho các icon liên hệ
  Widget _buildContactIcon(IconData icon, VoidCallback onPressed, String label) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30), // Bo tròn cho hiệu ứng splash
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
            child: Icon(icon, color: Color(0xFF0079CF), size: 30), // Icon màu xanh đậm
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