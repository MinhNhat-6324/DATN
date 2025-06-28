import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:front_end/services/register_service.dart'; // Import RegisterService
import 'package:front_end/services/chuyen_nganh_san_pham_service.dart'; // Import service để tải chuyên ngành
import 'home_screen.dart'; // Màn hình chính sau khi hoàn tất

class StudentClassScreen extends StatefulWidget {
  final String userId; // Thêm biến này

  const StudentClassScreen(
      {super.key, required this.userId}); // CẬP NHẬT CONSTRUCTOR

  @override
  State<StudentClassScreen> createState() => _StudentClassScreenState();
}

class _StudentClassScreenState extends State<StudentClassScreen> {
  final _formKey = GlobalKey<FormState>(); // Thêm GlobalKey cho Form
  final _classController = TextEditingController();
  String? _selectedMajor; // Ban đầu để null, sẽ được gán sau khi tải dữ liệu
  File? _imageFile;
  bool _isLoading = false; // Trạng thái loading cho nút hoàn tất đăng ký

  List<String> _majorItems = []; // Danh sách chuyên ngành sẽ được tải từ API
  bool _isLoadingMajors = true; // Trạng thái loading cho chuyên ngành
  final ChuyenNganhSanPhamService _chuyenNganhSanPhamService =
      ChuyenNganhSanPhamService(); // Khởi tạo service tải chuyên ngành
  final RegisterService _registerService =
      RegisterService(); // Khởi tạo RegisterService để cập nhật hồ sơ

  @override
  void initState() {
    super.initState();
    _fetchMajors(); // Gọi hàm tải chuyên ngành khi màn hình khởi tạo
  }

  @override
  void dispose() {
    _classController.dispose();
    super.dispose();
  }

  // Hàm tải danh sách chuyên ngành từ API
  Future<void> _fetchMajors() async {
    try {
      final List<String> fetchedMajors =
          await _chuyenNganhSanPhamService.fetchChuyenNganhNames();
      setState(() {
        _majorItems = fetchedMajors;
        // Đặt giá trị mặc định cho _selectedMajor nếu có dữ liệu
        if (_majorItems.isNotEmpty) {
          _selectedMajor = _majorItems.first;
        } else {
          _selectedMajor = null; // Không có chuyên ngành nào để chọn
        }
        _isLoadingMajors = false; // Tắt trạng thái loading
      });
    } on Exception catch (e) {
      setState(() {
        _isLoadingMajors = false; // Tắt trạng thái loading ngay cả khi có lỗi
        _majorItems = []; // Xóa danh sách nếu có lỗi
        _selectedMajor = null; // Đặt về null để không có lựa chọn nào
      });
      // Hiển thị thông báo lỗi cho người dùng
      _showMessage('Lỗi tải chuyên ngành',
          'Không thể tải danh sách chuyên ngành. Vui lòng thử lại. Chi tiết: ${e.toString().replaceFirst('Exception: ', '')}',
          success: false);
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  // Hàm hiển thị thông báo lỗi/thành công
  void _showMessage(String title, String message,
      {bool success = false, VoidCallback? onOkPressed}) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF4300FF),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                success ? Icons.check_circle_outline : Icons.error_outline,
                color: success ? Colors.greenAccent : const Color(0xFF00FFDE),
                size: 50,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF00FFDE),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onOkPressed?.call(); // Gọi callback nếu có
                  },
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm xử lý khi người dùng nhấn "Hoàn tất đăng ký"
  Future<void> _saveStudentDetails() async {
    FocusScope.of(context).unfocus(); // Ẩn bàn phím

    if (_formKey.currentState!.validate()) {
      // Kiểm tra validation của form
      if (_imageFile == null) {
        _showMessage('Thiếu ảnh thẻ sinh viên',
            'Vui lòng chọn ảnh thẻ sinh viên để hoàn tất đăng ký.');
        return;
      }
      if (_selectedMajor == null || _selectedMajor!.isEmpty) {
        _showMessage('Thiếu chuyên ngành', 'Vui lòng chọn chuyên ngành.');
        return;
      }

      setState(() => _isLoading = true); // Bắt đầu loading

      final lop = _classController.text.trim();
      final chuyenNganh =
          _selectedMajor!; // Chắc chắn có giá trị do đã kiểm tra

      try {
        await _registerService.updateStudentProfile(
          widget.userId, // Truyền userId nhận được từ màn hình trước đó
          lop,
          chuyenNganh,
          _imageFile!, // File ảnh thẻ sinh viên (sẽ được xử lý trong service)
        );

        _showMessage(
          'Hoàn tất đăng ký',
          'Thông tin của bạn đã được cập nhật thành công và đang chờ duyệt!', // Thông báo thành công mặc định
          success: true,
          onOkPressed: () {
            // Điều hướng đến màn hình chính sau khi hoàn tất
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      HomeScreen(userId: widget.userId)), // Đã sửa lỗi ở đây
            );
          },
        );
      } on Exception catch (e) {
        String errorMessage = e.toString().replaceFirst('Exception: ', '');
        _showMessage('Lỗi cập nhật thông tin', errorMessage);
      } finally {
        if (mounted) {
          setState(() => _isLoading = false); // Kết thúc loading
        }
      }
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName không được để trống.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF007EF4), Color(0xFF00C6FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Form(
              key: _formKey, // Gán GlobalKey vào Form
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Hoàn tất thông tin',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Phần chọn ảnh đại diện
                  const Text(
                    'Ảnh chụp thẻ sinh viên',
                    style: TextStyle(
                      color: Color(0xFF00FFDE),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4300FF),
                        borderRadius: BorderRadius.circular(20),
                        image: _imageFile != null
                            ? DecorationImage(
                                image: FileImage(_imageFile!),
                                fit: BoxFit.cover)
                            : null,
                      ),
                      child: _imageFile == null
                          ? const Icon(Icons.camera_alt,
                              color: Colors.white, size: 40)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildInput(
                    label: 'Tên lớp',
                    controller: _classController,
                    validator: (val) => _validateRequired(val, 'Tên lớp'),
                  ),
                  const SizedBox(height: 20), // Khoảng cách sau input

                  // Logic hiển thị chuyên ngành
                  _isLoadingMajors
                      ? const CircularProgressIndicator(
                          color: Color(0xFF00FFDE)) // Hiển thị loading
                      : _majorItems.isEmpty
                          ? const Text(
                              'Không có chuyên ngành để hiển thị. Vui lòng kiểm tra kết nối hoặc cấu hình API.',
                              style: TextStyle(color: Colors.white70),
                              textAlign: TextAlign.center,
                            )
                          : _buildDropdown(
                              label: 'Chuyên ngành',
                              value: _selectedMajor, // Sử dụng giá trị đã chọn
                              items: _majorItems, // Sử dụng danh sách từ API
                              onChanged: (val) =>
                                  setState(() => _selectedMajor = val),
                            ),
                  const SizedBox(height: 20), // Khoảng cách sau dropdown

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : _saveStudentDetails, // Gọi _saveStudentDetails
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Hoàn tất đăng ký',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Hàm _buildInput này được sửa để dùng TextFormField và validator
  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    String? prefixText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              color: Color(0xFF00FFDE),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            )),
        const SizedBox(height: 4),
        TextFormField(
          // Đã đổi sang TextFormField để dùng validator
          controller: controller,
          style: const TextStyle(color: Colors.white),
          keyboardType: keyboardType,
          validator: validator, // Gán validator
          decoration: InputDecoration(
            prefixText: prefixText,
            prefixStyle: const TextStyle(color: Colors.white),
            filled: true,
            fillColor: const Color(0xFF4300FF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            errorStyle:
                const TextStyle(color: Colors.redAccent), // Style cho lỗi
            errorBorder: OutlineInputBorder(
              // Border khi có lỗi
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              // Border khi có lỗi và focus
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // Hàm _buildDropdown này đã có sẵn, chỉ cần đảm bảo dùng đúng
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              color: Color(0xFF00FFDE),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            )),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF4300FF),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: const Color(0xFF4300FF),
              isExpanded: true,
              value: value,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child:
                      Text(item, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: items.isEmpty
                  ? null
                  : onChanged, // Vô hiệu hóa khi danh sách rỗng
            ),
          ),
        ),
      ],
    );
  }
}
