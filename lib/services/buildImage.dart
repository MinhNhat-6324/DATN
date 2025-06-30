String buildImageUrl(String duongDan) {
  if (duongDan.trim().isEmpty) return '';

  // Trường hợp đã là URL đầy đủ
  if (duongDan.startsWith('http')) {
    final uri = Uri.tryParse(duongDan);
    final imgurl = uri?.queryParameters['imgurl'];
    if (imgurl != null && imgurl.startsWith('http')) {
      return Uri.decodeFull(imgurl);
    }
    return duongDan;
  }

  // Xoá dấu '/' đầu nếu có để tránh lỗi //
  final cleanedPath =
      duongDan.startsWith('/') ? duongDan.substring(1) : duongDan;

  return 'http://10.0.2.2:8000/$cleanedPath';
}
