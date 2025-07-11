import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:front_end/services/tai_khoan_service.dart';
import 'package:front_end/services/bai_dang_service.dart';

class DashboardThongKeScreen extends StatefulWidget {
  const DashboardThongKeScreen({super.key});

  @override
  State<DashboardThongKeScreen> createState() => _DashboardThongKeScreenState();
}

class _DashboardThongKeScreenState extends State<DashboardThongKeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TaiKhoanService _taiKhoanService = TaiKhoanService();

  bool _isLoadingTaiKhoan = true;
  String? _errorTaiKhoan;
  Map<String, dynamic>? _chartDataTaiKhoan;

  bool _isLoadingBaiDang = true;
  String? _errorBaiDang;
  Map<String, dynamic>? _chartDataBaiDangTrangThai;
  List<Map<String, dynamic>>? _thongKeChuyenNganh;

  // Biến mới để lưu thông tin chuyên ngành được chạm
  Map<String, dynamic>? _selectedMajorInfo;
  int _touchedMajorIndex = -1; // Thêm biến để theo dõi index cột được chạm

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchTaiKhoanData();
    _fetchBaiDangData();
  }

  Future<void> _fetchTaiKhoanData() async {
    setState(() {
      _isLoadingTaiKhoan = true;
      _errorTaiKhoan = null;
    });

    try {
      final data = await _taiKhoanService.getChartStatistics();
      debugPrint("✅ JSON thống kê tài khoản: $data");
      setState(() {
        _chartDataTaiKhoan = data;
        _isLoadingTaiKhoan = false;
      });
    } catch (e) {
      setState(() {
        _errorTaiKhoan = "Không thể tải dữ liệu tài khoản: ${e.toString()}";
        _isLoadingTaiKhoan = false;
      });
    }
  }

  Future<void> _fetchBaiDangData() async {
    setState(() {
      _isLoadingBaiDang = true;
      _errorBaiDang = null;
    });

    try {
      final thongKeTrangThai = await thongKeBaiDangTheoTrangThai();
      final thongKeChuyenNganh = await thongKeBaiDangTheoChuyenNganh();
      debugPrint("✅ JSON thống kê bài đăng theo trạng thái: $thongKeTrangThai");
      debugPrint("✅ JSON thống kê bài đăng theo chuyên ngành: $thongKeChuyenNganh");

      setState(() {
        _chartDataBaiDangTrangThai = thongKeTrangThai;
        _thongKeChuyenNganh = thongKeChuyenNganh;
        _isLoadingBaiDang = false;
        // Reset selected info when data is fetched
        _selectedMajorInfo = null;
        _touchedMajorIndex = -1;
      });
    } catch (e) {
      setState(() {
        _errorBaiDang = "Không thể tải dữ liệu bài đăng: ${e.toString()}";
        _isLoadingBaiDang = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ------------------- TAB TÀI KHOẢN ----------------------
  Widget _buildTaiKhoanTab() {
    if (_isLoadingTaiKhoan) {
      return const Center(child: CircularProgressIndicator(color: Colors.indigo));
    }
    if (_errorTaiKhoan != null) {
      return _buildErrorWidget(_errorTaiKhoan!, _fetchTaiKhoanData);
    }
    if (_chartDataTaiKhoan == null || (_chartDataTaiKhoan!['series'] as List).isEmpty) {
      return _buildEmptyState('Không có dữ liệu thống kê tài khoản.');
    }

    final total = (_chartDataTaiKhoan!['total'] ?? 0);
    final List series = _chartDataTaiKhoan!['series'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total Accounts Card
          _buildInfoCard(
            title: 'Tổng số tài khoản',
            value: total.toString(),
            icon: Icons.people_alt,
            color: Colors.indigo.shade700,
          ),
          const SizedBox(height: 24),
          // Pie Chart Card
          _buildChartCard(
            child: SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 6,
                  centerSpaceRadius: 60,
                  sections: _chartSectionsTaiKhoan(),
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (event is FlLongPressEnd || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                          // Handle touch end or no touch
                        } else {
                          // Handle touch event if needed
                        }
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Legend
          _buildLegendCard(series, total),
        ],
      ),
    );
  }

  // ------------------- TAB BÀI ĐĂNG ----------------------
  Widget _buildBaiDangTab() {
    if (_isLoadingBaiDang) {
      return const Center(child: CircularProgressIndicator(color: Colors.indigo));
    }
    if (_errorBaiDang != null) {
      return _buildErrorWidget(_errorBaiDang!, _fetchBaiDangData);
    }
    if (_chartDataBaiDangTrangThai == null || (_chartDataBaiDangTrangThai!['series'] as List).isEmpty) {
      return _buildEmptyState('Không có dữ liệu thống kê bài đăng.');
    }

    final total = (_chartDataBaiDangTrangThai!['total'] ?? 0);
    final List seriesTrangThai = _chartDataBaiDangTrangThai!['series'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total Posts Card
          _buildInfoCard(
            title: 'Tổng số bài đăng',
            value: total.toString(),
            icon: Icons.article,
            color: Colors.teal.shade700,
          ),
          const SizedBox(height: 24),
          // Post Status Pie Chart Card
          _buildChartCard(
            title: 'Theo trạng thái',
            child: SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 6,
                  centerSpaceRadius: 60,
                  sections: _chartSectionsBaiDang(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Post Status Legend
          _buildLegendCard(seriesTrangThai, total),
          const SizedBox(height: 30),
          // Posts by Major Bar Chart Card
          _buildChartCard(
            title: 'Theo chuyên ngành',
            child: SizedBox(
              height: 350,
              child: BarChart(
                BarChartData(
                  barGroups: _barChartGroupsChuyenNganh(),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 5),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString(), style: const TextStyle(color: Colors.black54, fontSize: 12));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < (_thongKeChuyenNganh?.length ?? 0)) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 8,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  // KHÔNG SỬ DỤNG BarTooltipData NỮA
                  barTouchData: BarTouchData(
                    enabled: true, // Đảm bảo touch được bật
                    touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
                      if (event is FlTapUpEvent || event is FlPanEndEvent) {
                        setState(() {
                          if (response?.spot != null && response!.spot!.touchedBarGroupIndex != -1) {
                            _touchedMajorIndex = response.spot!.touchedBarGroupIndex;
                            _selectedMajorInfo = _thongKeChuyenNganh?[_touchedMajorIndex];
                          } else {
                            _touchedMajorIndex = -1;
                            _selectedMajorInfo = null;
                          }
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          // Hiển thị thông tin chuyên ngành được chạm
          _buildTouchedMajorInfo(),
          const SizedBox(height: 24),
          // Chú thích chuyên ngành
          _buildMajorLegendCard(),
        ],
      ),
    );
  }

  // ------------------- UTILITY WIDGETS ----------------------

  Widget _buildInfoCard({required String title, required String value, required IconData icon, required Color color}) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard({String? title, required Widget child}) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
            ],
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildLegendCard(List series, int total) {
    if (series.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chi tiết:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: series.length,
              itemBuilder: (context, index) {
                final item = series[index];
                final percent = total > 0 ? ((item['value'] * 100) / total).toStringAsFixed(1) : '0.0';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _getColorByLabel(item['label']),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${item['label']}: ${item['value']} (${percent}%)',
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget mới để hiển thị thông tin chuyên ngành được chạm
  Widget _buildTouchedMajorInfo() {
    if (_selectedMajorInfo == null) {
      return const SizedBox.shrink(); // Không hiển thị nếu chưa có cột nào được chạm
    }
    final String majorName = _selectedMajorInfo!['ten_nganh'] ?? 'Không rõ';
    final int postCount = (_selectedMajorInfo!['bai_dang_count'] ?? 0);

    return Card(
      margin: const EdgeInsets.only(top: 24),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin chi tiết chuyên ngành:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Text(
              'Chuyên ngành: $majorName (Số ${_touchedMajorIndex + 1})',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Số bài đăng: $postCount',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMajorLegendCard() {
    if (_thongKeChuyenNganh == null || _thongKeChuyenNganh!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chú thích chuyên ngành:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _thongKeChuyenNganh!.length,
              itemBuilder: (context, index) {
                final item = _thongKeChuyenNganh![index];
                final String majorName = item['ten_nganh'] ?? 'Không rõ';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '${index + 1}. $majorName',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: (index == _touchedMajorIndex) ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 60),
            const SizedBox(height: 20),
            Text(
              'Có lỗi xảy ra: $message',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline, color: Colors.grey.shade400, size: 80),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            const Text(
              'Vui lòng kiểm tra lại dữ liệu hoặc cài đặt.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------- CHART SECTIONS ----------------------
  List<PieChartSectionData> _chartSectionsTaiKhoan() {
    final List sections = _chartDataTaiKhoan?['series'] ?? [];
    return sections.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = false;
      final fontSize = isTouched ? 16.0 : 14.0;
      final radius = isTouched ? 70.0 : 60.0;
      final double value = (item['value'] as num).toDouble();
      final color = _getColorByLabel(item['label']);

      return PieChartSectionData(
        color: color,
        value: value,
        title: value > 0 ? '${value.toInt()}' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 2)],
        ),
      );
    }).toList();
  }

  List<PieChartSectionData> _chartSectionsBaiDang() {
    final List sections = _chartDataBaiDangTrangThai?['series'] ?? [];
    return sections.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = false;
      final fontSize = isTouched ? 16.0 : 14.0;
      final radius = isTouched ? 70.0 : 60.0;
      final double value = (item['value'] as num).toDouble();
      final color = _getColorByLabel(item['label']);

      return PieChartSectionData(
        color: color,
        value: value,
        title: value > 0 ? '${value.toInt()}' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 2)],
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _barChartGroupsChuyenNganh() {
    if (_thongKeChuyenNganh == null) return [];
    return List.generate(_thongKeChuyenNganh!.length, (index) {
      final item = _thongKeChuyenNganh![index];
      final count = ((item['bai_dang_count'] ?? 0) as num).toDouble();
      final double maxY = (_thongKeChuyenNganh!
          .map((e) => (e['bai_dang_count'] as num).toDouble())
          .fold(0.0, (previous, current) => previous > current ? previous : current)) + 5;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count,
            color: (index == _touchedMajorIndex) ? Colors.indigo.shade800 : Colors.indigo.shade400, // Đổi màu cột khi chạm
            width: 20,
            borderRadius: BorderRadius.circular(6),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxY,
              color: Colors.grey.shade200,
            ),
          ),
        ],
        showingTooltipIndicators: [], // Không dùng tooltip mặc định
      );
    });
  }

  Color _getColorByLabel(String label) {
    switch (label) {
      case 'Đang hoạt động':
        return Colors.green.shade600;
      case 'Sẵn sàng':
        return Colors.blue.shade600;
      case 'Chờ duyệt':
        return Colors.orange.shade600;
      case 'Đã cho tặng':
        return Colors.teal.shade600;
      case 'Bị khóa':
        return Colors.red.shade600;
      case 'Vi phạm':
        return Colors.purple.shade600;
      default:
        return Colors.blueGrey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2280EF), Color(0xFF2280EF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Bảng Thống Kê Số Lượng',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 8,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color.fromARGB(255, 255, 255, 255),
          labelColor: const Color.fromARGB(255, 255, 255, 255),
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
          tabs: const [
            Tab(text: 'Tài khoản'),
            Tab(text: 'Bài đăng'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaiKhoanTab(),
          _buildBaiDangTab(),
        ],
      ),
    );
  }
}