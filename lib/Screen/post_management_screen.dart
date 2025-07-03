import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import để định dạng thời gian
import 'package:front_end/services/bao_cao.dart'; 
import 'report_detail_screen.dart';
class PostManagementScreen extends StatefulWidget {
  const PostManagementScreen({super.key});

  @override
  State<PostManagementScreen> createState() => _PostManagementScreenState();
}

class _PostManagementScreenState extends State<PostManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<BaoCao>> _pendingBaoCaoListFuture;
  late Future<List<BaoCao>> _processedBaoCaoListFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 2 tab: Đang chờ, Đã xử lý
    _fetchBaoCaos(); // Lần đầu tải dữ liệu khi khởi tạo widget
    _tabController.addListener(() {
    if (_tabController.indexIsChanging == false) {
      // Khi chuyển tab xong → gọi lại fetch
      _fetchBaoCaos();
    }
  });
  }

  // Hàm để tải lại dữ liệu cho cả hai tab (được gọi khi cần làm mới)
  void _fetchBaoCaos() {
    setState(() {
      _pendingBaoCaoListFuture = getDanhSachBaoCao().then(
          (list) => list.where((baoCao) => baoCao.trangThai == 'dang_cho').toList());
      _processedBaoCaoListFuture = getDanhSachBaoCao().then(
          (list) => list.where((baoCao) => baoCao.trangThai == 'da_xu_ly').toList());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Nền xám nhạt hiện đại hơn
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent, // AppBar trong suốt
        elevation: 0, // Không có đổ bóng
        toolbarHeight: 50, // Tăng chiều cao của AppBar một chút
        title: const Padding(
          padding: EdgeInsets.only(top: 10.0), // Đẩy tiêu đề xuống một chút
          child: Text(
            "Quản lý báo cáo vi phạm", // Thay đổi tiêu đề cho phù hợp với việc có tab
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22, // Kích thước chữ vừa phải
            ),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(55.0), // Đảm bảo đủ không gian cho TabBar
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0), // Margin chỉ ở chiều ngang, không có vertical để sát đáy AppBar
            decoration: const BoxDecoration(
              color: Color(0xFF2280EF), // Nền màu xanh đậm của AppBar
            ),
            child: TabBar(
              controller: _tabController,
              // Indicator là đường kẻ dưới màu trắng
              indicatorColor: Colors.white, // Màu đường kẻ dưới là màu trắng
              indicatorWeight: 3.0, // Độ dày của đường kẻ dưới
              indicatorSize: TabBarIndicatorSize.tab, // Đường kẻ dưới chiếm toàn bộ chiều rộng tab
              labelColor: Colors.white, // Màu chữ của tab được chọn (trắng)
              unselectedLabelColor: Colors.white70, // Màu chữ của tab không được chọn (trắng mờ)
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
              overlayColor: MaterialStateProperty.all(Colors.transparent), // Loại bỏ hiệu ứng highlight khi chạm
              tabs: const [
                Tab(text: 'Đang chờ'),
                Tab(text: 'Đã xử lý'),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20), // Tăng padding tổng thể
        child: TabBarView( // <<< SỬ DỤNG TABBARVIEW ĐỂ HIỂN THỊ NỘI DUNG THEO TAB <<<
          controller: _tabController,
          children: [
            // Tab 1: Đang chờ
            ReportedPostList(
              baoCaoListFuture: _pendingBaoCaoListFuture, // Truyền future đã lọc
              onRefresh: _fetchBaoCaos, // Truyền callback để làm mới dữ liệu khi có thay đổi
              emptyMessage: 'Không có báo cáo nào đang chờ xử lý.',
            ),
            // Tab 2: Đã xử lý
            ReportedPostList(
              baoCaoListFuture: _processedBaoCaoListFuture, // Truyền future đã lọc
              onRefresh: _fetchBaoCaos, // Truyền callback để làm mới dữ liệu khi có thay đổi
              emptyMessage: 'Không có báo cáo nào đã được xử lý.',
            ),
          ],
        ),
      ),
    );
  }
}

// --- ReportedPostList được điều chỉnh để nhận Future và callback ---
class ReportedPostList extends StatefulWidget {
  final Future<List<BaoCao>> baoCaoListFuture; // Future chứa danh sách báo cáo
  final VoidCallback onRefresh; // Callback để yêu cầu làm mới dữ liệu từ parent
  final String emptyMessage; // Thông báo khi danh sách rỗng

  const ReportedPostList({
    super.key,
    required this.baoCaoListFuture,
    required this.onRefresh,
    required this.emptyMessage,
  });

  @override
  State<ReportedPostList> createState() => _ReportedPostListState();
}

class _ReportedPostListState extends State<ReportedPostList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BaoCao>>(
      future: widget.baoCaoListFuture, // Sử dụng future được truyền vào từ parent
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 80, color: Colors.green.withOpacity(0.6)),
                const SizedBox(height: 16),
                Text(
                  widget.emptyMessage, // Hiển thị thông báo trống được truyền vào
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else {
          final List<BaoCao> baoCaos = snapshot.data!;
          return ListView.builder(
            itemCount: baoCaos.length,
            itemBuilder: (context, index) {
              final BaoCao baoCao = baoCaos[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: ReportedPostItem(
                  baoCao: baoCao, // Truyền toàn bộ đối tượng BaoCao
                  onProcessedSuccess: widget.onRefresh, // Truyền callback để parent làm mới
                ),
              );
            },
          );
        }
      },
    );
  }
}

// --- Widget để hiển thị từng báo cáo vi phạm (Đã cập nhật icon trạng thái) ---
class ReportedPostItem extends StatelessWidget {
  final BaoCao baoCao;
  final VoidCallback onProcessedSuccess; // Callback khi xử lý thành công

  const ReportedPostItem({
    super.key,
    required this.baoCao,
    required this.onProcessedSuccess,
  });

  String _getStatusText(String? status) {
    switch (status) {
      case 'dang_cho':
        return 'Đang chờ';
      case 'da_xu_ly':
        return 'Đã xử lý';
      default:
        return 'Không rõ';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'dang_cho':
        return Colors.orange;
      case 'da_xu_ly':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Hàm tiện ích để lấy icon trạng thái (MỚI ĐƯỢC THÊM)
  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'dang_cho':
        return Icons.hourglass_empty_outlined; // Icon đồng hồ cát rỗng
      case 'da_xu_ly':
        return Icons.check_circle_outline; // Icon dấu tích tròn
      default:
        return Icons.info_outline; // Icon thông tin mặc định
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = _getStatusColor(baoCao.trangThai);
    IconData statusIcon = _getStatusIcon(baoCao.trangThai); // Lấy icon trạng thái

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.grey, width: 0.5),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailScreen( // Đảm bảo ReportDetailScreen đã được import
                baoCao: baoCao,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // Đổi thành "Báo cáo vi phạm #ID" cho rõ ràng hơn
                'Báo cáo vi phạm ', // Thêm ID của báo cáo
                style: const TextStyle(
                  color: Color(0xFF2280EF),
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.article_outlined, size: 20, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bài đăng: ${baoCao.baiDang?.tieuDe ?? 'Không có tiêu đề (ID: ${baoCao.maBaiDang})'}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_outlined, size: 20, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Lý do: ${baoCao.lyDo ?? 'Không có lý do cụ thể'}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              if (baoCao.moTaThem != null && baoCao.moTaThem!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notes, size: 20, color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mô tả thêm: ${baoCao.moTaThem}',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(statusIcon, size: 20, color: statusColor), // <<< SỬ DỤNG ICON MỚI VÀ MÀU TƯƠNG ỨNG <<<
                  const SizedBox(width: 8),
                  Text(
                    'Trạng thái: ',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(baoCao.trangThai),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_month, size: 18, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  Text(
                    'Ngày báo cáo: ${baoCao.thoiGianBaoCao != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(baoCao.thoiGianBaoCao!)) : 'Không rõ'}',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}