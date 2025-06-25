import 'package:flutter/material.dart';
import 'package:front_end/services/tai_khoan_service.dart'; // Import TaiKhoanService

class AdminRegistrationScreen extends StatefulWidget {
  const AdminRegistrationScreen({super.key});

  @override
  State<AdminRegistrationScreen> createState() => _AdminRegistrationScreenState();
}

class _AdminRegistrationScreenState extends State<AdminRegistrationScreen> {
  final _formKey = GlobalKey<FormState>(); // Key để quản lý trạng thái form
  final TaiKhoanService _taiKhoanService = TaiKhoanService();

  final TextEditingController _hoTenController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _sdtController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true; // Dùng để ẩn/hiện mật khẩu
  bool _obscureConfirmPassword = true;
  int? _selectedGioiTinh; // 0: Nữ, 1: Nam

  @override
  void dispose() {
    _hoTenController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _sdtController.dispose();
    super.dispose();
  }

  Future<void> _registerAdmin() async {
    if (!_formKey.currentState!.validate()) {
      return; // Không tiếp tục nếu form không hợp lệ
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _taiKhoanService.registerAdminAccount(
        hoTen: _hoTenController.text,
        email: _emailController.text,
        matKhau: _passwordController.text,
        sdt: _sdtController.text.isNotEmpty ? _sdtController.text : null,
        gioiTinh: _selectedGioiTinh,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Đăng ký admin thành công!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );

      // Reset form sau khi đăng ký thành công
      _hoTenController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _sdtController.clear();
      setState(() {
        _selectedGioiTinh = null;
      });

    } catch (e) {
      String rawErrorMessage = e.toString().replaceFirst('Exception: ', '');
      String displayMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại.'; // Thông báo lỗi mặc định

      // Tách thông báo lỗi chung và lỗi chi tiết từng trường
      List<String> parts = rawErrorMessage.split('\n');
      if (parts.length > 1) {
        // Có lỗi chi tiết, lấy lỗi của từng trường
        String detailedErrorsString = parts.sublist(1).join('\n');

        // Kiểm tra lỗi email trùng lặp
        if (detailedErrorsString.contains('email: The email has already been taken.')) {
          displayMessage = 'Email này đã được sử dụng cho tài khoản khác. Vui lòng chọn email khác.';
        }
        // Kiểm tra lỗi miền email không hợp lệ (nếu backend trả về rõ ràng)
        else if (detailedErrorsString.contains('email: The email must end with @caothang.edu.vn.')) {
          displayMessage = 'Email phải có miền @caothang.edu.vn.';
        }
        // Có thể thêm các kiểm tra lỗi chi tiết khác tùy theo thông báo từ backend
        // Ví dụ: if (detailedErrorsString.contains('password: The password must be at least 8 characters.')) { ... }
        else {
          // Nếu không phải lỗi cụ thể đã định nghĩa, hiển thị lỗi chi tiết từ backend
          displayMessage = detailedErrorsString;
        }
      } else {
        // Nếu chỉ có một phần lỗi, hiển thị phần đó
        displayMessage = rawErrorMessage;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(displayMessage), // Hiển thị thông báo đã được làm sạch
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2280EF), Color(0xFF00C6FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            // Tăng padding ngang để khung card lớn hơn một chút
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 25.0), // Đã tăng padding
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(30.0), // Đã tăng padding bên trong card
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Tạo tài khoản Admin',
                        style: TextStyle(
                          fontSize: 24, // Đã giảm kích thước chữ
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2280EF),
                        ),
                      ),
                      const SizedBox(height: 20), // Giảm khoảng cách
                      TextFormField(
                        controller: _hoTenController,
                        style: const TextStyle(fontSize: 16), // Kích thước chữ trong input
                        decoration: _inputDecoration('Họ và tên', Icons.person),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập họ và tên';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontSize: 16), // Kích thước chữ trong input
                        decoration: _inputDecoration('Email (@caothang.edu.vn)', Icons.email), // Cập nhật hint
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Email không hợp lệ';
                          }
                          // Kiểm tra miền email ở frontend
                          if (!value.endsWith('@caothang.edu.vn')) {
                            return 'Email phải có miền @caothang.edu.vn';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(fontSize: 16), // Kích thước chữ trong input
                        decoration: _inputDecoration(
                          'Mật khẩu',
                          Icons.lock,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          if (value.length < 8) {
                            return 'Mật khẩu phải có ít nhất 8 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: const TextStyle(fontSize: 16), // Kích thước chữ trong input
                        decoration: _inputDecoration(
                          'Xác nhận mật khẩu',
                          Icons.lock_reset,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng xác nhận mật khẩu';
                          }
                          if (value != _passwordController.text) {
                            return 'Mật khẩu xác nhận không khớp';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _sdtController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontSize: 16), // Kích thước chữ trong input
                        decoration: _inputDecoration('Số điện thoại (Tùy chọn)', Icons.phone),
                        // Validator là tùy chọn vì trường này là nullable
                      ),
                      const SizedBox(height: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Giới tính:',
                            style: TextStyle(
                              fontSize: 15, // Đã giảm kích thước chữ
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<int>(
                                  title: const Text('Nam', style: TextStyle(fontSize: 15)), // Đã giảm kích thước chữ
                                  value: 1,
                                  groupValue: _selectedGioiTinh,
                                  onChanged: (int? value) {
                                    setState(() {
                                      _selectedGioiTinh = value;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<int>(
                                  title: const Text('Nữ', style: TextStyle(fontSize: 15)), // Đã giảm kích thước chữ
                                  value: 0,
                                  groupValue: _selectedGioiTinh,
                                  onChanged: (int? value) {
                                    setState(() {
                                      _selectedGioiTinh = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20), // Giảm khoảng cách
                      _isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2280EF)),
                            )
                          : ElevatedButton(
                              onPressed: _registerAdmin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2280EF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12), // Giảm padding
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Giảm kích thước chữ
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 5,
                              ),
                              child: const Text('Đăng ký Admin'),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String labelText, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon, color: const Color(0xFF2280EF)),
      suffixIcon: suffixIcon,
      labelStyle: const TextStyle(color: Color(0xFF666666), fontSize: 14), // Giảm kích thước label
      fillColor: Colors.grey[100],
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF2280EF), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}
