import 'dart:async';
import 'package:flutter/material.dart';
import 'package:front_end/services/register_service.dart';
import 'package:pin_code_fields/pin_code_fields.dart'; // Import thư viện pin_code_fields
import 'student_class.dart'; // Màn hình tiếp theo sau OTP

class OtpScreen extends StatefulWidget {
  final String email;
  final String userId; // Nhận userId từ RegisterScreen

  const OtpScreen({super.key, required this.email, required this.userId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Khóa cho FormState
  final RegisterService _registerService = RegisterService(); // Khởi tạo service
  
  bool _isLoading = false; // Trạng thái loading cho nút xác nhận
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
    _timer?.cancel();
    _otpController.dispose(); // <== QUAN TRỌNG!
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

  // Hàm xác minh OTP
  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus(); // Ẩn bàn phím

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true); // Bắt đầu loading

      

      try {

        if (!mounted) return;
        
        final otpCode = _otpController.text.trim();

        final responseData = await _registerService.verifyOtp(widget.userId, otpCode);

        _showMessage(
          'Xác thực thành công',
          responseData['message'] ?? 'Mã OTP đã được xác thực thành công!',
          success: true,
          onOkPressed: () {
            // Điều hướng đến màn hình StudentClassScreen sau khi xác thực thành công
            // Sử dụng pushReplacement để không thể quay lại màn hình OTP
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentClassScreen(userId: widget.userId),
                ),
              );
            }
          },
        );
      } on Exception catch (e) {
        String errorMessage = e.toString().replaceFirst('Exception: ', '');
        _showMessage('Lỗi xác thực OTP', errorMessage);
      } finally {
        if (mounted) {
          setState(() => _isLoading = false); // Kết thúc loading
        }
      }
    }
  }

  // Hàm gửi lại OTP
  Future<void> _resendOtp() async {
    if (_isResending || !_canResend) return; // Ngăn chặn gửi lại khi đang loading hoặc chưa hết thời gian

    setState(() => _isResending = true); // Bắt đầu loading cho nút gửi lại

    try {
      final responseData = await _registerService.resendOtp(widget.userId, widget.email);
      _showMessage(
        'Gửi lại OTP thành công',
        responseData['message'] ?? 'Mã OTP mới đã được gửi đến email của bạn.',
        success: true,
      );
      _startCountdown(); // Bắt đầu lại bộ đếm ngược
    } on Exception catch (e) {
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      _showMessage('Lỗi gửi lại OTP', errorMessage);
    } finally {
      if (mounted) {
        setState(() => _isResending = false); // Kết thúc loading
      }
    }
  }

  String? _validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mã OTP.';
    }
    if (value.length != 6) {
      return 'Mã OTP phải có 6 chữ số.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Ngăn bàn phím làm thay đổi kích thước màn hình
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
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Xác thực OTP',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Mã OTP đã được gửi đến email:',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    widget.email,
                    style: const TextStyle(
                      color: Color(0xFF00FFDE),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
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
                      errorBorderColor: Colors.redAccent, // Màu khi có lỗi
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    backgroundColor: Colors.transparent,
                    enableActiveFill: true,
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      // Có thể thêm logic kiểm tra OTP khi người dùng nhập
                    },
                    validator: _validateOtp, // Gán validator
                    beforeTextPaste: (text) {
                      return true; // Cho phép dán văn bản
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOtp, // Gọi hàm xác minh OTP
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
                                'Xác nhận OTP',
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
                      Text(
                        'Chưa nhận được mã? ',
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: _canResend && !_isResending ? _resendOtp : null, // Vô hiệu hóa nút nếu đang đếm ngược hoặc đang gửi lại
                        child: Text(
                          _canResend ? 'Gửi lại mã' : 'Gửi lại sau ($_countdownSeconds s)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _canResend ? Color(0xFF00FFDE) : Colors.white54, // Thay đổi màu sắc tùy trạng thái
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
