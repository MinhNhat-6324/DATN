// image_picker_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({super.key});

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  File? _selectedImage;
  final picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      _showPreviewDialog(); // Hiển thị dialog preview
    } else {
      // Nếu người dùng không chọn ảnh, quay lại màn hình trước với giá trị null
      if (mounted) {
        Navigator.pop(context, null);
      }
    }
  }

  void _showPreviewDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Không cho phép đóng dialog khi nhấn ra ngoài
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            // Gradient mới cho dialog
            gradient: const LinearGradient(
              colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC)], // Màu tím nhạt -> xanh nhạt
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Xác nhận ảnh đại diện",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Màu chữ tối hơn
                ),
              ),
              const SizedBox(height: 20),
              if (_selectedImage != null)
                CircleAvatar(
                  radius: 70, // Tăng kích thước ảnh preview
                  backgroundColor: Colors.white,
                  backgroundImage: FileImage(_selectedImage!),
                  child: _selectedImage == null ? const Icon(Icons.person, size: 60, color: Colors.grey) : null,
                ),
              const SizedBox(height: 16),
              const Text(
                "Bạn có muốn sử dụng ảnh này không?",
                style: TextStyle(color: Colors.black54, fontSize: 16), // Màu chữ tối hơn
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent, // Nút hủy màu đỏ
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // Bo góc cho nút
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 5, // Đổ bóng cho nút
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Đóng dialog preview
                        // Sau đó quay lại màn hình ProfileScreen với giá trị null (hủy chọn ảnh)
                        if (mounted) {
                          Navigator.pop(context, null);
                        }
                      },
                      child: const Text(
                        "Huỷ",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent, // Nút xác nhận màu xanh
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 5,
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Đóng dialog preview
                        // Trả về đường dẫn của ảnh đã chọn cho màn hình trước đó (ProfileScreen)
                        if (mounted) {
                          Navigator.pop(context, _selectedImage!.path);
                        }
                      },
                      child: const Text(
                        "Xác nhận",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Hàm xây dựng nút chọn ảnh (Camera/Thư viện)
  Widget _buildSelectionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color startColor,
    required Color endColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18), // Bo góc lớn hơn cho nút
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Material(
        color: Colors.transparent, // Để gradient hiện ra
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(icon, size: 30, color: Colors.white), // Icon lớn hơn, màu trắng
                  const SizedBox(width: 15),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ]),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Nền gradient toàn màn hình
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6dd5ed), Color(0xFF2193b0)], // Gradient từ xanh nhạt đến xanh đậm
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25), // Tăng padding ngang
            child: Container(
              padding: const EdgeInsets.all(30), // Tăng padding bên trong
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9), // Nền trắng hơi trong suốt
                borderRadius: BorderRadius.circular(30), // Bo góc nhiều hơn
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: const Offset(0, 8), // Đổ bóng mạnh hơn
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Cập nhật ảnh của bạn",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2193b0), // Màu chữ phù hợp với gradient nền
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  _buildSelectionButton(
                    icon: Icons.camera_alt,
                    label: "Chụp từ Camera",
                    onPressed: () => _pickImage(ImageSource.camera),
                    startColor: const Color(0xFF00C6FF),
                    endColor: const Color(0xFF0072FF),
                  ),
                  _buildSelectionButton(
                    icon: Icons.photo_library, // Icon thư viện ảnh
                    label: "Chọn từ Thư viện",
                    onPressed: () => _pickImage(ImageSource.gallery),
                    startColor: const Color(0xFFFEE140),
                    endColor: const Color(0xFFFA709A), // Gradient màu hồng cam
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
