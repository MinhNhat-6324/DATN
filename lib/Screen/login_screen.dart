import 'package:flutter/material.dart';
import 'package:front_end/services/login_service.dart';
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
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final LoginService _loginService = LoginService();

  void _showMessage(String title, String message, {bool success = false}) {
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
                    Navigator.pop(context);
                    if (success) {
                      // Điều hướng sau khi đăng nhập thành công sẽ thực hiện trong _login()
                    }
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

  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email không được để trống.';
    }
    if (!email.endsWith('@caothang.edu.vn')) {
      return 'Chỉ chấp nhận email @caothang.edu.vn';
    }
    return null;
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Mật khẩu không được để trống.';
    }
    return null;
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      setState(() => _isLoading = true);

      try {
        final responseData = await _loginService.login(email, password);

        final data = responseData['data'];
        final isAdmin = data['isAdmin'] ?? false;

        // Lưu thông tin đăng nhập
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setInt('user_id', data['id_tai_khoan']);
        await prefs.setString('user_email', data['email']);
        await prefs.setBool('is_admin', isAdmin);

        _showMessage(
            'Thành công', responseData['message'] ?? 'Đăng nhập thành công!',
            success: true);

        // Chờ dialog đóng rồi điều hướng
        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  isAdmin ? const AdminScreen() : const HomeScreen(),
            ),
          );
        });
      } on Exception catch (e) {
        String errorMessage;
        String errorDetail = e.toString().replaceFirst('Exception: ', '');
        if (errorDetail.contains('Email hoặc mật khẩu không chính xác')) {
          errorMessage =
              'Email hoặc mật khẩu không chính xác. Vui lòng thử lại.';
        } else if (errorDetail.contains('Không thể kết nối đến máy chủ')) {
          errorMessage =
              'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng hoặc địa chỉ API.';
        } else {
          errorMessage = 'Đã có lỗi xảy ra. ' +
              errorDetail; // Hoặc chỉ "Đã có lỗi xảy ra. Vui lòng thử lại."
        }

        _showMessage('Lỗi đăng nhập', errorMessage);
      } finally {
        setState(() => _isLoading = false);
      }
    }
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildEmailInput(),
                    const SizedBox(height: 10),
                    _buildPasswordInput(),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Màn hình quên mật khẩu
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
                        onPressed: _isLoading ? null : _login,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
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

  Widget _buildEmailInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email đăng nhập',
          style: TextStyle(
            color: Color(0xFF00FFDE),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: _emailController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF4300FF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
        ),
      ],
    );
  }

  Widget _buildPasswordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mật khẩu',
          style: TextStyle(
            color: Color(0xFF00FFDE),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF4300FF),
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
          validator: _validatePassword,
        ),
      ],
    );
  }
}
