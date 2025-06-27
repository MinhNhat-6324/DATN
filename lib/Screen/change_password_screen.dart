// lib/Screen/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:front_end/services/tai_khoan_service.dart'; // Import service
// Không cần shared_preferences và login_screen nếu không logout

class ChangePasswordScreen extends StatefulWidget {
  final String userId; // Nhận userId từ màn hình trước

  const ChangePasswordScreen({super.key, required this.userId});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TaiKhoanService _taiKhoanService = TaiKhoanService(); // Khởi tạo service

  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmNewPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    FocusScope.of(context).unfocus(); // Ẩn bàn phím
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _taiKhoanService.changePassword(
        widget.userId,
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Đổi mật khẩu thành công!', // Chỉ thông báo thành công
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(10),
          ),
        );
        Navigator.of(context).pop(); // Đóng màn hình đổi mật khẩu sau khi thành công
      }
    } on Exception catch (e) {
      debugPrint('Error changing password: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi đổi mật khẩu: ${e.toString().replaceFirst('Exception: ', '')}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(10),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Phương thức xác thực mật khẩu (đã được sửa)
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu.';
    }
    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự.';
    }
    // Kiểm tra có ít nhất một chữ cái (hoa hoặc thường)
    if (!value.contains(RegExp(r'[a-zA-Z]'))) {
      return 'Mật khẩu phải chứa ít nhất một chữ cái.';
    }
    // Kiểm tra có ít nhất một chữ số
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Mật khẩu phải chứa ít nhất một chữ số.';
    }
    // Kiểm tra có ít nhất một ký tự đặc biệt
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Mật khẩu phải chứa ít nhất một ký tự đặc biệt.';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập lại mật khẩu.';
    }
    if (value != _newPasswordController.text) {
      return 'Mật khẩu nhập lại không khớp.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00C6FF), Color(0xFF0072FF)], // Gradient xanh dương
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25.0), // Tăng padding tổng thể
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10), // Khoảng cách nhỏ sau nút back
                  const Text(
                    'Đổi mật khẩu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32, // Kích thước lớn hơn cho tiêu đề chính
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2, // Tăng khoảng cách chữ
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Vui lòng nhập mật khẩu hiện tại và mật khẩu mới của bạn.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70, // Màu chữ nhạt hơn
                    ),
                  ),
                  const SizedBox(height: 40), // Tăng khoảng cách trước các trường input

                  // Mật khẩu hiện tại
                  _buildPasswordField(
                    controller: _currentPasswordController,
                    labelText: 'Mật khẩu hiện tại', // Vẫn truyền labelText vào hàm
                    obscureText: _obscureCurrentPassword,
                    onToggleObscure: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 25), // Tăng khoảng cách giữa các trường

                  // Mật khẩu mới
                  _buildPasswordField(
                    controller: _newPasswordController,
                    labelText: 'Mật khẩu mới', // Vẫn truyền labelText vào hàm
                    obscureText: _obscureNewPassword,
                    onToggleObscure: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 25),

                  // Xác nhận mật khẩu mới
                  _buildPasswordField(
                    controller: _confirmNewPasswordController,
                    labelText: 'Nhập lại mật khẩu mới', // Vẫn truyền labelText vào hàm
                    obscureText: _obscureConfirmNewPassword,
                    onToggleObscure: () {
                      setState(() {
                        _obscureConfirmNewPassword = !_obscureConfirmNewPassword;
                      });
                    },
                    validator: _validateConfirmPassword,
                  ),
                  const SizedBox(height: 40), // Tăng khoảng cách trước nút

                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : ElevatedButton(
                          onPressed: _changePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0072FF), // Màu chữ xanh
                            padding: const EdgeInsets.symmetric(vertical: 18), // Tăng padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30), // Bo góc nhiều hơn
                            ),
                            elevation: 8, // Đổ bóng mạnh hơn
                            shadowColor: Colors.black.withOpacity(0.3), // Màu đổ bóng
                          ),
                          child: const Text(
                            'Lưu mật khẩu',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Chữ lớn và đậm hơn
                          ),
                        ),
                  const SizedBox(height: 20), // Khoảng cách sau nút
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Hàm xây dựng TextField cho mật khẩu với icon toggle hiển thị/ẩn
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText, // Giờ nhận labelText để dùng cho Text widget
    required bool obscureText,
    required VoidCallback onToggleObscure,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Căn chỉnh label sang trái
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0), // Padding cho label
          child: Text(
            labelText,
            style: const TextStyle(
              color: Colors.white, // Màu trắng cho label trên nền gradient
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: TextInputType.text,
          style: const TextStyle(color: Colors.black87), // Màu chữ nhập vào
          decoration: InputDecoration(
            // ĐÃ BỎ labelText ở đây vì đã dùng Text widget riêng
            // labelText: labelText,
            // labelStyle: const TextStyle(color: Colors.black54),
            filled: true,
            fillColor: Colors.white, // Màu nền của input field
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Tăng padding input
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15), // Bo góc nhiều hơn
              borderSide: BorderSide.none, // Không có border mặc định
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF00FFDE), width: 2), // Border khi focus màu xanh ngọc
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1), // Border khi có lỗi
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.red, width: 2), // Border khi focus và có lỗi
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.black54,
              ),
              onPressed: onToggleObscure,
            ),
          ),
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }
}
