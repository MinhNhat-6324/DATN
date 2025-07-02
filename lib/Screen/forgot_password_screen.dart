// lib/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:front_end/services/quen_mat_khau_service.dart'; // Import QuenMatKhauService
import 'otp_verification_screen.dart'; // Màn hình tiếp theo

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final QuenMatKhauService _quenMatKhauService = QuenMatKhauService();

  bool _isLoading = false;

  /// Hiển thị thông báo lỗi/thành công với tông màu dịu mắt.
  /// Lỗi sẽ được hiển thị một cách ngắn gọn và thân thiện với người dùng.
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


  /// Validator cho Email: kiểm tra trống, định dạng và miền email.
  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email không được để trống.';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return 'Email không hợp lệ.';
    }
    if (!email.endsWith('@caothang.edu.vn')) {
      return 'Chỉ chấp nhận email @caothang.edu.vn';
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

  /// Gửi yêu cầu OTP để đặt lại mật khẩu.
  Future<void> _requestResetOtp() async {
    // Ẩn bàn phím trước khi xử lý
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final responseData = await _quenMatKhauService.sendResetOtp(_emailController.text.trim());

      _showMessage(
        'Thành công',
        responseData['message'] ?? 'Mã OTP đã được gửi đến email của bạn!',
        success: true,
      );

      // Đợi dialog đóng rồi điều hướng
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return; // Đảm bảo widget vẫn còn trong cây

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            email: _emailController.text.trim(),
            otpType: 'password_reset', // Đánh dấu loại OTP là "quên mật khẩu"
          ),
        ),
      );
    } on Exception catch (e) {
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      
      // Ưu tiên hiển thị thông báo lỗi trực tiếp từ backend nếu có
      // Backend của bạn cần trả về thông báo lỗi rõ ràng.
      // Ví dụ: Exception: Email không tồn tại
      // Hoặc nếu backend trả về JSON với một trường 'message', bạn có thể cần parse nó.
      
      // Các trường hợp lỗi cụ thể mà bạn đã xác định trước đó vẫn sẽ được xử lý nếu cần.
      if (errorMessage.contains('Email không tồn tại')) {
        errorMessage = 'Email bạn nhập không tồn tại trong hệ thống. Vui lòng kiểm tra lại.';
      } else {
        // Fallback cho các lỗi không xác định hoặc lỗi mạng khác
        errorMessage = 'Email bạn nhập không tồn tại trong hệ thống. Vui lòng kiểm tra lại';
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
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Quên Mật Khẩu',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
                          label: 'Email của bạn',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _requestResetOtp,
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
                                    'Gửi OTP',
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
                const SizedBox(height: 30),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Quay lại Đăng nhập',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}