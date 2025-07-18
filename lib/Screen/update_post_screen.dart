import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:front_end/model/chuyen_nganh_service.dart';
import 'package:front_end/model/loai_san_pham_service.dart';
import 'package:front_end/model/bai_dang_service.dart';
import 'package:front_end/services/buildImage.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UpdatePostScreen extends StatefulWidget {
  final int idNguoiDung;
  final BaiDang baiDang;

  const UpdatePostScreen({
    super.key,
    required this.idNguoiDung,
    required this.baiDang,
  });

  @override
  State<UpdatePostScreen> createState() => _UpdatePostScreenState();
}

class _UpdatePostScreenState extends State<UpdatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  // Khởi tạo và dispose các controller trong initState/dispose
  final int currentYear = DateTime.now().year;
  late final List<int> namXuatBanOptions =
      List.generate(8, (index) => currentYear - index);
  LoaiSanPham? _selectedLoai;
  String? _selectedLop;
  int? _selectedNamXuatBan;

  late TextEditingController titleController;
  late TextEditingController conditionController;
  late TextEditingController lopChuyenNganhController;
  late TextEditingController namXuatBanController;
  final List<String> lopChuyenNganhOptions = [
    'CĐ Ngành',
    'CĐ Nghề',
  ];

  List<Nganh> danhSachNganh = [];
  List<LoaiSanPham> danhSachLoai = [];
  Nganh? _selectedNganh;
  int _sliderValue = 99;
  String? _selectedLopChuyenNganh;
  final List<File> _capturedImages = [];
  final List<String> _existingImageUrls = [];
  final List<String> _deletedImageUrls = [];
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.baiDang.tieuDe);
    namXuatBanController = TextEditingController(
        text: widget.baiDang.namXuatBan?.toString() ?? currentYear.toString());

    _sliderValue = widget.baiDang.doMoi ?? 100;
    _selectedLopChuyenNganh = widget.baiDang.lopChuyenNganh ?? 'CĐ Ngành';

    // Xử lý ảnh cũ
    if (widget.baiDang.anhBaiDang.isNotEmpty) {
      for (var e in widget.baiDang.anhBaiDang) {
        _existingImageUrls.add(buildImageUrl(e.duongDan));
      }
    }

    _loadDropdownData();
  }

  Map<int, List<Map<String, dynamic>>> danhSachDoMoiTheoLoai = {
    1: [
      // 📘 Sách giáo trình
      {'percent': '100', 'desc': 'Mới tinh, chưa sử dụng'},
      {'percent': '90', 'desc': 'Gần như mới, không rách'},
      {'percent': '70', 'desc': 'Đã sử dụng, có vết gấp nhẹ'},
      {'percent': '50', 'desc': 'Cũ, tróc bìa nhẹ hoặc ố màu'},
      {'percent': '30', 'desc': 'Hư nhẹ, rách vài trang'},
      {'percent': '10', 'desc': 'Hư nặng, chỉ tham khảo'},
    ],
    2: [
      // 🛠️ Dụng cụ
      {'percent': '100', 'desc': 'Chưa sử dụng, còn nguyên bao bì'},
      {'percent': '90', 'desc': 'Ít dùng, còn mới'},
      {'percent': '70', 'desc': 'Đã sử dụng, hoạt động tốt'},
      {'percent': '50', 'desc': 'Có trầy xước nhẹ'},
      {'percent': '30', 'desc': 'Cũ, mòn hoặc có lỗi nhỏ'},
      {'percent': '10', 'desc': 'Cũ nặng, dùng tạm'},
    ],
    3: [
      // 📄 Tài liệu học tập
      {'percent': '100', 'desc': 'Bản in rõ nét, chưa sử dụng'},
      {'percent': '90', 'desc': 'Gần như mới, sạch sẽ'},
      {'percent': '70', 'desc': 'Đã sử dụng, gấp góc nhẹ'},
      {'percent': '50', 'desc': 'Bị lem mực hoặc rách nhẹ'},
      {'percent': '30', 'desc': 'Thiếu vài trang, vẫn đọc được'},
      {'percent': '10', 'desc': 'Mất nhiều nội dung, chỉ tham khảo'},
    ],
  };

  Widget _buildDropdownDoMoi() {
    final idLoai = _selectedLoai?.id ?? 1;
    final danhSach = danhSachDoMoiTheoLoai[idLoai] ?? [];

    return DropdownButtonFormField<int>(
      value: _sliderValue,
      items: danhSach
          .map((item) => DropdownMenuItem<int>(
                value: int.parse(item['percent']!),
                child: Text(
                  '${item['percent']}% - ${item['desc']}',
                  overflow: TextOverflow.ellipsis, // CẮT TEXT nếu quá dài
                  maxLines: 1, // Giới hạn 1 dòng
                ),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _sliderValue = value!;
        });
      },
      decoration: InputDecoration(
        border: _inputBorder(),
        enabledBorder: _inputBorder(),
        focusedBorder: _inputBorder(color: const Color(0xFF0079CF)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
      ),
      isExpanded: true, // GIÃN dropdown để tránh tràn
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0079CF)),
    );
  }

  String _getMoTaDoMoi(int value) {
    if (value >= 90) return 'Gần như mới, còn rất tốt';
    if (value >= 70) return 'Còn sử dụng tốt, có vài vết nhẹ';
    if (value >= 50) return 'Đã qua sử dụng nhiều, bị tróc nhẹ';
    if (value >= 30) return 'Hơi cũ, rách/móp nhẹ, mất một số trang/bìa';
    if (value >= 10) return 'Cũ nặng, mất trang hoặc bìa, dùng để tham khảo';
    return 'Hư hỏng nhiều, chỉ tham khảo phần còn lại';
  }

  @override
  void dispose() {
    // Gọi dispose cho tất cả controllers
    titleController.dispose();
    conditionController.dispose();
    super.dispose();
    lopChuyenNganhController.dispose();
    namXuatBanController.dispose();
  }

  Future<void> _luuBaiDang() async {
    if (!_formKey.currentState!.validate()) return;

    final tieuDe = titleController.text.trim();
    final doMoi = _sliderValue;

    final idLoai = _selectedLoai?.id;
    final idNganh = _selectedNganh?.id;

    if (idLoai == null || idNganh == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Vui lòng chọn đầy đủ ngành và loại sản phẩm')),
        );
      }
      return;
    }
    if (_existingImageUrls.length + _capturedImages.length < 2) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❗ Bài đăng cần ít nhất 2 ảnh'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
            child: CircularProgressIndicator(color: Color(0xFF0079CF))),
      );
    }

    final success = await updateBaiDang(
      idBaiDang: widget.baiDang.id!,
      tieuDe: titleController.text.trim(),
      doMoi: _sliderValue,
      idLoai: _selectedLoai!.id,
      idNganh: _selectedNganh!.id,
      hinhAnhMoi: _capturedImages,
      hinhAnhCanXoa: _deletedImageUrls,
      lopChuyenNganh: _selectedLopChuyenNganh!,
      namXuatBan: int.tryParse(namXuatBanController.text) ?? currentYear,
    );

    if (context.mounted) {
      Navigator.pop(context); // Dismiss loading dialog
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Cập nhật bài viết thành công!',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true); // Go back and indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Cập nhật bài viết thất bại. Vui lòng thử lại.',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadDropdownData() async {
    try {
      final nganhData = await getDanhSachNganh();
      final loaiData = await getDanhSachLoai();
      if (mounted) {
        setState(() {
          danhSachNganh = nganhData;
          danhSachLoai = loaiData;
          // Set initial selected values, with fallback to first if not found
          _selectedNganh = danhSachNganh.firstWhere(
            (e) => e.id == widget.baiDang.idNganh,
            orElse: () => danhSachNganh.isNotEmpty
                ? danhSachNganh.first
                : throw Exception('No nganh data'), // Handle empty list
          );
          _selectedLoai = danhSachLoai.firstWhere(
            (e) => e.id == widget.baiDang.idLoai,
            orElse: () => danhSachLoai.first,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _capturedImages.add(File(image.path)));
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() => _capturedImages.add(File(photo.path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Chỉnh sửa bài đăng',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // Remove shadow
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0079CF), Color(0xFF00C6FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Ngành'),
              const SizedBox(height: 8), // Added spacing
              Card(
                margin: EdgeInsets.zero,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: _buildDropdownButtonFormField<Nganh>(
                  value: _selectedNganh,
                  items: danhSachNganh,
                  getLabel: (nganh) => nganh.tenNganh,
                  onChanged: (Nganh? newVal) =>
                      setState(() => _selectedNganh = newVal),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Loại sản phẩm'),
              const SizedBox(height: 8), // Added spacing
              Card(
                margin: EdgeInsets.zero,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: _buildDropdownButtonFormField<LoaiSanPham>(
                  value: _selectedLoai,
                  items: danhSachLoai,
                  getLabel: (loai) => loai.tenLoai,
                  onChanged: (LoaiSanPham? newVal) =>
                      setState(() => _selectedLoai = newVal),
                ),
              ),

              const SizedBox(
                  height: 20), // Increased spacing // Increased spacing
              _buildSectionTitle('Tiêu đề bài viết'),
              const SizedBox(height: 8), // Added spacing
              Card(
                margin: EdgeInsets.zero, // Remove default card margin
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: _buildTextFormField(
                  controller: titleController,
                  hintText: 'Tiêu đề (tên sản phẩm...)',
                  validator: (value) => (value == null || value.isEmpty)
                      ? '❗ Tiêu đề không được để trống'
                      : null,
                ),
              ),
              const SizedBox(height: 20), // Increased spacing

              _buildSectionTitle('Độ mới sản phẩm'),
              const SizedBox(height: 8),
              _buildDropdownDoMoi(),
              const SizedBox(height: 20),

              if (_selectedLoai?.id == 1) ...[
                _buildSectionTitle("Hệ đào tạo"),
                _buildDropdownButtonFormField<String>(
                  value: _selectedLopChuyenNganh,
                  items: lopChuyenNganhOptions,
                  getLabel: (lop) => lop,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLopChuyenNganh = newValue!;
                    });
                  },
                ),
                _buildSectionTitle("Năm xuất bản"),
                const SizedBox(height: 20),
                _buildGridNamXuatBan(),
              ],

              _buildSectionTitle('Ảnh đã có và ảnh mới'),
              const SizedBox(height: 12), // Adjusted spacing
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 4 : 3,
                  crossAxisSpacing: 12, // Increased spacing
                  mainAxisSpacing: 12, // Increased spacing
                  childAspectRatio: 1,
                ),
                itemCount:
                    _existingImageUrls.length + _capturedImages.length + 1,
                itemBuilder: (context, index) {
                  if (index ==
                      _existingImageUrls.length + _capturedImages.length) {
                    return GestureDetector(
                      onTap: _showImageSourceActionSheet,
                      child: _buildAddImageTile(),
                    );
                  } else if (index < _existingImageUrls.length) {
                    return _buildImageTile(
                        _existingImageUrls[index], true, index);
                  } else {
                    return _buildImageTile(
                      _capturedImages[index - _existingImageUrls.length],
                      false,
                      index - _existingImageUrls.length,
                    );
                  }
                },
              ),
              const SizedBox(height: 30), // Increased spacing for button

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _luuBaiDang,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0056D2), // Darker blue
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12)), // More rounded
                    shadowColor: Colors.black26, // Add shadow
                    elevation: 8, // Increase elevation
                  ),
                  child: const Text('Lưu bài viết',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 19, // Slightly larger font
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageTile(dynamic image, bool isOld, int index) => Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: isOld
                ? Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, url, error) {
                      print('[ERROR] Không thể tải ảnh: $url - $error');
                      return Image.network(
                        'https://cdn-icons-png.flaticon.com/512/4140/4140037.png',
                        fit: BoxFit.cover,
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      // Trả luôn ảnh mặc định thay vì vòng xoay
                      return Image.network(
                        'https://cdn-icons-png.flaticon.com/512/4140/4140037.png',
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.file(image, fit: BoxFit.cover),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => setState(() {
                if (isOld) {
                  final fullUrl = _existingImageUrls[index];
                  final fileName = Uri.parse(fullUrl).pathSegments.last;
                  _deletedImageUrls.add(fileName);
                  _existingImageUrls.removeAt(index);
                } else {
                  _capturedImages.removeAt(index);
                }
              }),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      );

  Widget _buildTextFormField({
    required TextEditingController controller,
    String? hintText,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) =>
      TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hintText,
          border: _inputBorder(),
          enabledBorder: _inputBorder(),
          focusedBorder: _inputBorder(color: const Color(0xFF0079CF)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: true,
          fillColor: Colors.white,
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    String? suffixText,
    List<TextInputFormatter>? inputFormatters,
  }) =>
      // Container removed as Card now handles BoxDecoration
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hintText,
          suffixText: suffixText,
          suffixStyle: const TextStyle(
              color: Colors.grey, fontSize: 16), // Style for suffix
          border: _inputBorder(),
          enabledBorder: _inputBorder(), // Apply border to enabled state
          focusedBorder: _inputBorder(
              color: const Color(0xFF0079CF)), // Highlight on focus
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14), // More vertical padding
          filled: true,
          fillColor: Colors.white, // Explicitly white background
        ),
      );

  Widget _buildDropdownButtonFormField<T>({
    required T? value,
    required List<T> items,
    required String Function(T) getLabel,
    required ValueChanged<T?> onChanged,
  }) =>
      // Container removed as Card now handles BoxDecoration
      DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          border: _inputBorder(),
          enabledBorder: _inputBorder(), // Apply border to enabled state
          focusedBorder: _inputBorder(
              color: const Color(0xFF0079CF)), // Highlight on focus
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14), // More vertical padding
          filled: true,
          fillColor: Colors.white, // Explicitly white background
        ),
        items: items
            .map((T item) =>
                DropdownMenuItem<T>(value: item, child: Text(getLabel(item))))
            .toList(),
        onChanged: onChanged,
        isExpanded: true, // Make dropdown take full width
        icon: const Icon(Icons.arrow_drop_down,
            color: Color(0xFF0079CF)), // Themed icon
      );

  OutlineInputBorder _inputBorder(
          {Color color = Colors.transparent}) => // Default to transparent
      OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(10), // More rounded for input fields
        borderSide: BorderSide(color: color, width: 1.0), // Add a subtle border
      );

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0, top: 0), // Adjust padding
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 17, // Slightly larger font
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
      );

  Widget _buildAddImageTile() => Container(
        decoration: BoxDecoration(
          color: Colors.grey[100], // Lighter grey
          borderRadius: BorderRadius.circular(10), // More rounded
          border: Border.all(
              color: Colors.grey.shade300,
              width: 1.5), // Thinner, lighter border
        ),
        child: const Center(
          child: Icon(Icons.add_a_photo,
              color: Colors.grey, size: 45), // Larger icon
        ),
      );
  Widget _buildGridNamXuatBan() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: namXuatBanOptions.map((nam) {
        final isSelected = int.tryParse(namXuatBanController.text ?? '') == nam;

        return GestureDetector(
          onTap: () {
            setState(() => namXuatBanController.text = nam.toString());
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFF0079CF) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Color(0xFF0079CF) : Colors.grey.shade300,
              ),
            ),
            child: Text(
              nam.toString(),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showImageSourceActionSheet() => showModalBottomSheet(
        context: context,
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF0079CF)),
                title:
                    const Text('Chụp ảnh mới', style: TextStyle(fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: Color(0xFF0079CF)),
                title: const Text('Chọn từ thư viện',
                    style: TextStyle(fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
            ],
          ),
        ),
      );
}

// Custom TextInputFormatter to limit percentage input to 0-100
class _PercentageRangeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    int? parsedValue = int.tryParse(newValue.text);
    if (parsedValue == null) {
      return oldValue; // Keep old value if not a valid number
    }
    if (parsedValue < 0) {
      return const TextEditingValue(text: '0'); // Don't allow less than 0
    }
    if (parsedValue > 100) {
      return const TextEditingValue(text: '100'); // Don't allow more than 100
    }
    return newValue;
  }
}
