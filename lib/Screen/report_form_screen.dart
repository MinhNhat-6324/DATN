import 'package:flutter/material.dart';
import 'package:front_end/services/bao_cao.dart'; // Đảm bảo file đúng tên

class ReportFormScreen extends StatefulWidget {
  final int idBaiDang;
  final int idNguoiBaoCao;

  const ReportFormScreen({
    Key? key,
    required this.idBaiDang,
    required this.idNguoiBaoCao,
  }) : super(key: key);

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  String _selectedReason = 'Thông tin sai sự thật';
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  // Danh sách các lý do báo cáo
  final List<String> _reportReasons = [
    'Thông tin sai sự thật',
    'Hình ảnh sai sự thật',
    'Không liên quan đến học tập',
    'Lừa đảo',
    'Khác'
  ];

  // Widget riêng để xây dựng từng tùy chọn Radio
  Widget _buildRadioOption(String title) {
    // Định nghĩa màu viền và màu nền của RadioListTile
    Color borderColor = _selectedReason == title ? const Color(0xFF0079CF) : Colors.grey[300]!;
    Color tileColor = Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0), // Tăng khoảng cách dọc
      child: Container( // Thay đổi từ Card sang Container để kiểm soát border tốt hơn
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(15), // Bo góc nhiều hơn
          border: Border.all(
            color: borderColor, // Viền thay đổi màu khi được chọn
            width: _selectedReason == title ? 2.0 : 1.0, // Độ dày viền thay đổi khi được chọn
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05), // Shadow nhẹ nhàng
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: RadioListTile<String>(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
          value: title,
          groupValue: _selectedReason,
          onChanged: (value) {
            setState(() {
              _selectedReason = value!;
            });
          },
          activeColor: const Color(0xFF0079CF), // Màu của radio button khi được chọn
          controlAffinity: ListTileControlAffinity.leading, // Di chuyển radio button ra đầu
          contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0), // Tùy chỉnh padding bên trong RadioListTile
        ),
      ),
    );
  }

  Future<void> _handleSendReport() async {
    // Show loading indicator
    setState(() => _isLoading = true);

    try {
      await guiBaoCao(
        idBaiDang: widget.idBaiDang,
        idNguoiBaoCao: widget.idNguoiBaoCao,
        lyDo: _selectedReason,
        moTaThem: _descriptionController.text.trim(), // Trim khoảng trắng thừa
      );

      if (!mounted) return;

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Gửi báo cáo thành công!', style: TextStyle(color: Colors.white)),
            ],
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating, // Hiển thị nổi
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop(); // Quay lại màn hình trước
    } catch (e) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded( // Sử dụng Expanded để text không bị tràn
                child: Text(
                  'Lỗi gửi báo cáo: ${e.toString().replaceFirst('Exception: ', '')}',
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis, // Cắt bớt nếu quá dài
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      // Hide loading indicator
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Màu nền tổng thể cho màn hình
      backgroundColor: Colors.grey[50], // Màu xám nhạt tinh tế hơn
      appBar: AppBar(
                automaticallyImplyLeading: false,
        title: const Text(
          'Báo cáo bài đăng vi phạm',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Nền trong suốt để gradient phủ toàn bộ
        elevation: 0, // Bỏ đổ bóng mặc định của AppBar
        iconTheme: const IconThemeData(color: Colors.white), // Đổi màu icon back thành trắng
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              // Gradient màu xanh hiện đại hơn
              colors: [Color(0xFF0079CF), Color(0xFF00C6FF)], // Từ xanh đậm đến xanh sáng
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)), // Bo góc dưới AppBar
            boxShadow: [
              BoxShadow(
                color: Colors.black26, // Đổ bóng nhẹ nhàng
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20), // Tăng padding tổng thể
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lý do báo cáo', // Tiêu đề rõ ràng hơn
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333), // Màu chữ tối hơn
                ),
              ),
              const SizedBox(height: 15), // Tăng khoảng cách

              // Vòng lặp để tạo các RadioOption
              ..._reportReasons.map((reason) => _buildRadioOption(reason)).toList(),

              const SizedBox(height: 25), // Khoảng cách lớn hơn giữa 2 phần

              const Text(
                'Mô tả chi tiết (tùy chọn)', // Thêm "(tùy chọn)" để rõ ràng hơn
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 15), // Tăng khoảng cách

              // TextField cho mô tả chi tiết
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15), // Bo góc cho TextField
                  // Thêm viền vào đây
                  border: Border.all(
                    color: Colors.grey[300]!, // Màu viền mặc định
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.08), // Bóng nhẹ
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 6, // Tăng số dòng hiển thị mặc định
                  minLines: 3, // Giảm số dòng tối thiểu nếu muốn
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Nhập mô tả chi tiết về lý do báo cáo...',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                    border: InputBorder.none, // Vẫn bỏ border mặc định của InputDecoration
                    enabledBorder: InputBorder.none,
                    focusedBorder: OutlineInputBorder( // Viền khi focus (để nổi bật hơn)
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF0079CF), width: 2), // Viền xanh khi focus
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15), // Padding nội dung
                  ),
                  style: TextStyle(color: Colors.grey[900], fontSize: 16),
                ),
              ),
              const SizedBox(height: 30), // Khoảng cách trước nút gửi

              // Nút "Gửi báo cáo"
              SizedBox(
                width: double.infinity,
                height: 55, // Chiều cao cố định cho nút
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSendReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0079CF), // Màu xanh của nút
                    foregroundColor: Colors.white, // Màu chữ
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Bo góc nút
                    ),
                    elevation: 8, // Đổ bóng cho nút
                    shadowColor: const Color(0xFF0079CF).withOpacity(0.4), // Màu bóng
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5, // Độ dày của loading indicator
                          ),
                        )
                      : const Text(
                          'Gửi báo cáo',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}