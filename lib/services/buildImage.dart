String buildImageUrl(String duongDan) {
  if (duongDan.trim().isEmpty) return '';
  if (duongDan.startsWith('http')) {
    final uri = Uri.tryParse(duongDan);
    final imgurl = uri?.queryParameters['imgurl'];
    if (imgurl != null && imgurl.startsWith('http')) {
      return Uri.decodeFull(imgurl);
    }
    return duongDan;
  }
  return 'http://10.0.2.2:8000/$duongDan';
}
