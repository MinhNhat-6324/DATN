import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:front_end/services/register_service.dart';
import 'otp_screen.dart'; // Màn hình OTP

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false; // Biến trạng thái loading

  final _formKey = GlobalKey<FormState>(); // Dùng FormState để validate

  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedGender = 'Nam'; // 0 = Nữ, 1 = Nam

  File? _imageFile; // Ảnh đại diện sẽ được chọn ở màn hình StudentClassScreen
  final RegisterService _registerService = RegisterService(); // Khởi tạo service

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Hàm này sẽ không còn dùng ở đây nếu ảnh đại diện được chọn ở StudentClassScreen
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  // Hàm hiển thị thông báo lỗi/thành công
  void _showMessage(String title, String message, {bool success = false, VoidCallback? onOkPressed}) {
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
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Đóng dialog
                    onOkPressed?.call(); // Gọi callback sau khi dialog đóng
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

  // Hàm Gửi OTP
  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus(); // Ẩn bàn phím

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final email = _emailController.text.trim();
      final hoTen = _nameController.text.trim();
      final sdt = _phoneController.text.trim();
      final matKhau = _passwordController.text;
      final nhapLai = _confirmPasswordController.text;

      // Chuyển đổi giới tính từ String sang int cho backend (0=Nữ, 1=Nam)
      int? genderValue;
      if (_selectedGender == 'Nam') {
        genderValue = 1;
      } else if (_selectedGender == 'Nữ') {
        genderValue = 0;
      } else {
        genderValue = null;
      }

      try {
        final responseData = await _registerService.sendOtpForRegistration(
          email,
          matKhau,
          nhapLai,
          hoTen,
          sdt.isEmpty ? null : sdt,
          genderValue,
        );

        final String? userId = responseData['user_id']?.toString(); // Đảm bảo userId là String

        if (userId == null || userId.isEmpty) {
          throw Exception('Không nhận được ID người dùng từ máy chủ. Vui lòng thử lại.');
        }

        _showMessage(
          'Gửi OTP thành công',
          responseData['message'] ?? 'Mã OTP đã được gửi đến email của bạn. Vui lòng kiểm tra hộp thư đến.',
          success: true,
          onOkPressed: () { // Callback này sẽ được gọi khi người dùng nhấn OK trên dialog
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OtpScreen(
                    email: email,
                    userId: userId, // TRUYỀN ID_TAI_KHOAN QUA ĐÂY
                  ),
                ),
              );
            }
          },
        );
      } on Exception catch (e) {
        String errorMessage = e.toString().replaceFirst('Exception: ', '');
        _showMessage('Lỗi gửi OTP', errorMessage);
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email không được để trống.';
    }
    if (!value.endsWith('@caothang.edu.vn')) {
      return 'Chỉ chấp nhận email @caothang.edu.vn';
    }
    if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
        return 'Email không đúng định dạng.';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Họ và tên không được để trống.';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Số điện thoại không được để trống.';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Chỉ 10 chữ số';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống.';
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$%^&*(),.?":{}|<>])[A-Za-z\d!@#\$%^&*(),.?":{}|<>]{8,}$').hasMatch(value)) {
      return 'Mật khẩu phải từ 8 ký tự và gồm chữ, số, ký tự đặc biệt.';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập lại mật khẩu.';
    }
    if (value != _passwordController.text) {
      return 'Mật khẩu nhập lại không khớp.';
    }
    return null;
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    String? prefixText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
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
          TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              prefixText: prefixText,
              prefixStyle: const TextStyle(color: Colors.white),
              filled: true,
              fillColor: const Color(0xFF4300FF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              errorStyle: const TextStyle(color: Colors.redAccent),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordInput(String label, TextEditingController controller, bool obscureText, VoidCallback onToggle, String? Function(String?)? validator) {
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
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(color: Colors.white),
            validator: validator,
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
              errorStyle: const TextStyle(color: Colors.redAccent),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.red, width: 2),
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
            child: Form(
              key: _formKey,
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
                  // Phần chọn ảnh đại diện đã được di chuyển sang StudentClassScreen
                  _buildInput(
                    label: 'Email đăng nhập',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  _buildInput(
                    label: 'Họ và tên',
                    controller: _nameController,
                    validator: _validateName,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: 'Giới tính',
                          value: _selectedGender,
                          items: const ['Nam', 'Nữ'],
                          onChanged: (val) => setState(() => _selectedGender = val),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildInput(
                          label: 'Số điện thoại',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: _validatePhone,
                        ),
                      ),
                    ],
                  ),
                  _buildPasswordInput(
                    'Mật khẩu',
                    _passwordController,
                    _obscurePassword,
                    () { setState(() => _obscurePassword = !_obscurePassword); },
                    _validatePassword,
                  ),
                  _buildPasswordInput(
                    'Nhập lại mật khẩu',
                    _confirmPasswordController,
                    _obscureConfirmPassword,
                    () { setState(() => _obscureConfirmPassword = !_obscureConfirmPassword); },
                    _validateConfirmPassword,
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendOtp, // Gọi _sendOtp
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
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                          : const Text(
                                'Đăng ký',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Đã có tài khoản?',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Quay về màn hình đăng nhập
                        },
                        child: const Text(
                          'Đăng nhập',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
