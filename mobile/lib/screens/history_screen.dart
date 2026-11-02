import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart'; // Import library Chart
import '../services/storage_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _history = [];

  static const Color primaryGreen = Color(0xFF047857);
  static const Color darkText = Color(0xFF1F2937);

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await StorageService.getDietHistory();
    setState(() {
      _history = history.reversed.toList();
      _isLoading = false;
    });
  }

  Future<void> _deleteRecord(int index) async {
    int realIndex = _history.length - 1 - index;
    final prefs = await SharedPreferences.getInstance();
    List<String> historyStrings = prefs.getStringList('diet_history_porsipas') ?? [];
    
    if (realIndex >= 0 && realIndex < historyStrings.length) {
      historyStrings.removeAt(realIndex);
      await prefs.setStringList('diet_history_porsipas', historyStrings);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan riwayat berhasil dihapus'), backgroundColor: Colors.red),
        );
        _loadHistory();
      }
    }
  }

  double _parseDoubleSafely(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'Waktu tidak tercatat';
    try {
      DateTime dt = DateTime.parse(isoString);
      List<String> months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
      return "${dt.day} ${months[dt.month]} ${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return 'Format waktu tidak valid';
    }
  }

  void _showDetailBottomSheet(Map<String, dynamic> data) {
    double kaloriTotal = _parseDoubleSafely(data['kalori']);
    int kaloriSarapan = (kaloriTotal * 0.25).toInt();
    int kaloriSiang = (kaloriTotal * 0.40).toInt();
    int kaloriMalam = (kaloriTotal * 0.35).toInt();

    String targetDiet = data['target_tubuh'] ?? 'Menjaga Berat Badan';
    String gender = data['is_pria'] == null ? '-' : (data['is_pria'] ? 'Pria' : 'Wanita');
    String age = data['umur']?.toString() ?? '-';
    String height = data['tinggi']?.toString() ?? '-';
    String weight = data['berat']?.toString() ?? '-';
    String activity = data['aktivitas'] ?? 'Aktivitas tidak tercatat';
    String timestamp = _formatDate(data['timestamp']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.90,
        padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 0),
        decoration: const BoxDecoration(
          color: Color(0xFFFAFAFA),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Jurnal Prediksi AI', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: darkText)),
                      const SizedBox(height: 4),
                      Text('Klasifikasi: ${data['status'] ?? '-'}', style: const TextStyle(fontSize: 13, color: primaryGreen, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      const Icon(Icons.access_time_filled_rounded, color: Colors.blue, size: 14),
                      const SizedBox(height: 2),
                      Text(timestamp, style: const TextStyle(fontSize: 9, color: Colors.blue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Data Kalibrasi Tubuh', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black54, letterSpacing: 0.5)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.flag_circle_rounded, color: Colors.orange, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(targetDiet, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkText))),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Colors.black12)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoMini('Kelamin', gender, Icons.wc_rounded),
                            _buildInfoMini('Usia', '$age Thn', Icons.cake_rounded),
                            _buildInfoMini('Tinggi', '$height cm', Icons.height_rounded),
                            _buildInfoMini('Berat', '$weight kg', Icons.monitor_weight_rounded),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.directions_run_rounded, color: primaryGreen, size: 16),
                            const SizedBox(width: 6),
                            Expanded(child: Text(activity, style: const TextStyle(fontSize: 11, color: Colors.black87))),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text('Rekomendasi Menu Makanan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: darkText)),
                  const SizedBox(height: 12),
                  _buildFullDetailMealItem(
                    title: 'Sarapan', 
                    icon: Icons.wb_sunny_outlined, 
                    mealName: data['menu_sarapan'], 
                    imageUrl: data['img_sarapan'], 
                    calories: kaloriSarapan,
                    karbo: _parseDoubleSafely(data['karbo_sarapan']),
                    protein: _parseDoubleSafely(data['pro_sarapan']),
                    lemak: _parseDoubleSafely(data['lemak_sarapan']),
                  ),
                  _buildFullDetailMealItem(
                    title: 'Makan Siang', 
                    icon: Icons.wb_incandescent_outlined, 
                    mealName: data['menu_siang'], 
                    imageUrl: data['img_siang'], 
                    calories: kaloriSiang,
                    karbo: _parseDoubleSafely(data['karbo_siang']),
                    protein: _parseDoubleSafely(data['pro_siang']),
                    lemak: _parseDoubleSafely(data['lemak_siang']),
                  ),
                  _buildFullDetailMealItem(
                    title: 'Makan Malam', 
                    icon: Icons.nights_stay_outlined, 
                    mealName: data['menu_malam'], 
                    imageUrl: data['img_malam'], 
                    calories: kaloriMalam,
                    karbo: _parseDoubleSafely(data['karbo_malam']),
                    protein: _parseDoubleSafely(data['pro_malam']),
                    lemak: _parseDoubleSafely(data['lemak_malam']),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoMini(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.black45),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: primaryGreen)),
      ],
    );
  }

  Widget _buildFullDetailMealItem({
    required String title,
    required IconData icon,
    required String? mealName,
    required String? imageUrl,
    required int calories,
    required double karbo,
    required double protein,
    required double lemak,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  image: (imageUrl != null && imageUrl.isNotEmpty)
                      ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                      : null,
                ),
                child: (imageUrl == null || imageUrl.isEmpty)
                    ? Icon(icon, color: Colors.orange)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(mealName ?? 'Menu tidak tersedia', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: darkText), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: primaryGreen, borderRadius: BorderRadius.circular(8)),
                child: Text('~$calories Kcal', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutrientChipSmall('Protein', protein, const Color(0xFFD1FAE5), primaryGreen),
              _buildNutrientChipSmall('Karbo', karbo, const Color(0xFFFEF3C7), const Color(0xFFD97706)),
              _buildNutrientChipSmall('Lemak', lemak, const Color(0xFFE0E7FF), const Color(0xFF4338CA)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientChipSmall(String label, double value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
          Text('${value.toStringAsFixed(0)}g', style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  // --- FUNGSI CHART PROGRESS ---
  Widget _buildChart() {
    // Balik urutan histori dari yang terlama (kiri) ke terbaru (kanan)
    List<dynamic> chronologicalHistory = _history.reversed.toList();
    
    List<FlSpot> spots = [];
    double minY = double.infinity;
    double maxY = -double.infinity;

    for (int i = 0; i < chronologicalHistory.length; i++) {
      double weight = _parseDoubleSafely(chronologicalHistory[i]['berat']);
      spots.add(FlSpot(i.toDouble(), weight));
      if (weight < minY) minY = weight;
      if (weight > maxY) maxY = weight;
    }

    // Beri ruang (padding) untuk Sumbu Y agar grafik tidak menabrak atap/dasar
    minY = (minY - 2).floorToDouble();
    maxY = (maxY + 2).ceilToDouble();

    return SizedBox(
      height: 160, // Tinggi area grafik
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true, 
            drawVerticalLine: false,
            horizontalInterval: 2, // Garis putus-putus horizontal setiap 2 kg
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey.shade200, strokeWidth: 1, dashArray: [5, 5]);
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  // Jangan tampilkan tulisan jika bukan bilangan bulat
                  if (value % 1 != 0) return const SizedBox.shrink();
                  int index = value.toInt();
                  if (index >= 0 && index < spots.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Sesi ${index + 1}', style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (spots.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: primaryGreen,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: primaryGreen);
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: primaryGreen.withOpacity(0.15),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => primaryGreen,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  return LineTooltipItem(
                    '${touchedSpot.y} kg',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressTracker() {
    if (_history.length < 2) {
      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.blue.shade100)),
        child: Row(
          children: const [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 12),
            Expanded(child: Text('Lakukan kalibrasi ulang di hari lain untuk melihat grafik progress perkembangan berat badanmu di sini!', style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4))),
          ],
        ),
      );
    }

    double beratAwal = _parseDoubleSafely(_history.last['berat']);
    double beratSekarang = _parseDoubleSafely(_history.first['berat']);
    double selisih = beratSekarang - beratAwal;

    String progressText = "Berat Tetap Stabil";
    Color progressColor = Colors.blue;
    IconData progressIcon = Icons.drag_handle_rounded;

    if (selisih < 0) {
      progressText = "Turun ${selisih.abs().toStringAsFixed(1)} kg";
      progressColor = primaryGreen;
      progressIcon = Icons.trending_down_rounded;
    } else if (selisih > 0) {
      progressText = "Naik ${selisih.toStringAsFixed(1)} kg";
      progressColor = Colors.orange.shade700;
      progressIcon = Icons.trending_up_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.query_stats_rounded, color: primaryGreen, size: 20),
              SizedBox(width: 8),
              Text('PROGRESS DIET KAMU', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: primaryGreen, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressStat('Berat Awal', '$beratAwal', 'kg'),
              Icon(Icons.arrow_forward_rounded, color: Colors.grey.shade300),
              _buildProgressStat('Saat Ini', '$beratSekarang', 'kg'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: progressColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(progressIcon, color: progressColor, size: 18),
                const SizedBox(width: 8),
                Text(progressText, style: TextStyle(color: progressColor, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
          
          // --- Menampilkan Grafik Line Chart ---
          const SizedBox(height: 24),
          const Text('Grafik Berat Badan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 16),
          _buildChart(),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, String value, String unit) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: darkText)),
            const SizedBox(width: 2),
            Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(unit, style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold))),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.eco, color: primaryGreen, size: 24),
            ),
            const SizedBox(width: 10),
            const Text('PorsiPas', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w900, fontSize: 22)),
            Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(6)),
              child: const Text('AI', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryGreen))
          : _history.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  color: primaryGreen,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.show_chart, color: Colors.blue, size: 16),
                          SizedBox(width: 8),
                          Text('JURNAL KESEHATAN', style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Jejak Sehatmu 📈', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: darkText, height: 1.2)),
                      const SizedBox(height: 8),
                      const Text('Setiap langkah kecil bernilai. Lihat hasil analisis prediksi nutrisi yang pernah dibuat oleh AI.', style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4)),
                      const SizedBox(height: 24),
                      
                      _buildProgressTracker(),

                      ...List.generate(_history.length, (index) {
                        final record = _history[index];
                        return _buildHistoryCard(index, record);
                      }),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: primaryGreen.withOpacity(0.05), shape: BoxShape.circle),
              child: Icon(Icons.history_rounded, size: 80, color: primaryGreen.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            const Text('Belum Ada Riwayat', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: darkText)),
            const SizedBox(height: 12),
            const Text('Gunakan kalkulator AI untuk menganalisis kebutuhan nutrisi pertamamu.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(int index, Map<String, dynamic> record) {
    String status = record['status'] ?? 'Balanced Diet';
    status = status.replaceAll('(AI)', '').trim();
    double kalori = _parseDoubleSafely(record['kalori']);
    
    int sessionNumber = _history.length - index;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: primaryGreen.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.favorite, color: primaryGreen, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sesi Pengecekan AI #$sessionNumber', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: darkText)),
                      const SizedBox(height: 4),
                      Text(status, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _deleteRecord(index),
                )
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.black12),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Batas Kalori Harian', style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${kalori.toInt()}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: primaryGreen, height: 1.0)),
                        const SizedBox(width: 4),
                        const Padding(padding: EdgeInsets.only(bottom: 3), child: Text('Kcal', style: TextStyle(fontSize: 11, color: Colors.black54))),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _showDetailBottomSheet(record),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: darkText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), 
                      side: BorderSide(color: Colors.grey.shade300)
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Lihat Detail', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}