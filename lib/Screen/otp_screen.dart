import 'dart:async';
import 'package:flutter/material.dart';
import 'package:front_end/services/register_service.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'student_class.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String userId;

  const OtpScreen({super.key, required this.email, required this.userId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final RegisterService _registerService = RegisterService();

  bool _isLoading = false;
  bool _isResending = false;

  int _countdownSeconds = 60;
  Timer? _timer;
  bool _canResend = false;

  String _otpCode = ''; // Biến lưu OTP thay vì dùng controller

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _canResend = false;
    _countdownSeconds = 60;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_countdownSeconds == 0) {
        setState(() => _canResend = true);
        timer.cancel();
      } else {
        setState(() => _countdownSeconds--);
      }
    });
  }

  void _showMessage(String title, String message,
      {bool success = false, VoidCallback? onOkPressed}) {
    if (!mounted) return;

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
                    if (mounted) Navigator.pop(context);
                    if (mounted) onOkPressed?.call();
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

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      if (!mounted) return;
      setState(() => _isLoading = true);

      try {
        final otpCode = _otpCode.trim();
        final responseData =
            await _registerService.verifyOtp(widget.userId, otpCode);

        if (!mounted) return;
        _showMessage(
          'Xác thực thành công',
          responseData['message'] ?? 'Mã OTP đã được xác thực thành công!',
          success: true,
          onOkPressed: () {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    StudentClassScreen(userId: widget.userId),
              ),
            );
          },
        );
      } on Exception catch (e) {
        if (!mounted) return;
        String errorMessage = e.toString().replaceFirst('Exception: ', '');
        _showMessage('Lỗi xác thực OTP', errorMessage);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_isResending || !_canResend) return;

    setState(() => _isResending = true);

    try {
      final responseData =
          await _registerService.resendOtp(widget.userId, widget.email);

      if (!mounted) return;
      _showMessage(
        'Gửi lại OTP thành công',
        responseData['message'] ?? 'Mã OTP mới đã được gửi đến email của bạn.',
        success: true,
      );
      _startCountdown();
    } on Exception catch (e) {
      if (!mounted) return;
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      _showMessage('Lỗi gửi lại OTP', errorMessage);
    } finally {
      if (mounted) setState(() => _isResending = false);
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
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
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
                      inactiveFillColor:
                          const Color(0xFF4300FF).withOpacity(0.7),
                      selectedFillColor: const Color(0xFF4300FF),
                      activeColor: const Color(0xFF00FFDE),
                      inactiveColor: Colors.white54,
                      selectedColor: Colors.white,
                      errorBorderColor: Colors.redAccent,
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    backgroundColor: Colors.transparent,
                    enableActiveFill: true,
                    enablePinAutofill: false,
                    keyboardType: TextInputType.number,
                    validator: _validateOtp,
                    onChanged: (value) {
                      if (!mounted) return;
                      _otpCode = value;
                    },
                    beforeTextPaste: (text) => true,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOtp,
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
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
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
                      const Text(
                        'Chưa nhận được mã? ',
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed:
                            _canResend && !_isResending ? _resendOtp : null,
                        child: Text(
                          _canResend
                              ? 'Gửi lại mã'
                              : 'Gửi lại sau ($_countdownSeconds s)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _canResend
                                ? const Color(0xFF00FFDE)
                                : Colors.white54,
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
