// lib/screens/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:front_end/services/quen_mat_khau_service.dart';
import 'login_screen.dart'; // Quay về màn hình đăng nhập sau khi thành công

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otpCode; // Mã OTP đã được xác thực từ màn hình trước

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otpCode,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final QuenMatKhauService _quenMatKhauService = QuenMatKhauService();

  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  /// Hiển thị thông báo lỗi/thành công với tông màu dịu mắt.
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


  /// Validator cho Mật khẩu mới:
  /// - Không được để trống.
  /// - Phải có ít nhất 8 ký tự.
  /// - Phải bao gồm chữ cái (hoa hoặc thường), số và ký tự đặc biệt.
  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Mật khẩu không được để trống.';
    }
    if (password.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự.';
    }
    // Kiểm tra có ít nhất một chữ cái (hoa hoặc thường)
    if (!password.contains(RegExp(r'[a-zA-Z]'))) {
      return 'Mật khẩu phải chứa ít nhất một chữ cái.';
    }
    // Kiểm tra có ít nhất một số
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Mật khẩu phải chứa ít nhất một số.';
    }
    // Kiểm tra có ít nhất một ký tự đặc biệt (ngoại trừ chữ cái và số)
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Mật khẩu phải chứa ít nhất một ký tự đặc biệt.';
    }
    return null;
  }

  /// Validator cho Xác nhận mật khẩu mới:
  /// - Không được để trống.
  /// - Phải khớp với mật khẩu mới.
  String? _validateConfirmPassword(String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Xác nhận mật khẩu không được để trống.';
    }
    if (confirmPassword != _newPasswordController.text) {
      return 'Mật khẩu xác nhận không khớp.';
    }
    return null;
  }

  /// Widget dùng để xây dựng trường nhập liệu TextFormField.
  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF00FFDE),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white),
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF4300FF),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.white54), // Viền khi không focus
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFF00FFDE), width: 2), // Viền khi focus
            ),
            errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  /// Xử lý việc đặt lại mật khẩu.
  Future<void> _resetPassword() async {
    // Ẩn bàn phím trước khi xử lý
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final responseData = await _quenMatKhauService.resetPassword(
        widget.email,
        widget.otpCode,
        _newPasswordController.text,
        _confirmPasswordController.text,
      );

      _showMessage(
        'Thành công',
        responseData['message'] ?? 'Mật khẩu của bạn đã được đặt lại thành công!',
        success: true,
      );

      // Chờ dialog đóng rồi điều hướng về màn hình đăng nhập và xóa các route trước đó
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return; // Đảm bảo widget vẫn còn trong cây

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false, // Xóa tất cả các route trước đó
      );
    } on Exception catch (e) {
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      // Lọc và hiển thị lỗi một cách thân thiện hơn
      if (errorMessage.contains('Mã OTP không hợp lệ hoặc đã hết hạn')) {
        errorMessage = 'Mã xác thực không hợp lệ hoặc đã hết hạn. Vui lòng thử lại.';
      } else if (errorMessage.contains('Mật khẩu mới không được giống mật khẩu cũ')) {
        errorMessage = 'Mật khẩu mới không được trùng với mật khẩu cũ của bạn.';
      } else if (errorMessage.contains('Mật khẩu mới và xác nhận mật khẩu không khớp')) {
        errorMessage = 'Mật khẩu mới và xác nhận mật khẩu không khớp.';
      } else if (errorMessage.contains('Internal server error')) { // Ví dụ lỗi từ backend
        errorMessage = 'Có lỗi xảy ra từ hệ thống. Vui lòng thử lại sau.';
      } else if (errorMessage.contains('Failed host lookup') || errorMessage.contains('Connection refused')) { // Lỗi mạng
        errorMessage = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.';
      }
      else {
        // Fallback cho các lỗi không xác định khác
        errorMessage = 'Đã xảy ra lỗi không mong muốn. Vui lòng thử lại sau.';
      }
      _showMessage('Lỗi', errorMessage);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        // Loại bỏ nút quay lại mặc định
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true, // Kéo dài body ra sau AppBar
      body: Container(
        width: MediaQuery.of(context).size.width, // Đảm bảo chiếm toàn bộ chiều rộng
        height: MediaQuery.of(context).size.height, // Đảm bảo chiếm toàn bộ chiều cao
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF007EF4), Color(0xFF00C6FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        // Sử dụng Center để căn giữa nội dung chính
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Căn giữa theo chiều dọc
              crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa theo chiều ngang
              children: [
                const Text(
                  'Đặt Lại Mật Khẩu Mới',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextFormField(
                          label: 'Mật khẩu mới',
                          controller: _newPasswordController,
                          obscureText: _obscureNewPassword,
                          validator: _validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildTextFormField(
                          label: 'Xác nhận mật khẩu mới',
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          validator: _validateConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 25), // Tăng khoảng cách cho đồng đều
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _resetPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyanAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
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
                                    'Đặt Lại Mật Khẩu',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30), // Thêm khoảng trống dưới cùng để cân đối
              ],
            ),
          ),
        ),
      ),
    );
  }
}