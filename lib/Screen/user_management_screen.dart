import 'dart:async';
import 'package:flutter/material.dart';
import 'package:front_end/services/tai_khoan_service.dart';
import 'user_details_screen.dart'; // Import màn hình chi tiết người dùng
import 'package:flutter/foundation.dart'; // For debugPrint

// Màn hình chính quản lý người dùng với TabBar
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> with SingleTickerProviderStateMixin {
  final TaiKhoanService _taiKhoanService = TaiKhoanService();

  // Lists for different user statuses
  List<dynamic> _activeUsers = []; // Trang_thai = 1
  List<dynamic> _restrictedUsers = []; // Sẽ hiển thị Trang_thai = 2 (Bị khóa)

  bool _isLoadingActive = false;
  bool _isPaginatingActive = false;
  String? _errorMessageActive;

  bool _isLoadingRestricted = false; // Đổi tên từ _isLoadingPending
  bool _isPaginatingRestricted = false; // Đổi tên từ _isPaginatingPending
  String? _errorMessageRestricted; // Đổi tên từ _errorMessagePending

  int _currentPageActive = 1;
  int _lastPageActive = 1;
  int _currentPageRestricted = 1; // Đổi tên từ _currentPagePending
  int _lastPageRestricted = 1; // Đổi tên từ _lastPagePending
  final int _perPage = 10;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  final ScrollController _activeScrollController = ScrollController();
  final ScrollController _restrictedScrollController = ScrollController(); // Đổi tên từ _pendingScrollController

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);

    _fetchActiveUsers(); // Tải danh sách người dùng đang hoạt động ban đầu (trạng thái 1)
    _fetchRestrictedUsers(); // Tải danh sách người dùng bị hạn chế (trạng thái 2) ban đầu

    _activeScrollController.addListener(() {
      if (_activeScrollController.position.pixels == _activeScrollController.position.maxScrollExtent &&
          _currentPageActive < _lastPageActive &&
          !_isLoadingActive &&
          !_isPaginatingActive) {
        _loadMoreActiveUsers();
      }
    });

    _restrictedScrollController.addListener(() { // Sử dụng scroll controller mới
      if (_restrictedScrollController.position.pixels == _restrictedScrollController.position.maxScrollExtent &&
          _currentPageRestricted < _lastPageRestricted && // Sử dụng biến phân trang mới
          !_isLoadingRestricted && // Sử dụng biến loading mới
          !_isPaginatingRestricted) { // Sử dụng biến paginating mới
        _loadMoreRestrictedUsers(); // Gọi hàm loadMore mới
      }
    });
  }

  void _handleTabSelection() {
    // Refresh data when switching tabs if needed, apply search filter
    if (_tabController.indexIsChanging) {
      if (_tabController.index == 0) { // Tab "Đang hoạt động"
        _fetchActiveUsers(search: _searchController.text, page: 1);
      } else { // Tab "Hạn chế"
        _fetchRestrictedUsers(search: _searchController.text, page: 1);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _activeScrollController.dispose();
    _restrictedScrollController.dispose(); // Dispose scroll controller mới
    _tabController.dispose();
    super.dispose();
  }

  // Phương thức tải danh sách người dùng đang hoạt động (trạng thái 1)
  Future<void> _fetchActiveUsers({String? search, int page = 1}) async {
    if (page == 1) {
      if (_isLoadingActive) return;
      setState(() {
        _isLoadingActive = true;
        _errorMessageActive = null;
        _activeUsers = [];
      });
    } else {
      if (_isPaginatingActive) return;
      setState(() {
        _isPaginatingActive = true;
      });
    }

    try {
      final response = await _taiKhoanService.getAccounts( // GỌI API VỚI STATUS = 1
        search: search,
        page: page,
        perPage: _perPage,
        status: 1, // Lọc tài khoản có trạng thái = 1
      );

      setState(() {
        if (page == 1) {
          _activeUsers = response['data'];
        } else {
          _activeUsers.addAll(response['data']);
        }
        _currentPageActive = response['pagination']['current_page'];
        _lastPageActive = response['pagination']['last_page'];
      });
    } on Exception catch (e) {
      setState(() {
        _errorMessageActive = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoadingActive = false;
        _isPaginatingActive = false;
      });
    }
  }

  // Phương thức tải danh sách người dùng bị hạn chế/khóa (trạng thái 2)
  Future<void> _fetchRestrictedUsers({String? search, int page = 1}) async {
    if (page == 1) {
      if (_isLoadingRestricted) return;
      setState(() {
        _isLoadingRestricted = true;
        _errorMessageRestricted = null;
        _restrictedUsers = []; // Sử dụng list mới
      });
    } else {
      if (_isPaginatingRestricted) return;
      setState(() {
        _isPaginatingRestricted = true;
      });
    }

    try {
      final response = await _taiKhoanService.getAccounts( // GỌI API VỚI STATUS = 2
        search: search,
        page: page,
        perPage: _perPage,
        status: 2, // Lọc tài khoản có trạng thái = 2 (Bị khóa)
      );

      setState(() {
        if (page == 1) {
          _restrictedUsers = response['data']; // Cập nhật list mới
        } else {
          _restrictedUsers.addAll(response['data']); // Cập nhật list mới
        }
        _currentPageRestricted = response['pagination']['current_page'];
        _lastPageRestricted = response['pagination']['last_page'];
      });
    } on Exception catch (e) {
      setState(() {
        _errorMessageRestricted = e.toString().replaceFirst('Exception: ', ''); // Sử dụng biến error mới
      });
    } finally {
      setState(() {
        _isLoadingRestricted = false; // Sử dụng biến loading mới
        _isPaginatingRestricted = false; // Sử dụng biến paginating mới
      });
    }
  }

  Future<void> _loadMoreActiveUsers() async {
    await _fetchActiveUsers(
      search: _searchController.text,
      page: _currentPageActive + 1,
    );
  }

  Future<void> _loadMoreRestrictedUsers() async { // Hàm loadMore mới cho tab Hạn chế
    await _fetchRestrictedUsers(
      search: _searchController.text,
      page: _currentPageRestricted + 1,
    );
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_tabController.index == 0) { // Tab "Đang hoạt động"
        _fetchActiveUsers(search: query, page: 1);
      } else { // Tab "Hạn chế"
        _fetchRestrictedUsers(search: query, page: 1);
      }
    });
  }

  // Hàm refresh dữ liệu chung cho cả hai tab
  Future<void> _refreshData() async {
    if (_tabController.index == 0) {
      await _fetchActiveUsers(search: _searchController.text, page: 1);
    } else {
      await _fetchRestrictedUsers(search: _searchController.text, page: 1);
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
          "Quản lý người dùng",
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
                Color(0xFF2280EF), // Xanh đậm
                Color(0xFF2280EF), // Xanh nhạt
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
        bottom: TabBar( // Thêm TabBar vào AppBar
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
          tabs: const [
            Tab(text: 'Đang hoạt động'), // Tab hiển thị trạng thái 1
            Tab(text: 'Bị khóa'), // Tab hiển thị trạng thái 2 (Bị khóa)
          ],
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
                  color: Colors.white.withOpacity(0.9), // Giảm opacity để hòa hợp hơn với nền gradient
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1), // Bóng đổ màu đen nhẹ nhàng
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
                    hintText: "Tìm kiếm người dùng...",
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
              child: TabBarView( // Thêm TabBarView để chứa các danh sách
                controller: _tabController,
                children: [
                  _buildUserList(
                    users: _activeUsers,
                    isLoading: _isLoadingActive,
                    isPaginating: _isPaginatingActive,
                    errorMessage: _errorMessageActive,
                    scrollController: _activeScrollController,
                    onRefresh: () => _fetchActiveUsers(search: _searchController.text, page: 1),
                  ),
                  _buildUserList(
                    users: _restrictedUsers, // Sử dụng list mới cho tab Hạn chế
                    isLoading: _isLoadingRestricted, // Sử dụng biến loading mới
                    isPaginating: _isPaginatingRestricted, // Sử dụng biến paginating mới
                    errorMessage: _errorMessageRestricted, // Sử dụng biến error mới
                    scrollController: _restrictedScrollController, // Sử dụng scroll controller mới
                    onRefresh: () => _fetchRestrictedUsers(search: _searchController.text, page: 1), // Gọi hàm refresh mới
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList({
    required List<dynamic> users,
    required bool isLoading,
    required bool isPaginating,
    required String? errorMessage,
    required ScrollController scrollController,
    required Future<void> Function() onRefresh,
  }) {
    if (isLoading && users.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    } else if (users.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: const Color(0xFF2280EF),
        backgroundColor: Colors.white,
        child: const Center(
          child: Text(
            'Không tìm thấy người dùng nào.',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ),
      );
    } else {
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: const Color(0xFF2280EF),
        backgroundColor: Colors.white,
        child: ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          itemCount: users.length + (isPaginating ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == users.length) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              );
            }

            final user = users[index];
            final int trangThai = user['trang_thai'] ?? 0;
            String statusText;
            Color statusColor;
            IconData statusIcon;

            switch (trangThai) {
              case 0:
                statusText = 'Chờ duyệt'; // Trạng thái 0 là "Chờ duyệt"
                statusColor = Colors.orangeAccent;
                statusIcon = Icons.hourglass_empty;
                break;
              case 1:
                statusText = 'Đang hoạt động'; // Trạng thái 1 là "Đang hoạt động"
                statusColor = Colors.green;
                statusIcon = Icons.check_circle;
                break;
              case 2:
                statusText = 'Bị khóa'; // Trạng thái 2 là "Bị khóa"
                statusColor = Colors.redAccent;
                statusIcon = Icons.lock;
                break;
              default:
                statusText = 'Không xác định';
                statusColor = Colors.grey;
                statusIcon = Icons.info_outline;
                break;
            }

            return UserItem(
              id: user['id_tai_khoan'].toString(),
              name: user["ho_ten"] ?? 'Chưa có tên',
              phone: user["so_dien_thoai"] ?? 'N/A',
              email: user["email"] ?? 'N/A',
              statusText: statusText,
              statusColor: statusColor,
              statusIcon: statusIcon,
              avatarUrl: user["anh_dai_dien"] ?? '',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserDetailsScreen(userId: user['id_tai_khoan'].toString()),
                  ),
                );
                _refreshData();
              },
            );
          },
        ),
      );
    }
  }
}

// Widget hiển thị thông tin của từng người dùng (Không thay đổi)
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
            color: Color(0xFF00FFDE), // Màu xanh lá sáng cho viền card
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
