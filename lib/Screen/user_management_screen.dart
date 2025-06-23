import 'package:flutter/material.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  // Dữ liệu người dùng
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

  // Logic để khóa/mở khóa người dùng
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
        backgroundColor: const Color(0xFF2280EF), // Sử dụng màu gradient chính
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
              foregroundColor: const Color(0xFF2280EF), // Màu nút theo màu chính của app
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
          behavior: SnackBarBehavior.floating, // Hiển thị nổi
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Nền màu xám nhạt hiện đại hơn
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 30.0, // Đã điều chỉnh chiều cao nhỏ hơn
            floating: true,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2280EF), // Xanh đậm
                    Color(0xFF00FFDE), // Xanh nhạt
                  ],
                  begin: Alignment.topCenter, // Đổi gradient từ trên xuống
                  end: Alignment.bottomCenter,
                ),
              ),
              child: FlexibleSpaceBar(
                centerTitle: true, // Căn giữa tiêu đề
                titlePadding: const EdgeInsets.only(bottom: 5.0), // Đã điều chỉnh padding
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Đẩy các phần tử ra xa nhau
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Quay lại', // Thêm tooltip
                    ),
                    const Text(
                      "   Danh sách người dùng",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(width: 50), // Để căn chỉnh cho cân đối với nút back
                  ],
                ),
              ),
            ),
          ),

          // Danh sách người dùng
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final user = _users[index]; // Use _users directly
                return UserItem(
                  name: user["name"],
                  phone: user["phone"],
                  isLocked: user["isLocked"],
                  avatarUrl: user["avatar"],
                  onToggleLock: () => _toggleUserLock(index), // Pass the direct index
                );
              },
              childCount: _users.length, // Use _users.length directly
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20), // Khoảng trống cuối cùng
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Đã điều chỉnh padding
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          onTap: () {
            debugPrint('Tapped on user: $name');
          },
          borderRadius: BorderRadius.circular(15),
          splashColor: const Color(0xFF2280EF).withOpacity(0.1),
          highlightColor: const Color(0xFF2280EF).withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18), // Đã điều chỉnh padding
            child: Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: const Color(0xFF00FFDE),
                  backgroundImage: NetworkImage(avatarUrl),
                  onBackgroundImageError: (exception, stackTrace) {
                    debugPrint('Failed to load image: $exception');
                  },
                  child: avatarUrl.isEmpty
                      ? Text(
                          name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                              color: Color(0xFF2280EF),
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Color(0xFF333333),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phone,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                      if (isLocked)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: const [
                              Icon(Icons.lock, size: 16, color: Colors.redAccent),
                              SizedBox(width: 4),
                              Text(
                                'Đã khóa',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Nút ba chấm (menu)
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
                              color: isLocked ? const Color(0xFF2280EF) : Colors.red),
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
        ),
      ),
    );
  }
}