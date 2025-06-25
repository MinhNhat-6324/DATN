import 'package:flutter/material.dart';
import 'package:front_end/services/login_service.dart'; // Đảm bảo import LoginService
import 'package:shared_preferences/shared_preferences.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'admin.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false; // Khôi phục trạng thái loading
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Giữ lại GlobalKey cho Form
  final LoginService _loginService = LoginService(); // Khôi phục LoginService

  // Hàm hiển thị thông báo lỗi/thành công với tông màu dịu mắt
  void _showMessage(String title, String message, {bool success = false}) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Bo tròn góc
        backgroundColor: Colors.white, // Nền trắng dịu mắt
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                success ? Icons.check_circle_outline : Icons.error_outline,
                color: success ? Colors.green.shade600 : Colors.red.shade600, // Màu xanh/đỏ dịu hơn
                size: 50,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF2280EF), // Màu xanh chủ đạo
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: const TextStyle(color: Colors.black87), // Màu chữ đen mờ
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2280EF), // Màu xanh chủ đạo cho nút OK
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // Logic điều hướng sau thành công đã được chuyển vào _login()
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

  // Validator cho Email
  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email không được để trống.';
    }
    // Kiểm tra định dạng email cơ bản
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return 'Email không hợp lệ.';
    }
    // Kiểm tra miền email @caothang.edu.vn
    if (!email.endsWith('@caothang.edu.vn')) {
      return 'Chỉ chấp nhận email @caothang.edu.vn';
    }
    return null;
  }

  // Validator cho Mật khẩu (đã làm mạnh hơn theo tiêu chuẩn backend)
  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Mật khẩu không được để trống.';
    }
    if (password.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự.';
    }
    // Các kiểm tra khác nếu cần (ví dụ: chứa chữ, số, ký tự đặc biệt)
    // if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$').hasMatch(password)) {
    //   return 'Mật khẩu phải chứa ít nhất 1 chữ hoa, 1 chữ thường, 1 số và 1 ký tự đặc biệt.';
    // }
    return null;
  }

  // Khôi phục logic _login() để sử dụng Form validation và LoginService
  Future<void> _login() async {
    // Kiểm tra Form validation
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      setState(() => _isLoading = true); // Bắt đầu loading

      try {
        final responseData = await _loginService.login(email, password);

        final data = responseData['data'];
        final int loaiTaiKhoan = data['loai_tai_khoan'] ?? 0;
        final String userId = data['id_tai_khoan'].toString();

        // Lưu thông tin đăng nhập vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_id', userId);
        await prefs.setString('user_email', data['email']);
        await prefs.setInt('loai_tai_khoan', loaiTaiKhoan);

        // Hiển thị thông báo thành công
        _showMessage('Thành công', responseData['message'] ?? 'Đăng nhập thành công!', success: true);

        // Chờ dialog đóng rồi điều hướng
        Future.delayed(const Duration(milliseconds: 300), () {
          if (loaiTaiKhoan == 1) { // Admin
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => AdminScreen(userId: userId),
              ),
            );
          } else { // Sinh viên
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomeScreen(userId: userId),
              ),
            );
          }
        });
      } on Exception catch (e) {
        String errorMessage = e.toString().replaceFirst('Exception: ', '');
        // Xử lý các thông báo lỗi cụ thể từ backend
        if (errorMessage.contains('Email hoặc mật khẩu không chính xác')) {
          errorMessage = 'Email hoặc mật khẩu không chính xác. Vui lòng thử lại.';
        } else if (errorMessage.contains('Tài khoản của bạn đang chờ quản trị viên duyệt')) {
          errorMessage = 'Tài khoản của bạn đang chờ quản trị viên duyệt. Vui lòng thử lại sau.';
        } else if (errorMessage.contains('Tài khoản của bạn đã bị khóa')) {
          errorMessage = 'Tài khoản của bạn đã bị khóa. Vui lòng liên hệ quản trị viên để biết thêm chi tiết.';
        } else if (errorMessage.contains('Không thể kết nối đến máy chủ')) {
          errorMessage = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng hoặc địa chỉ API.';
        }
        // Thêm các kiểm tra lỗi khác nếu có thông báo lỗi đặc biệt từ backend

        _showMessage('Lỗi đăng nhập', errorMessage);
      } finally {
        if (mounted) { // Đảm bảo widget vẫn còn trong cây widget trước khi gọi setState
          setState(() => _isLoading = false); // Kết thúc loading
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF007EF4), Color(0xFF00C6FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Đăng nhập',
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
              child: Form( // Khôi phục Form widget
                key: _formKey, // Gán GlobalKey vào Form
                child: Column(
                  children: [
                    // Sử dụng _buildTextFormField thay vì _buildInput
                    _buildTextFormField(
                      label: 'Email đăng nhập',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail, // Gán validator
                    ),
                    const SizedBox(height: 10),
                    _buildTextFormField(
                      label: 'Mật khẩu',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      validator: _validatePassword, // Gán validator
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password logic
                        },
                        child: const Text(
                          'Quên mật khẩu?',
                          style: TextStyle(color: Color(0xFF00FFDE)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login, // Gắn hàm _login()
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
                                'Đăng nhập',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Bạn chưa có tài khoản?',
                  style: TextStyle(color: Colors.white),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    'Đăng ký',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // Hàm _buildTextFormField mới để sử dụng TextFormField và validator
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
        TextFormField( // Sử dụng TextFormField
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white),
          keyboardType: keyboardType,
          validator: validator, // Gán validator
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF4300FF),
            suffixIcon: suffixIcon, // Thêm suffixIcon
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12), // Style lỗi
            errorBorder: OutlineInputBorder( // Border lỗi
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder( // Border lỗi khi focus
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
