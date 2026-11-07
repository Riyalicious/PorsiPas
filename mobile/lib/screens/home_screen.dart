import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  bool _hasData = false;
  double _targetKalori = 0;
  String _kategoriDiet = 'Balanced Diet';
  double _proteinG = 0;
  double _karboG = 0;
  double _lemakG = 0;
  int _waterCount = 0;

  static const Color primaryGreen = Color(0xFF047857);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color darkText = Color(0xFF1F2937);

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  double _parseDoubleSafely(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final history = await StorageService.getDietHistory();
    final water = await StorageService.getWaterCount();

    if (history.isNotEmpty) {
      final latest = history.last; 
      setState(() {
        _hasData = true;
        _targetKalori = _parseDoubleSafely(latest['kalori']);
        
        String rawKategori = latest['status'] ?? 'Balanced Diet';
        _kategoriDiet = rawKategori.replaceAll('(AI)', '').trim(); 
        
        _proteinG = _parseDoubleSafely(latest['target_protein_harian']);
        if (_proteinG <= 0) _proteinG = (_targetKalori * 0.25) / 4;

        _karboG = _parseDoubleSafely(latest['target_karbo_harian']);
        if (_karboG <= 0) _karboG = (_targetKalori * 0.50) / 4;

        _lemakG = _parseDoubleSafely(latest['target_lemak_harian']);
        if (_lemakG <= 0) _lemakG = (_targetKalori * 0.25) / 9;
      });
    } else {
      setState(() {
        _hasData = false;
      });
    }

    setState(() {
      _waterCount = water;
      _isLoading = false;
    });
  }

  Future<void> _updateWater(int delta) async {
    int newCount = _waterCount + delta;
    if (newCount < 0) newCount = 0;
    if (newCount > 8) newCount = 8; 
    await StorageService.saveWaterCount(newCount);
    setState(() => _waterCount = newCount);
  }

  String _getDietDescription(String diet) {
    String lowerDiet = diet.toLowerCase();
    if (lowerDiet.contains('protein')) {
      return 'AI merekomendasikan diet Tinggi Protein untuk mendukung pemeliharaan massa otot, mengoptimalkan pemulihan sel, dan memberikan rasa kenyang lebih lama.';
    } else if (lowerDiet.contains('carb')) {
      return 'AI merekomendasikan diet Rendah Karbohidrat untuk membatasi lonjakan gula darah dan mendorong pembakaran cadangan lemak tubuh.';
    } else if (lowerDiet.contains('fat')) {
      return 'AI merekomendasikan diet Rendah Lemak untuk mengontrol asupan kalori secara efisien dan mendukung pemeliharaan berat badan.';
    } else if (lowerDiet.contains('balanced')) {
      return 'AI merekomendasikan diet Seimbang. Porsi ini mendistribusikan nutrisi secara merata untuk menjaga stabilitas metabolisme dan energi harian.';
    }
    return 'Diet disesuaikan secara khusus dengan kalibrasi fisik dan target biologis Anda.';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: primaryGreen)));
    }

    if (!_hasData) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: _buildAppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: primaryGreen.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.monitor_weight_outlined, size: 80, color: primaryGreen.withValues(alpha: 0.5)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Halo, Sahabat Sehat 🌿',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: darkText),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Kami belum memiliki data kalibrasi tubuh Anda. Silakan buka menu Kalkulator di bawah untuk mulai membuat rencana diet berbasis AI.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: primaryGreen,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Halo, Sahabat Sehat 🌿', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: darkText)),
              const SizedBox(height: 6),
              const Text(
                'Siap wujudkan tubuh bugar hari ini? Pantau nutrisimu dan jadikan sehat sebagai gaya hidup yang menyenangkan!',
                style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFF0FDF4)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.green.shade100, width: 1.5),
                  boxShadow: [BoxShadow(color: primaryGreen.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.auto_awesome, color: primaryGreen, size: 18),
                        SizedBox(width: 8),
                        Text('HASIL KLASIFIKASI AI', style: TextStyle(color: primaryGreen, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    Text(
                      _kategoriDiet,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: primaryGreen, height: 1.1),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primaryGreen.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.psychology, color: primaryGreen, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _getDietDescription(_kategoriDiet),
                              style: const TextStyle(fontSize: 12, color: darkText, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${_targetKalori.toInt()}', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: darkText, height: 1.0)),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Text('kkal / hari', style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMacroColumn('Protein', 'Otot & Sel', '${_proteinG.toInt()}g', primaryGreen),
                        _buildMacroColumn('Karbo', 'Energi Fisik', '${_karboG.toInt()}g', Colors.orange),
                        _buildMacroColumn('Lemak', 'Cadangan', '${_lemakG.toInt()}g', emeraldGreen),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.black12, height: 1)),
                    
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.local_drink_rounded, color: Colors.blue, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('💧 Hidrasi Tubuh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: darkText)),
                              Text('$_waterCount / 8 gelas terpenuhi', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                            ],
                          ),
                        ),
                        
                        InkWell(
                          onTap: () => _updateWater(-1),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade100)
                            ),
                            child: const Icon(Icons.remove, color: Colors.red, size: 16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        ElevatedButton(
                          onPressed: () => _updateWater(1),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            elevation: 0,
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.add, size: 16),
                              SizedBox(width: 4),
                              Text('1 Gelas', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildPiringkuGuide(),
              const SizedBox(height: 20),

              _buildInsightsCard(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFAFAFA),
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: emeraldGreen.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
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
    );
  }

  Widget _buildMacroColumn(String title, String subtitle, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: darkText)),
        Text(subtitle, style: const TextStyle(fontSize: 9, color: Colors.black45)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: color)),
      ],
    );
  }

  Widget _buildPiringkuGuide() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.pie_chart_rounded, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Panduan Isi Piringku 🍽️', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: darkText)),
                    Text('Standar Emas Kemenkes RI', style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Aturan emas rasio porsi saat makan untuk menjaga metabolisme tubuh:', style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildPiringkuTile('🌾 Karbo', '2/3 Piring', 'Nasi, jagung, ubi.', Colors.orange.shade50, Colors.orange.shade900)),
              const SizedBox(width: 12),
              Expanded(child: _buildPiringkuTile('🥚 Lauk', '1/3 Piring', 'Tahu, tempe, ikan.', Colors.red.shade50, Colors.red.shade900)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildPiringkuTile('🥦 Sayur', '2/3 Piring', 'Serat pencernaan.', Colors.green.shade50, primaryGreen)),
              const SizedBox(width: 12),
              Expanded(child: _buildPiringkuTile('🍌 Buah', '1/3 Piring', 'Vitamin & gula alami.', Colors.purple.shade50, Colors.purple.shade900)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPiringkuTile(String title, String ratio, String desc, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: color)),
          const SizedBox(height: 2),
          Text(ratio, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: color.withValues(alpha: 0.7))),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(fontSize: 9, color: Colors.black87, height: 1.3)),
        ],
      ),
    );
  }

  Widget _buildInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.tips_and_updates_rounded, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text('Catatan Pelatih AI 🤖', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightItem(
            Icons.star_rounded, 
            'Mode Klasifikasi: $_kategoriDiet', 
            'Target asupan harianmu dikalkulasi sebesar ${_targetKalori.toInt()} kkal berdasarkan klasifikasi AI. Imbangi dengan pola makan teratur!'
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            Icons.local_drink_rounded, 
            'Target Hidrasi Tubuh', 
            'Pastikan minum minimal 8 gelas sehari ($_waterCount/8 gelas terpenuhi) untuk membantu penyerapan makronutrisi secara optimal.'
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.orange.shade700, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: darkText)),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(fontSize: 11, color: Colors.black87, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}