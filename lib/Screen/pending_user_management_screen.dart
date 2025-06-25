import 'package:flutter/material.dart';
import 'package:front_end/services/tai_khoan_service.dart'; // Import TaiKhoanService
import 'dart:async'; // Dùng cho Timer debounce
import 'user_details_screen.dart'; // Import màn hình chi tiết người dùng
import 'package:flutter/foundation.dart'; // For debugPrint

// UserItem widget - Recommended to be in a separate file (e.g., `widgets/user_item.dart`)
// If it's already in a separate file, you can remove this definition and just import it.
class UserItem extends StatelessWidget {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String statusText; // Trạng thái dạng text
  final Color statusColor; // Màu trạng thái
  final IconData statusIcon; // Icon trạng thái
  final String avatarUrl;
  final VoidCallback onTap; 
  final VoidCallback? onActivate; // Thêm callback cho nút kích hoạt nếu cần

  const UserItem({
    super.key,
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.statusText,
    required this.statusColor,
    required this.statusIcon,
    required this.avatarUrl,
    required this.onTap, 
    this.onActivate, // Có thể null
  });

  @override
  Widget build(BuildContext context) {
    final bool showDefaultAvatar = avatarUrl.isEmpty || (Uri.tryParse(avatarUrl)?.isAbsolute != true);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(
            color: Color(0xFF00C6FF), // Màu xanh sáng cho viền card
            width: 1.5, 
          ),
        ),
        elevation: 6,
        color: Colors.white.withOpacity(0.95),
        child: InkWell(
          onTap: onTap, 
          borderRadius: BorderRadius.circular(18),
          splashColor: const Color(0xFF2280EF).withOpacity(0.1),
          highlightColor: const Color(0xFF2280EF).withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
            child: Row(
              children: [
                // Avatar người dùng
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2280EF),
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    backgroundImage: showDefaultAvatar ? null : NetworkImage(avatarUrl),
                    onBackgroundImageError: showDefaultAvatar ? null : (exception, stackTrace) {
                      debugPrint('Không thể tải ảnh cho $name: $exception');
                    },
                    child: showDefaultAvatar
                        ? Text(
                            name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                            style: const TextStyle(
                                color: Color(0xFF2280EF),
                                fontWeight: FontWeight.bold,
                                fontSize: 24),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF333333),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Email: $email',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'SĐT: $phone',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                      // Hiển thị trạng thái
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Chip(
                          avatar: Icon(
                            statusIcon, 
                            size: 16,
                            color: Colors.white,
                          ),
                          label: Text(
                            statusText, 
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: statusColor, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
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

// Màn hình quản lý người dùng đang chờ duyệt
class PendingUserManagementScreen extends StatefulWidget {
  const PendingUserManagementScreen({super.key});

  @override
  State<PendingUserManagementScreen> createState() => _PendingUserManagementScreenState();
}

class _PendingUserManagementScreenState extends State<PendingUserManagementScreen> {
  final TaiKhoanService _taiKhoanService = TaiKhoanService();
  List<dynamic> _users = []; // List này sẽ chỉ chứa tài khoản trạng thái = 0
  bool _isLoading = false;
  bool _isPaginating = false;
  String? _errorMessage;

  int _currentPage = 1;
  int _lastPage = 1;
  final int _perPage = 10;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchPendingUsers(); // Gọi phương thức để lấy danh sách chờ duyệt

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
          _currentPage < _lastPage &&
          !_isLoading &&
          !_isPaginating) {
        _loadMorePendingUsers();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchPendingUsers({String? search, int page = 1}) async {
    if (page == 1) {
      if (_isLoading) return;
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _users = [];
      });
    } else {
      if (_isPaginating) return;
      setState(() {
        _isPaginating = true;
      });
    }
    
    try {
      // GỌI API getPendingAccounts để lấy riêng tài khoản chờ duyệt (trạng thái 0)
      // Phương thức này trong TaiKhoanService của bạn sẽ gửi request tới
      // /api/tai-khoan/pending endpoint, nơi đã được gán cứng để lọc trạng thái = 0.
      final response = await _taiKhoanService.getPendingAccounts(
        search: search,
        page: page,
        perPage: _perPage,
      );
      
      setState(() {
        if (page == 1) {
          _users = response['data'];
        } else {
          _users.addAll(response['data']);
        }
        _currentPage = response['pagination']['current_page'];
        _lastPage = response['pagination']['last_page'];
      });
    } on Exception catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isPaginating = false; // Đặt lại false khi hoàn thành phân trang
      });
    }
  }

  Future<void> _loadMorePendingUsers() async {
    await _fetchPendingUsers(
      search: _searchController.text,
      page: _currentPage + 1,
    );
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchPendingUsers(search: query, page: 1); // Luôn gọi lại fetch cho màn hình này
    });
  }

  // Logic để kích hoạt tài khoản
  Future<void> _activateUser(String userId, int itemIndexInList) async {
    final String userName = _users[itemIndexInList]['ho_ten'] ?? 'người dùng này';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        title: const Text(
          "Xác nhận kích hoạt tài khoản",
          style: TextStyle(
              color: Color(0xFF2280EF), fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Bạn có chắc chắn muốn kích hoạt tài khoản của $userName?",
          style: const TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2280EF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Kích hoạt"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true; // Hiển thị loading cho màn hình này
      });
      try {
        await _taiKhoanService.updateAccountStatus(userId, 1); // Đặt trạng thái về 1 (kích hoạt)
        
        setState(() {
          _users.removeAt(itemIndexInList); // Xóa khỏi danh sách UI vì đã được kích hoạt
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Đã kích hoạt tài khoản của $userName thành công!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      } on Exception catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi khi kích hoạt tài khoản: ${e.toString().replaceFirst('Exception: ', '')}"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false; // Tắt loading
        });
      }
    }
  }

  // Widget chung để hiển thị trạng thái loading/error/empty cho PendingUserManagementScreen
  Widget _buildListContent() {
    if (_isLoading && _users.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    } else if (_users.isEmpty) {
      // Khi không có người dùng và không lỗi, hiển thị thông báo rỗng kèm RefreshIndicator
      return RefreshIndicator(
        onRefresh: () => _fetchPendingUsers(search: _searchController.text, page: 1),
        color: const Color(0xFF2280EF),
        backgroundColor: Colors.white,
        child: const Center(
          child: SingleChildScrollView( // Sử dụng SingleChildScrollView để có thể kéo xuống refresh
            physics: AlwaysScrollableScrollPhysics(), // Luôn cho phép cuộn để refresh
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Không tìm thấy người dùng nào chờ duyệt.', // Thông báo rõ ràng
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ),
          ),
        ),
      );
    } else {
      // Hiển thị danh sách người dùng khi có dữ liệu
      return RefreshIndicator(
        onRefresh: () => _fetchPendingUsers(search: _searchController.text, page: 1),
        color: const Color(0xFF2280EF),
        backgroundColor: Colors.white,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          itemCount: _users.length + (_isPaginating ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _users.length) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              );
            }

            final user = _users[index];
            // Trong màn hình này, trạng thái luôn là "Chờ duyệt" (trạng thái 0)
            const String statusText = 'Chờ duyệt'; 
            const Color statusColor = Colors.orangeAccent;
            const IconData statusIcon = Icons.hourglass_empty;
            
            return UserItem(
              id: user['id_tai_khoan'].toString(),
              name: user["ho_ten"] ?? 'Chưa có tên',
              phone: user["so_dien_thoai"] ?? 'N/A',
              email: user["email"] ?? 'N/A',
              statusText: statusText,
              statusColor: statusColor,
              statusIcon: statusIcon,
              avatarUrl: user["anh_dai_dien"] ?? '',
              onActivate: () => _activateUser(user['id_tai_khoan'].toString(), index),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserDetailsScreen(userId: user['id_tai_khoan'].toString()),
                  ),
                );
                // Sau khi quay về từ chi tiết, làm mới danh sách chờ duyệt
                _fetchPendingUsers(search: _searchController.text, page: 1);
              },
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Tài khoản chờ duyệt", // Tiêu đề rõ ràng cho màn hình này
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2280EF),
                Color(0xFF2280EF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2280EF), Color(0xFF00C6FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: Color(0xFF333333)),
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm người dùng chờ duyệt...",
                    hintStyle: const TextStyle(color: Color(0xFF999999)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF2280EF)),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color(0xFF2280EF), width: 2),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _buildListContent(), // Sử dụng hàm build content để hiển thị danh sách
            ),
            const SizedBox(height: 20), // Khoảng trống cuối cùng
          ],
        ),
      ),
    );
  }
}
