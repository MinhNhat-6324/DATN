import 'package:flutter/material.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final List<Map<String, dynamic>> _users = [
    {
      "name": "Nguyễn Vũ Minh Nhật",
      "phone": "0306221454",
      "isLocked": false,
      "avatar": "https://cdn-icons-png.flaticon.com/512/4140/4140037.png", 
    },
    {
      "name": "Hỷ Châu Quang Phúc",
      "phone": "0306221462",
      "isLocked": true,
      "avatar": "https://cdn-icons-png.flaticon.com/512/4140/4140037.png",
    },
  ];

  void _toggleUserLock(int index) async {
    final user = _users[index];
    final bool currentLockStatus = user["isLocked"];
    final String action = currentLockStatus ? "mở" : "khóa";
    final String confirmButtonText = currentLockStatus ? "Mở" : "Khóa";

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: const Color(0xFF2193b0),
        title: Text(
          "Xác nhận ${action} tài khoản",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Bạn có chắc chắn muốn ${action} tài khoản của ${user["name"]}?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2193b0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmButtonText),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _users[index]["isLocked"] = !currentLockStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đã ${action} tài khoản của ${user["name"]}"),
          backgroundColor: const Color(0xFF00C6FF),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2280EF), Color(0xFF00FFDE)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const Spacer(),
            const Text(
              "Danh sách người dùng",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: _users.length,
          itemBuilder: (context, index) {
            final user = _users[index];
            return UserItem(
              name: user["name"],
              phone: user["phone"],
              isLocked: user["isLocked"],
              avatarUrl: user["avatar"],
              onToggleLock: () => _toggleUserLock(index),
            );
          },
        ),
      ),
    );
  }
}

class UserItem extends StatelessWidget {
  final String name;
  final String phone;
  final bool isLocked;
  final String avatarUrl;
  final VoidCallback onToggleLock;

  const UserItem({
    super.key,
    required this.name,
    required this.phone,
    required this.isLocked,
    required this.avatarUrl,
    required this.onToggleLock,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF2280EF),
              backgroundImage: NetworkImage(avatarUrl),
              onBackgroundImageError: (exception, stackTrace) {
                debugPrint('Failed to load image: $exception');
              },
              child: avatarUrl.isEmpty
                  ? Text(
                      name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phone,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFF666666)),
              onSelected: (String value) {
                if (value == 'toggleLock') {
                  onToggleLock();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'toggleLock',
                  child: Row(
                    children: [
                      Icon(isLocked ? Icons.lock_open : Icons.lock,
                          color: const Color(0xFF2193b0)),
                      const SizedBox(width: 8),
                      Text(isLocked ? 'Mở tài khoản' : 'Khóa tài khoản'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}