import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _classController = TextEditingController();

  String? _selectedGender = 'Nam';
  String? _selectedMajor = 'CNTT';

  File? _imageFile;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _classController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF4300FF), // Màu tím đậm nền dialog
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFF00FFDE),
                size: 50,
              ),
              const SizedBox(height: 10),
              const Text(
                'Thông báo',
                style: TextStyle(
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đã hiểu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Đăng ký tài khoản',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                _buildInput(label: 'Email đăng nhập', controller: _emailController),
                _buildInput(label: 'Họ và tên', controller: _nameController),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        label: 'Giới tính',
                        value: _selectedGender,
                        items: ['Nam', 'Nữ'],
                        onChanged: (val) => setState(() => _selectedGender = val),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInput(
                        label: 'Số điện thoại',
                        controller: _phoneController,
                      ),
                    ),
                  ],
                ),
                _buildPasswordInput('Mật khẩu', _passwordController, _obscurePassword, () {
                  setState(() => _obscurePassword = !_obscurePassword);
                }),
                _buildPasswordInput('Nhập lại mật khẩu', _confirmPasswordController, _obscureConfirmPassword, () {
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                }),
                Row(
                  children: [
                    Expanded(
                      child: _buildInput(label: 'Tên lớp', controller: _classController),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDropdown(
                        label: 'Chuyên ngành',
                        value: _selectedMajor,
                        items: ['CNTT', 'Cơ khí', 'Điện tử', 'Kế toán'],
                        onChanged: (val) => setState(() => _selectedMajor = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Text(
                        'Ảnh chụp thẻ sinh viên',
                        style: TextStyle(
                          color: Color(0xFF00FFDE),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4300FF),
                      borderRadius: BorderRadius.circular(20),
                      image: _imageFile != null
                          ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _imageFile == null
                        ? const Icon(Icons.camera_alt, color: Colors.white, size: 40)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();

                      Future.delayed(Duration.zero, () {
                        String email = _emailController.text.trim();
                        String hoTen = _nameController.text.trim();
                        String sdt = _phoneController.text.trim();
                        String matKhau = _passwordController.text;
                        String nhapLai = _confirmPasswordController.text;
                        String lop = _classController.text.trim();
                        String gioiTinh = _selectedGender ?? '';
                        String chuyenNganh = _selectedMajor ?? '';

                        if (_imageFile == null) {
                          _showError('Vui lòng chọn ảnh đại diện.');
                          return;
                        }

                        if (email.isEmpty || hoTen.isEmpty || sdt.isEmpty || matKhau.isEmpty || nhapLai.isEmpty || lop.isEmpty || gioiTinh.isEmpty || chuyenNganh.isEmpty) {
                          _showError('Vui lòng điền đầy đủ tất cả thông tin.');
                          return;
                        }

                        if (!email.endsWith('@caothang.edu.vn')) {
                          _showError('Chỉ chấp nhận email @caothang.edu.vn');
                          return;
                        }

                        if (!RegExp(r'^\d{10}$').hasMatch(sdt)) {
                          _showError('Số điện thoại phải gồm đúng 10 chữ số.');
                          return;
                        }

                        if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$%^&*(),.?":{}|<>])[A-Za-z\d!@#\$%^&*(),.?":{}|<>]{8,}$').hasMatch(matKhau)) {
                          _showError('Mật khẩu phải từ 8 ký tự và gồm chữ, số, ký tự đặc biệt.');
                          return;
                        }

                        if (matKhau != nhapLai) {
                          _showError('Mật khẩu nhập lại không khớp.');
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OtpScreen()),
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Đăng ký',
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
    );
  }

  Widget _buildInput({required String label, required TextEditingController controller, String? prefixText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                color: Color(0xFF00FFDE),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              )),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixText: prefixText,
              prefixStyle: const TextStyle(color: Colors.white),
              filled: true,
              fillColor: const Color(0xFF4300FF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordInput(String label, TextEditingController controller, bool obscureText, VoidCallback onToggle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                color: Color(0xFF00FFDE),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              )),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: onToggle,
              ),
              filled: true,
              fillColor: const Color(0xFF4300FF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
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
                    child: Text(item, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
