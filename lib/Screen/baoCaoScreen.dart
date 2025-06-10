import 'package:flutter/material.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({Key? key}) : super(key: key);

  @override
  _ReportFormState createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportFormScreen> {
  String _selectedReason = 'Thông tin sai sự thật';
  final TextEditingController _descriptionController = TextEditingController();

  // Hàm xây dựng RadioListTile có viền và nền trắng riêng
  Widget _buildBorderedRadioTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Đặt nền riêng cho mỗi lựa chọn là màu trắng
          border: Border.all(color: Colors.grey), // Màu border: xám
          borderRadius: BorderRadius.circular(8.0), // Bo góc border
        ),
        child: RadioListTile(
          title: Text(title),
          value: value,
          groupValue: _selectedReason,
          onChanged: (value) {
            setState(() {
              _selectedReason = value.toString();
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Đặt nền màn hình chính thành màu xanh nhạt
      backgroundColor: Color(0xFFF6F1E9),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text(
          'Báo cáo bài đăng vi phạm',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Chữ màu trắng
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Sử dụng SingleChildScrollView để tránh trường hợp bàn phím che khuất
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '*    Lý do',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildBorderedRadioTile(
                  'Thông tin sai sự thật', 'Thông tin sai sự thật'),
              _buildBorderedRadioTile(
                  'Hình ảnh sai sự thật', 'Hình ảnh sai sự thật'),
              _buildBorderedRadioTile(
                  'Không liên quan đến học tập', 'Không liên quan đến học tập'),
              _buildBorderedRadioTile('Lừa đảo', 'Lừa đảo'),
              _buildBorderedRadioTile('Khác', 'Khác'),
              const SizedBox(height: 20),
              const Text(
                '*    Mô tả chi tiết',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Bảo đảm TextField có nền trắng bằng InputDecoration
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  fillColor: Colors.white, // Đặt nền TextField là trắng
                  filled: true,
                  border: OutlineInputBorder(),
                  hintText: 'Nhập mô tả chi tiết...',
                ),
              ),
              const SizedBox(height: 20),
              // Nút full width với màu nền xanh dương
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Xử lý khi nhấn "Gửi báo cáo"
                    print("Lý do: $_selectedReason");
                    print("Mô tả: ${_descriptionController.text}");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Màu nền của nút
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Gửi báo cáo',
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
