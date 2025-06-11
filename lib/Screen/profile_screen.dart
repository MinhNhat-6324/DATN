import 'package:flutter/material.dart';
import 'package:front_end/Screen/baiDangCuaToiScreen.dart';
import 'image_picker_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00C6FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                          'https://cdn-icons-png.flaticon.com/512/4140/4140037.png',
                        ),
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ImagePickerScreen()),
                                );
                              },
                              icon: const Icon(Icons.image, size: 18),
                              label: const Text("Đổi ảnh đại diện"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                elevation: 2,
                                textStyle: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Thông tin cá nhân
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F1E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: const [
                    _InfoRow(icon: Icons.person, text: "Nguyễn Vũ Minh Nhật"),
                    _InfoRow(icon: Icons.credit_card, text: "CDĐTH22 DĐE"),
                    _InfoRow(icon: Icons.school, text: "Công nghệ thông tin"),
                    _InfoRow(icon: Icons.badge, text: "0306221454"),
                    _InfoRow(icon: Icons.transgender, text: "Nam"),
                    _InfoRow(
                        icon: Icons.email, text: "0306221454@caothang.edu.vn"),
                    _InfoRow(
                        icon: Icons.phone_android,
                        text: "0364311716",
                        showEdit: true),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Bài viết của tôi
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  tileColor: const Color(0xFFF6F1E9),
                  leading: const Icon(Icons.article, color: Colors.black87),
                  title: const Text('Bài viết của tôi'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyPostScreen()));
                  },
                ),
              ),

              const SizedBox(height: 30),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  tileColor: const Color(0xFFF6F1E9),
                  leading:
                      const Icon(Icons.notifications, color: Colors.black87),
                  title: const Text('Thông báo'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO:
                  },
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool showEdit;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.showEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: Colors.black54),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              if (showEdit)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: () {
                    showEditPhoneDialog(context);
                  },
                ),
            ],
          ),
        ),
        const Divider(thickness: 1, height: 0, color: Colors.black12),
      ],
    );
  }
}

void showEditPhoneDialog(BuildContext context) {
  final TextEditingController phoneController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Nhập số điện thoại mới',
                  hintStyle: const TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Huỷ"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final newPhone = phoneController.text.trim();
                      // TODO: xử lý cập nhật số điện thoại
                      Navigator.of(context).pop();
                    },
                    child: const Text("Lưu số"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}
