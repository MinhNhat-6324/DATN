// lib/screens/otp_verification_screen.dart
import 'dart:async'; // Import để sử dụng Timer
import 'package:flutter/material.dart';
import 'package:front_end/services/quen_mat_khau_service.dart';
import 'package:front_end/services/login_service.dart'; 
import 'package:pin_code_fields/pin_code_fields.dart'; // Import thư viện pin_code_fields
import 'reset_password_screen.dart'; // Màn hình tiếp theo sau khi xác thực OTP quên mật khẩu thành công
// import 'registration_success_screen.dart'; // Màn hình tiếp theo sau khi xác thực OTP đăng ký thành công (giả định)

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String otpType; // 'registration' hoặc 'password_reset'

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.otpType,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final QuenMatKhauService _quenMatKhauService = QuenMatKhauService();
  final LoginService _loginService = LoginService(); // Giả định LoginService có thể gửi lại OTP đăng ký

  bool _isLoading = false;
  bool _isResending = false; // Trạng thái loading cho nút gửi lại OTP

  // Biến cho bộ đếm thời gian gửi lại OTP
  int _countdownSeconds = 60;
  Timer? _timer;
  bool _canResend = false; // Biến kiểm soát trạng thái có thể gửi lại OTP hay không

  @override
  void initState() {
    super.initState();
    _startCountdown(); // Bắt đầu đếm ngược khi vào màn hình
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel(); // Hủy timer khi màn hình bị hủy
    super.dispose();
  }

  // Hàm bắt đầu bộ đếm ngược
  void _startCountdown() {
    _canResend = false; // Vô hiệu hóa nút gửi lại ngay lập tức
    _countdownSeconds = 60; // Đặt lại thời gian đếm ngược
    _timer?.cancel(); // Hủy bỏ timer cũ nếu có

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds == 0) {
        setState(() {
          _canResend = true; // Kích hoạt nút gửi lại
          timer.cancel(); // Dừng timer
        });
      } else {
        setState(() {
          _countdownSeconds--;
        });
      }
    });
  }

  // Hàm hiển thị thông báo lỗi/thành công
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

  // Validator cho OTP
  String? _validateOtp(String? otp) {
    if (otp == null || otp.isEmpty) {
      return 'Mã OTP không được để trống.';
    }
    if (otp.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(otp)) {
      return 'Mã OTP phải là 6 chữ số.';
    }
    return null;
  }

  // Hàm xác minh OTP
  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (!mounted) return;
      final otpCode = _otpController.text.trim();

      if (widget.otpType == 'password_reset') {
        final responseData = await _quenMatKhauService.verifyResetOtp(
          widget.email,
          otpCode,
        );

        _showMessage(
          'Thành công',
          responseData['message'] ?? 'Mã OTP đã được xác thực thành công!',
          success: true,
          onOkPressed: () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ResetPasswordScreen(
                    email: widget.email,
                    otpCode: otpCode,
                  ),
                ),
              );
            }
          },
        );
      } else {
        // Logic xác thực OTP đăng ký (placeholder)
        _showMessage(
          'Thông báo', 
          'Tính năng xác thực OTP đăng ký chưa được tích hợp hoàn chỉnh tại đây. (Nếu thành công, bạn sẽ được chuyển đến màn hình Đăng nhập)',
          success: true,
          onOkPressed: () {
            if (mounted) {
              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
            }
          }
        );
      }
    } on Exception catch (e) {
      _showMessage('Lỗi xác thực OTP', 'Mã OTP không hợp lệ hoặc đã hết hạn.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Hàm gửi lại OTP
  Future<void> _resendOtp() async {
    if (_isResending || !_canResend) return;

    setState(() => _isResending = true);

    try {
      if (widget.otpType == 'password_reset') {
        final responseData = await _quenMatKhauService.sendResetOtp(widget.email);
        _showMessage(
          'Thành công',
          responseData['message'] ?? 'Mã OTP mới đã được gửi lại!',
          success: true,
        );
      } else {
        // Logic gửi lại OTP đăng ký (placeholder)
        _showMessage('Thông báo', 'Chức năng gửi lại OTP đăng ký đang được xử lý.');
      }
      _startCountdown(); // Bắt đầu lại bộ đếm ngược
    } on Exception catch (e) {
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      _showMessage('Lỗi gửi lại OTP', errorMessage);
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String titleText = widget.otpType == 'password_reset' ? 'Xác Thực OTP' : 'Xác Thực OTP';
    String descriptionText = 'Mã OTP đã được gửi đến email ${widget.email}. Vui lòng kiểm tra hộp thư đến';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Loại bỏ nút mũi tên quay lại bằng cách đặt automaticallyImplyLeading thành false
        automaticallyImplyLeading: false, 
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
        // Sử dụng Center để căn giữa nội dung theo chiều dọc và ngang
        child: Center( 
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Căn giữa các item trong Column
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Không cần SizedBox(height: 50) cố định nữa vì Center đã lo việc căn giữa
                  Text(
                    titleText,
                    style: const TextStyle(
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
                    child: Column(
                      children: [
                        Text(
                          descriptionText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                        const SizedBox(height: 20),
                        PinCodeTextField(
                          appContext: context,
                          length: 6,
                          obscureText: false,
                          animationType: AnimationType.fade,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(10),
                            fieldHeight: 50,
                            fieldWidth: 40,
                            activeFillColor: const Color(0xFF4300FF),
                            inactiveFillColor: const Color(0xFF4300FF).withOpacity(0.7),
                            selectedFillColor: const Color(0xFF4300FF),
                            activeColor: const Color(0xFF00FFDE),
                            inactiveColor: Colors.white54,
                            selectedColor: Colors.white,
                            errorBorderColor: Colors.redAccent,
                          ),
                          animationDuration: const Duration(milliseconds: 300),
                          backgroundColor: Colors.transparent,
                          enableActiveFill: true,
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            // Có thể thêm logic kiểm tra OTP khi người dùng nhập
                          },
                          validator: _validateOtp,
                          beforeTextPaste: (text) {
                            return true;
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _verifyOtp,
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
                                    'Xác thực OTP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: _canResend && !_isResending ? _resendOtp : null,
                              child: Text(
                                _canResend ? 'Gửi lại mã' : 'Gửi lại sau ($_countdownSeconds s)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _canResend ? const Color(0xFF00FFDE) : Colors.white54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Hàm _buildTextFormField không còn cần thiết cho trường OTP dạng PinCodeTextField
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
              borderSide: const BorderSide(color: Colors.white54),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFF00FFDE), width: 2),
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
}