class ChuyenNganhItem {
  final int id;
  final String name;

  ChuyenNganhItem({required this.id, required this.name});

  // Hàm factory để tạo đối tượng từ JSON (nếu API trả về JSON)
  factory ChuyenNganhItem.fromJson(Map<String, dynamic> json) {
    return ChuyenNganhItem(
      id: json['id_nganh'], // Đảm bảo khớp với tên trường từ API Laravel của bạn
      name: json['ten_nganh'], // Đảm bảo khớp với tên trường từ API Laravel của bạn
    );
  }

  // Để DropdownButton hiển thị đúng và phân biệt các item
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChuyenNganhItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return name; // DropdownButton sẽ dùng toString() để hiển thị, nên trả về tên
  }
}