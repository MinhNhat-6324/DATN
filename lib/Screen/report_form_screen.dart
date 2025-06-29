import 'package:flutter/material.dart';
import 'package:front_end/model/bao_cao.dart'; // Đảm bảo file đúng tên

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

  Widget _buildRadioOption(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: RadioListTile<String>(
          title: Text(title),
          value: title,
          groupValue: _selectedReason,
          onChanged: (value) {
            setState(() {
              _selectedReason = value!;
            });
          },
        ),
      ),
    );
  }

  Future<void> _handleSendReport() async {
    setState(() => _isLoading = true);
    try {
      await guiBaoCao(
        idBaiDang: widget.idBaiDang,
        idNguoiBaoCao: widget.idNguoiBaoCao,
        lyDo: _selectedReason,
        moTaThem: _descriptionController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Gửi báo cáo thành công')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Lỗi gửi báo cáo: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E9),
      appBar: AppBar(
        title: const Text(
          'Báo cáo bài đăng vi phạm',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0079CF), Color(0xFF00FFDE)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('*    Lý do',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...[
                'Thông tin sai sự thật',
                'Hình ảnh sai sự thật',
                'Không liên quan đến học tập',
                'Lừa đảo',
                'Khác'
              ].map(_buildRadioOption),
              const SizedBox(height: 20),
              const Text('*    Mô tả chi tiết',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Nhập mô tả chi tiết...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSendReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
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
