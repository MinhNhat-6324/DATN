import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:front_end/model/bai_dang_service.dart';
import 'package:front_end/model/chuyen_nganh_service.dart';
import 'package:front_end/model/loai_san_pham_service.dart';
import 'package:front_end/services/tai_khoan_service.dart';

class PostScreen extends StatefulWidget {
  final String userId;

  const PostScreen({super.key, required this.userId});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController conditionController = TextEditingController(text: '99');

  List<Nganh> danhSachNganh = [];
  List<LoaiSanPham> danhSachLoai = [];
  Nganh? _selectedNganh;
  LoaiSanPham? _selectedLoai;

  final List<File> _capturedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool _coTheDangBai = false;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
    _kiemTraTrangThaiTaiKhoan();
  }

  Future<void> _kiemTraTrangThaiTaiKhoan() async {
    try {
      final taiKhoanData = await TaiKhoanService().getAccountById(widget.userId);
      debugPrint('Dữ liệu tài khoản: $taiKhoanData');

      final trangThai = int.tryParse(taiKhoanData['trang_thai'].toString()) ?? 0;
      debugPrint('Trạng thái tài khoản: $trangThai');

      setState(() {
        _coTheDangBai = trangThai == 1;
      });
    } catch (e) {
      debugPrint('Lỗi kiểm tra trạng thái tài khoản: $e');
      setState(() {
        _coTheDangBai = false;
      });
    }
  }

  Future<void> _loadDropdownData() async {
    try {
      final nganhData = await getDanhSachNganh();
      final loaiData = await getDanhSachLoai();
      setState(() {
        danhSachNganh = nganhData;
        danhSachLoai = loaiData;
        _selectedNganh = danhSachNganh.isNotEmpty ? danhSachNganh[0] : null;
        _selectedLoai = danhSachLoai.isNotEmpty ? danhSachLoai[0] : null;
      });
    } catch (e) {
      debugPrint('Lỗi khi load ngành/loại: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _capturedImages.add(File(photo.path));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Đã chụp ảnh!', style: TextStyle(color: Colors.white)),
              ],
            ),
            backgroundColor: const Color(0xFF00C6FF),
            behavior: SnackBarBehavior.floating, // Nổi
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Chưa có ảnh nào được chụp.', style: TextStyle(color: Colors.white)),
              ],
            ),
            backgroundColor: Colors.orangeAccent,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Lỗi khi truy cập camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Lỗi khi truy cập camera: ${e.toString().replaceFirst('Exception: ', '')}',
                    style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    conditionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Màu nền nhẹ nhàng, hiện đại
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Đăng bài viết mới', // Tiêu đề rõ ràng hơn
          style: TextStyle(
            fontSize: 22, // Kích thước lớn hơn
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Nền trong suốt để gradient phủ toàn bộ
        elevation: 0, // Bỏ đổ bóng mặc định của AppBar
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              // Gradient màu xanh hiện đại hơn
              colors: [Color(0xFF0079CF), Color(0xFF00C6FF)], // Từ xanh đậm đến xanh sáng
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)), // Bo góc dưới AppBar
            boxShadow: [
              BoxShadow(
                color: Colors.black26, // Đổ bóng nhẹ nhàng
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0), // Tăng padding tổng thể
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Tiêu đề bài viết'),
              const SizedBox(height: 10), // Tăng khoảng cách
              _buildTextFormField(
                controller: titleController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tiêu đề không được để trống'; // Icon cảnh báo
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20), // Tăng khoảng cách

              _buildSectionTitle('Độ mới sản phẩm'),
              const SizedBox(height: 10),
              _buildTextField(
                controller: conditionController,
                keyboardType: TextInputType.number,
                suffixText: '%',
                hintText: 'Nhập độ mới (ví dụ: 90)',
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3), // Giới hạn 3 chữ số
                  _PercentageInputFormatter(), // Tùy chỉnh formatter để giới hạn 0-100
                ],
              ),
              const SizedBox(height: 20),

              _buildSectionTitle('Ngành'),
              const SizedBox(height: 10),
              _buildDropdownButtonFormField<Nganh>(
                value: _selectedNganh,
                items: danhSachNganh,
                getLabel: (nganh) => nganh.tenNganh,
                onChanged: (Nganh? newValue) => setState(() => _selectedNganh = newValue),
              ),
              const SizedBox(height: 20),

              _buildSectionTitle('Loại sản phẩm'),
              const SizedBox(height: 10),
              _buildDropdownButtonFormField<LoaiSanPham>(
                value: _selectedLoai,
                items: danhSachLoai,
                getLabel: (loai) => loai.tenLoai,
                onChanged: (LoaiSanPham? newValue) => setState(() => _selectedLoai = newValue),
              ),
              const SizedBox(height: 20),

              _buildSectionTitle('Giá tiền'),
              const SizedBox(height: 10),
              _buildTextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                hintText: 'Nhập giá tiền mong muốn',
                suffixText: ' VNĐ', // Thêm khoảng trắng
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CurrencyInputFormatter(), // Custom formatter cho tiền tệ
                ],
              ),
              const SizedBox(height: 20),

              _buildSectionTitle('Ảnh sản phẩm'), // Đổi tiêu đề cho rõ ràng hơn
              const SizedBox(height: 10),
              // Grid ảnh và nút chụp ảnh
              if (_capturedImages.isNotEmpty) ...[
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWide ? 4 : 3,
                    crossAxisSpacing: 10, // Tăng khoảng cách giữa các ảnh
                    mainAxisSpacing: 10, // Tăng khoảng cách giữa các ảnh
                    childAspectRatio: 1,
                  ),
                  itemCount: _capturedImages.length,
                  itemBuilder: (context, index) {
                    return _buildImageThumbnail(_capturedImages[index], index);
                  },
                ),
                const SizedBox(height: 15), // Khoảng cách giữa grid và nút camera
              ],
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0079CF), Color(0xFF00FFDE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10), // Bo góc hơn
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0079CF).withOpacity(0.3), // Màu bóng xanh
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon( // Sử dụng ElevatedButton.icon
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                    label: const Text('Chụp ảnh',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // Nền trong suốt
                      shadowColor: Colors.transparent, // Bỏ bóng mặc định của ElevatedButton
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20), // Tăng padding
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30), // Khoảng cách lớn hơn trước nút Đăng bài

              // Nút Đăng bài
              SizedBox(
                width: double.infinity,
                height: 55, // Chiều cao cố định
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    if (!_coTheDangBai) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.block, color: Colors.white),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text('Tài khoản của bạn hiện không được phép đăng bài.',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.deepOrange, // Màu cảnh báo mạnh hơn
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      return;
                    }
                    if (_capturedImages.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.image_not_supported, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Vui lòng chụp ít nhất một ảnh cho sản phẩm.',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          backgroundColor: Colors.orange[700],
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      return;
                    }

                    final title = titleController.text.trim();
                    final price = int.tryParse(priceController.text.replaceAll('.', '').trim()) ?? 0; // Xóa dấu chấm cho số tiền
                    final doMoi = int.tryParse(conditionController.text.trim()) ?? 100;
                    final idLoai = _selectedLoai?.id ?? 1;
                    final idNganh = _selectedNganh?.id ?? 1;
                    final idTaiKhoan = int.tryParse(widget.userId) ?? 1;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            SizedBox(width: 10),
                            Text('Đang đăng bài...', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        backgroundColor: Colors.blueAccent,
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        duration: const Duration(seconds: 5), // Thời gian hiển thị dài hơn cho loading
                      ),
                    );

                    final success = await postBaiDang(
                      idTaiKhoan: idTaiKhoan,
                      tieuDe: title,
                      gia: price,
                      doMoi: doMoi,
                      idLoai: idLoai,
                      idNganh: idNganh,
                      hinhAnh: _capturedImages,
                    );

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Ẩn snackbar loading

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Đăng bài thành công!', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          backgroundColor: Colors.green[600],
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      setState(() {
                        titleController.clear();
                        priceController.clear();
                        conditionController.text = '99';
                        _capturedImages.clear();
                        _selectedNganh = danhSachNganh.isNotEmpty ? danhSachNganh[0] : null;
                        _selectedLoai = danhSachLoai.isNotEmpty ? danhSachLoai[0] : null;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.white),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text('Đăng bài thất bại. Vui lòng thử lại.',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0079CF), // Màu xanh chủ đạo
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Bo góc hơn cho nút chính
                    ),
                    elevation: 10, // Tăng đổ bóng
                    shadowColor: const Color(0xFF0079CF).withOpacity(0.5), // Bóng màu xanh
                  ),
                  child: const Text('Đăng bài',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Text lớn hơn
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget cho mỗi ảnh đã chụp
  Widget _buildImageThumbnail(File imageFile, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Bo góc ảnh
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.1), // Shadow nhẹ cho mỗi ảnh
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              imageFile,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 5,
              right: 5,
              child: GestureDetector(
                onTap: () => setState(() => _capturedImages.removeAt(index)),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54, // Màu nền của nút xóa
                    borderRadius: BorderRadius.circular(15), // Bo tròn hoàn toàn
                  ),
                  padding: const EdgeInsets.all(5),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm tạo tiêu đề phần
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17, // Tăng kích thước
        fontWeight: FontWeight.bold,
        color: Color(0xFF222222), // Màu chữ đậm hơn
      ),
    );
  }

  // Hàm tạo TextField dùng cho các trường thông thường
  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    String? suffixText,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: _inputBoxDecoration(), // Sử dụng decoration mới
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontSize: 16, color: Colors.black87), // Style cho text nhập vào
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
          suffixText: suffixText,
          suffixStyle: const TextStyle(color: Colors.black54, fontSize: 15), // Style cho suffix text
          border: InputBorder.none, // Bỏ border mặc định
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder( // Viền khi focus
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0079CF), width: 2), // Viền xanh khi focus
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Tăng padding
          filled: true,
          fillColor: Colors.transparent, // Không cần fill vì container đã có màu
        ),
      ),
    );
  }

  // Hàm tạo TextFormField (có validator)
  Widget _buildTextFormField({
    required TextEditingController controller,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: _inputBoxDecoration(),
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
          border: InputBorder.none, // Bỏ border mặc định
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0079CF), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: true,
          fillColor: Colors.transparent,
          errorStyle: const TextStyle(color: Colors.red, fontSize: 13, height: 1.2), // Tùy chỉnh lỗi
          errorMaxLines: 2, // Cho phép lỗi hiển thị 2 dòng
        ),
      ),
    );
  }

  // Hàm tạo DropdownButtonFormField
  Widget _buildDropdownButtonFormField<T>({
    required T? value,
    required List<T> items,
    required String Function(T) getLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      decoration: _inputBoxDecoration(),
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true, // Cho phép dropdown mở rộng hết chiều rộng
        icon: Icon(Icons.arrow_drop_down_rounded, color: Colors.grey[600], size: 28), // Icon mũi tên
        style: const TextStyle(fontSize: 16, color: Colors.black87), // Style cho giá trị được chọn
        decoration: InputDecoration(
          border: InputBorder.none, // Bỏ border mặc định
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0079CF), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: true,
          fillColor: Colors.transparent,
        ),
        items: items
            .map((T item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    getLabel(item),
                    overflow: TextOverflow.ellipsis, // Xử lý text dài
                  ),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  // Decoration chung cho các input field
  BoxDecoration _inputBoxDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Bo góc lớn hơn
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08), // Bóng mềm mại hơn
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!, width: 1.0), // Viền nhẹ mặc định
      );
}

// Custom Input Formatter cho phần trăm (0-100)
class _PercentageInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    final int? value = int.tryParse(newValue.text);
    if (value == null) {
      return oldValue; // Chỉ cho phép số
    }
    if (value < 0) {
      return const TextEditingValue(text: '0');
    } else if (value > 100) {
      return const TextEditingValue(text: '100');
    }
    return newValue;
  }
}

// Custom Input Formatter cho định dạng tiền tệ (thêm dấu chấm)
class _CurrencyInputFormatter extends TextInputFormatter {
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String cleanText = newValue.text.replaceAll('.', '');
    if (cleanText.isEmpty) {
      return newValue;
    }

    try {
      final int value = int.parse(cleanText);
      final String formattedValue = _formatNumber(value);
      return newValue.copyWith(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
    } catch (e) {
      return oldValue; // Giữ giá trị cũ nếu không phải số hợp lệ
    }
  }

  String _formatNumber(int n) {
    if (n == 0) return '0';
    String s = n.toString();
    String newString = '';
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      newString = s[i] + newString;
      count++;
      if (count % 3 == 0 && i != 0) {
        newString = '.' + newString;
      }
    }
    return newString;
  }
}