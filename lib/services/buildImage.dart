String buildImageUrl(String duongDan) {
  if (duongDan.trim().isEmpty) return '';

  if (duongDan.startsWith('data:image')) {
    print('📷 Base64 image');
    return duongDan;
  }

  if (duongDan.startsWith('http')) {
    final uri = Uri.tryParse(duongDan);
    final imgurl = uri?.queryParameters['imgurl'];
    if (imgurl != null && imgurl.startsWith('http')) {
      return Uri.decodeFull(imgurl);
    }
    return duongDan;
  }

  final cleanedPath =
      duongDan.startsWith('/') ? duongDan.substring(1) : duongDan;

  final fullUrl = 'http://10.0.2.2:8000/$cleanedPath';
  print('🧩 buildImageUrl: $fullUrl');
  return fullUrl;
}
