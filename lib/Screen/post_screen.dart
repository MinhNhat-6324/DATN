import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:front_end/model/bai_dang_service.dart';
import 'package:front_end/model/chuyen_nganh_service.dart';
import 'package:front_end/model/loai_san_pham_service.dart';

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
  final TextEditingController conditionController =
      TextEditingController(text: '99');

  List<Nganh> danhSachNganh = [];
  List<LoaiSanPham> danhSachLoai = [];
  Nganh? _selectedNganh;
  LoaiSanPham? _selectedLoai;

  final List<File> _capturedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _capturedImages.add(File(photo.path));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Đã chụp ảnh!', style: TextStyle(color: Colors.white)),
            backgroundColor: Color(0xFF00C6FF),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa có ảnh nào được chụp.')),
        );
      }
    } catch (e) {
      debugPrint('Lỗi khi truy cập camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể truy cập camera: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
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
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0079CF), Color(0xFF00FFDE)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Text(
          widget.userId,
          style: const TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Tiêu đề bài viết'),
              const SizedBox(height: 8),
              _buildTextFormField(
                controller: titleController,
                hintText: 'Tiêu đề (tên sản phẩm...)',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '❗ Tiêu đề không được để trống';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Độ mới sản phẩm'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: conditionController,
                keyboardType: TextInputType.number,
                suffixText: '%',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Ngành'),
              const SizedBox(height: 8),
              _buildDropdownButtonFormField<Nganh>(
                value: _selectedNganh,
                items: danhSachNganh,
                getLabel: (nganh) => nganh.tenNganh,
                onChanged: (Nganh? newValue) {
                  setState(() => _selectedNganh = newValue);
                },
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Loại sản phẩm'),
              const SizedBox(height: 8),
              _buildDropdownButtonFormField<LoaiSanPham>(
                value: _selectedLoai,
                items: danhSachLoai,
                getLabel: (loai) => loai.tenLoai,
                onChanged: (LoaiSanPham? newValue) {
                  setState(() => _selectedLoai = newValue);
                },
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Giá tiền'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                hintText: 'Nhập giá tiền',
                suffixText: 'VNĐ',
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Ảnh đã chụp'),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 4 : 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: _capturedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _capturedImages[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _capturedImages.removeAt(index));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0079CF), Color(0xFF00FFDE)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton(
                    onPressed: _takePhoto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Camera',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    final title = titleController.text.trim();
                    final price =
                        int.tryParse(priceController.text.trim()) ?? 0;
                    final doMoi =
                        int.tryParse(conditionController.text.trim()) ?? 100;

                    final idLoai = _selectedLoai?.id ?? 1;
                    final idNganh = _selectedNganh?.id ?? 1;
                    final idTaiKhoan = int.tryParse(widget.userId) ?? 1;

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

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Đăng bài thành công!')),
                      );
                      setState(() {
                        titleController.clear();
                        priceController.clear();
                        conditionController.text = '99';
                        _capturedImages.clear();
                        _selectedNganh =
                            danhSachNganh.isNotEmpty ? danhSachNganh[0] : null;
                        _selectedLoai =
                            danhSachLoai.isNotEmpty ? danhSachLoai[0] : null;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('❌ Đăng bài thất bại')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0056D2),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Đăng bài',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    String? suffixText,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hintText,
          suffixText: suffixText,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Colors.transparent,
          errorStyle: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildDropdownButtonFormField<T>({
    required T? value,
    required List<T> items,
    required String Function(T) getLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2)),
        ],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Colors.transparent,
        ),
        items: items
            .map((T item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(getLabel(item)),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
    );
  }
}
