import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:front_end/services/bao_cao.dart'; // Đảm bảo import đúng đường dẫn của model BaoCao và các hàm API
import 'package:front_end/services/buildImage.dart'; // Import hàm buildImageUrl của bạn
import 'package:front_end/services/loai_san_pham_service.dart'; // Import file chứa LoaiSanPham và getDanhSachLoai()
import 'package:front_end/services/chuyen_nganh_san_pham_service.dart'; // IMPORT DỊCH VỤ CHUYÊN NGÀNH
import 'package:front_end/model/chuyen_nganh_item.dart'; // IMPORT MODEL CHUYÊN NGÀNH

class ReportDetailScreen extends StatefulWidget {
  final BaoCao baoCao;

  const ReportDetailScreen({
    super.key,
    required this.baoCao,
  });

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  String? selectedImageUrl;
  List<LoaiSanPham> _listLoaiSanPham = [];
  bool _isLoadingLoai = true;

  List<ChuyenNganhItem> _listChuyenNganh = [];
  bool _isLoadingNganh = true;
  final ChuyenNganhSanPhamService _chuyenNganhService = ChuyenNganhSanPhamService(); // Instance của service

  late BaoCao _currentBaoCao; // Sử dụng late để khởi tạo trong initState

  @override
  void initState() {
    super.initState();
    _currentBaoCao = widget.baoCao; // Khởi tạo _currentBaoCao từ widget.baoCao ban đầu

    if (_currentBaoCao.baiDang != null && _currentBaoCao.baiDang!.anhBaiDang != null && _currentBaoCao.baiDang!.anhBaiDang!.isNotEmpty) {
      selectedImageUrl = buildImageUrl(_currentBaoCao.baiDang!.anhBaiDang![0]);
    }
    _fetchLoaiSanPham();
    _fetchChuyenNganh();
  }

  Future<void> _fetchLoaiSanPham() async {
    try {
      final List<LoaiSanPham> fetchedList = await getDanhSachLoai();
      if (mounted) {
        setState(() {
          _listLoaiSanPham = fetchedList;
          _isLoadingLoai = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi khi tải danh sách loại sản phẩm: $e');
      if (mounted) {
        setState(() {
          _isLoadingLoai = false;
        });
      }
    }
  }

  Future<void> _fetchChuyenNganh() async {
    try {
      final List<ChuyenNganhItem> fetchedList = await _chuyenNganhService.fetchAllChuyenNganh();
      if (mounted) {
        setState(() {
          _listChuyenNganh = fetchedList;
          _isLoadingNganh = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi khi tải danh sách chuyên ngành: $e');
      if (mounted) {
        setState(() {
          _isLoadingNganh = false;
        });
      }
    }
  }

  String _getLoaiName(int? idLoai) {
    if (idLoai == null) return 'Không rõ';
    if (_isLoadingLoai) return 'Đang tải...';

    final loai = _listLoaiSanPham.firstWhere(
      (element) => element.id == idLoai,
      orElse: () => LoaiSanPham(id: idLoai, tenLoai: 'Không tìm thấy ($idLoai)'),
    );
    return loai.tenLoai;
  }

  String _getNganhName(int? idNganh) {
    if (idNganh == null) return 'Không rõ';
    if (_isLoadingNganh) return 'Đang tải...';

    final nganh = _listChuyenNganh.firstWhere(
      (element) => element.id == idNganh,
      orElse: () => ChuyenNganhItem(id: idNganh, name: 'Không tìm thấy ($idNganh)'),
    );
    return nganh.name;
  }

  // <<<<<< HÀM XỬ LÝ KHI NHẤN NÚT "GỠ BÀI ĐĂNG" >>>>>>
  Future<void> _handleGoBaiDang() async {
    // Chỉ cho phép xử lý nếu báo cáo đang chờ
    if (_currentBaoCao.trangThai != 'dang_cho') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Báo cáo này đã được xử lý.')),
      );
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
           title: Text(
          "Xác nhận gỡ bài đăng",
          style: const TextStyle(
              color: Color(0xFF2280EF), fontWeight: FontWeight.bold),
        ),
          content: const Text('Bạn có chắc chắn muốn gỡ bài đăng này không?',style: const TextStyle(color: Colors.black87)),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hủy'),
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
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Xác nhận"),)
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        // Gọi API để gỡ bài đăng và duyệt báo cáo
        bool success = await goBaiDangBaoCao(_currentBaoCao.id);

        if (success) {
          // Cập nhật trạng thái báo cáo và trạng thái bài đăng trên UI
          // Tạo một đối tượng BaoCao mới với trạng thái cập nhật
          setState(() {
            _currentBaoCao = BaoCao(
              id: _currentBaoCao.id,
              maBaiDang: _currentBaoCao.maBaiDang,
              idTaiKhoanBaoCao: _currentBaoCao.idTaiKhoanBaoCao,
              lyDo: _currentBaoCao.lyDo,
              moTaThem: _currentBaoCao.moTaThem,
              thoiGianBaoCao: _currentBaoCao.thoiGianBaoCao,
              trangThai: 'da_xu_ly', // Trạng thái báo cáo chuyển sang "da__xu_ly"
              baiDang: _currentBaoCao.baiDang?.copyWith(trangThai: 'vi_pham'), // Cập nhật trạng thái bài đăng
              nguoiBaoCao: _currentBaoCao.nguoiBaoCao,
            );
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Bài đăng đã được gỡ!',
            style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),),
          );
          // Quay về màn hình trước đó, có thể truyền kết quả về nếu cần
          Navigator.pop(context, true); // True để báo hiệu có thay đổi
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể gỡ bài đăng. Vui lòng thử lại.')),
          );
        }
      } catch (e) {
        debugPrint('Lỗi khi gọi API gỡ bài đăng: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi: ${e.toString()}')),
        );
      }
    }
  }

  // <<<<<< HÀM XỬ LÝ KHI NHẤN NÚT "TỪ CHỐI BÁO CÁO" >>>>>>
  Future<void> _handleTuChoiBaoCao() async {
    // Chỉ cho phép xử lý nếu báo cáo đang chờ
    if (_currentBaoCao.trangThai != 'dang_cho') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Báo cáo này đã được xử lý.')),
      );
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
          "Xác nhận từ chối báo cáo",
          style: const TextStyle(
              color: Color(0xFF2280EF), fontWeight: FontWeight.bold),
        ),
          content: const Text('Bạn có chắc chắn muốn từ chối báo cáo này không?',style: const TextStyle(color: Colors.black87),),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hủy'),
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
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Xác nhận"),
          ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        // Gọi API để từ chối báo cáo
        bool success = await tuChoiBaoCao(_currentBaoCao.id);

        if (success) {
          // Cập nhật trạng thái báo cáo trên UI
          setState(() {
            _currentBaoCao = BaoCao(
              id: _currentBaoCao.id,
              maBaiDang: _currentBaoCao.maBaiDang,
              idTaiKhoanBaoCao: _currentBaoCao.idTaiKhoanBaoCao,
              lyDo: _currentBaoCao.lyDo,
              moTaThem: _currentBaoCao.moTaThem,
              thoiGianBaoCao: _currentBaoCao.thoiGianBaoCao,
              trangThai: 'da_xu_ly', // Trạng thái báo cáo chuyển sang "da_xu_ly"
              baiDang: _currentBaoCao.baiDang, // Bài đăng giữ nguyên
              nguoiBaoCao: _currentBaoCao.nguoiBaoCao,
            );
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Đã từ chối báo cáo!',
            style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),),
          );
          // Quay về màn hình trước đó
          Navigator.pop(context, true); // True để báo hiệu có thay đổi
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể từ chối báo cáo. Vui lòng thử lại.')),
          );
        }
      } catch (e) {
        debugPrint('Lỗi khi gọi API từ chối báo cáo: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi: ${e.toString()}')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final BaoCao baoCao = _currentBaoCao; // Sử dụng _currentBaoCao
    final BaiDang? baiDang = baoCao.baiDang;
    final size = MediaQuery.of(context).size;

    String currentMainImageUrl;
    if (selectedImageUrl != null && selectedImageUrl!.isNotEmpty) {
      currentMainImageUrl = selectedImageUrl!;
    } else if (baiDang != null && baiDang.anhBaiDang != null && baiDang.anhBaiDang!.isNotEmpty) {
      currentMainImageUrl = buildImageUrl(baiDang.anhBaiDang![0]);
    } else {
      currentMainImageUrl = "https://via.placeholder.com/150";
    }

    // Xác định xem các nút có nên được hiển thị hay không
    final bool canProcessReport = baoCao.trangThai == 'dang_cho';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2280EF),
        title: const Text(
          'Chi tiết báo cáo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.03),
              _buildMainImage(currentMainImageUrl, size),
              SizedBox(height: size.height * 0.03),
              if (baiDang != null && baiDang.anhBaiDang != null && baiDang.anhBaiDang!.isNotEmpty)
                _buildImageGallery(baiDang.anhBaiDang!),
              SizedBox(height: size.height * 0.03),

              // 1. Thẻ thông tin bài đăng bị báo cáo
              if (baiDang != null)
                _buildInfoCard(
                  title: 'Thông tin bài đăng bị báo cáo',
                  children: [
                    _buildInfoRow('Tiêu đề:', baiDang.tieuDe ?? 'Không có'),
                    _buildInfoRow(
                      'Giá:',
                      baiDang.gia != null
                          ? '${NumberFormat('#,##0').format(double.parse(baiDang.gia!))} VNĐ'
                          : 'Không có',
                    ),
                    _buildInfoRow('Độ mới:', baiDang.doMoi != null
                        ? '${baiDang.doMoi}%'
                        : 'Không rõ'),
                    _buildInfoRow(
                      'Loại:',
                      _getLoaiName(baiDang.idLoai),
                    ),
                    _buildInfoRow(
                      'Ngành:',
                      _getNganhName(baiDang.idNganh),
                    ),
                    _buildInfoRow(
                      'Ngày đăng:',
                      baiDang.ngayDang != null
                          ? DateFormat('dd/MM/yyyy').format(
                              DateTime.parse(baiDang.ngayDang!).toLocal(),
                            )
                          : 'Không rõ',
                    ),
                  ],
                ),
              if (baiDang == null)
                _buildInfoCard(
                  title: 'Thông tin bài đăng bị báo cáo',
                  children: [
                    _buildInfoRow('Bài đăng:', 'Bài đăng đã bị xóa hoặc không tìm thấy.'),
                  ],
                ),

              const SizedBox(height: 20),
              // 3. Thẻ thông tin báo cáo
              _buildInfoCard(
                title: 'Thông tin báo cáo',
                children: [
                  _buildInfoRow('Lý do:', baoCao.lyDo ?? 'Không có'),
                  _buildInfoRow('Mô tả thêm:', baoCao.moTaThem ?? 'Không có'),
                  _buildInfoRow(
                    'Thời gian:',
                    baoCao.thoiGianBaoCao != null
                        ? DateFormat('dd/MM/yyyy').format(
                            DateTime.parse(baoCao.thoiGianBaoCao!).toLocal(),
                          )
                        : 'Không rõ',
                  ),
                  _buildStatusRow(baoCao.trangThai),
                ],
              ),
              const SizedBox(height: 40),

              // <<<<<< PHẦN HIỂN THỊ NÚT XỬ LÝ TRẠNG THÁI >>>>>>
              if (canProcessReport) // Chỉ hiển thị các nút khi báo cáo đang chờ
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _handleGoBaiDang,
                          icon: const Icon(Icons.delete_forever_outlined, color: Colors.white),
                          label: const Text(
                            'Gỡ bài đăng',
                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600, // Màu đỏ cho hành động gỡ
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _handleTuChoiBaoCao,
                          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                          label: const Text(
                            'Từ chối báo cáo',
                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600, // Màu xanh cho hành động từ chối
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Các hàm hỗ trợ (không thay đổi logic hiển thị) ---
  Widget _buildMainImage(String imageUrl, Size size) {
    return Container(
      width: size.width * 0.7,
      height: size.width * 0.7 * (4 / 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.image, size: 80, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery(List<String> imageUrls) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: imageUrls.map((url) {
            final fullUrl = buildImageUrl(url);
            return GestureDetector(
              onTap: () => setState(() => selectedImageUrl = fullUrl),
              child: _buildSmallImage(fullUrl),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,  
              color: Color(0xFF0079CF),
            ),
          ),
          const Divider(height: 20, thickness: 1, color: Colors.grey),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String? status) {
    String statusText = '';
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.info_outline;

    switch (status) {
      case 'dang_cho':
        statusText = 'Đang chờ';
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty_outlined;
        break;
      case 'da_xu_ly':
        statusText = 'Đã xử lý';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      default:
        statusText = 'Không rõ';
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          const SizedBox(
            width: 120,
            child: Text(
              'Trạng thái:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
          Icon(statusIcon, size: 20, color: statusColor),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallImage(String imageUrl) {
    final isSelected = selectedImageUrl == imageUrl;
    return Container(
      width: 90,
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Center(child: Icon(Icons.broken_image)),
        ),
      ),
    );
  }
}

// <<<< Cần thêm copyWith vào model BaiDang nếu bạn muốn cập nhật một cách immutable >>>>
extension BaiDangCopyWith on BaiDang {
  BaiDang copyWith({
    int? id,
    int? idTaiKhoan,
    String? tieuDe,
    int? doMoi,
    int? idLoai,
    int? idNganh,
    String? gia,
    String? ngayDang,
    String? trangThai,
    String? noiDung,
    List<String>? anhBaiDang,
  }) {
    return BaiDang(
      id: id ?? this.id,
      idTaiKhoan: idTaiKhoan ?? this.idTaiKhoan,
      tieuDe: tieuDe ?? this.tieuDe,
      doMoi: doMoi ?? this.doMoi,
      idLoai: idLoai ?? this.idLoai,
      idNganh: idNganh ?? this.idNganh,
      gia: gia ?? this.gia,
      ngayDang: ngayDang ?? this.ngayDang,
      trangThai: trangThai ?? this.trangThai,
      noiDung: noiDung ?? this.noiDung,
      anhBaiDang: anhBaiDang ?? this.anhBaiDang,
    );
  }
}

// <<<< Cần thêm copyWith vào model BaoCao nếu bạn muốn cập nhật một cách immutable >>>>
extension BaoCaoCopyWith on BaoCao {
  BaoCao copyWith({
    int? id,
    int? maBaiDang,
    int? idTaiKhoanBaoCao,
    String? lyDo,
    String? moTaThem,
    String? thoiGianBaoCao,
    String? trangThai,
    BaiDang? baiDang,
    TaiKhoan? nguoiBaoCao,
  }) {
    return BaoCao(
      id: id ?? this.id,
      maBaiDang: maBaiDang ?? this.maBaiDang,
      idTaiKhoanBaoCao: idTaiKhoanBaoCao ?? this.idTaiKhoanBaoCao,
      lyDo: lyDo ?? this.lyDo,
      moTaThem: moTaThem ?? this.moTaThem,
      thoiGianBaoCao: thoiGianBaoCao ?? this.thoiGianBaoCao,
      trangThai: trangThai ?? this.trangThai,
      baiDang: baiDang ?? this.baiDang,
      nguoiBaoCao: nguoiBaoCao ?? this.nguoiBaoCao,
    );
  }
}