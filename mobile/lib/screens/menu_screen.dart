import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart'; 

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _isLoading = true;
  bool _hasData = false; 
  double _targetKalori = 0;
  
  String _insightAi = "";
  double _targetKarboHarian = 0.0;
  double _targetProteinHarian = 0.0;
  double _targetLemakHarian = 0.0;

  bool _isRefSarapan = false;
  bool _isRefSiang = false;
  bool _isRefMalam = false;

  Map<String, dynamic> _sarapanData = {};
  Map<String, dynamic> _siangData = {};
  Map<String, dynamic> _malamData = {};

  static const Color primaryGreen = Color(0xFF047857);
  static const Color darkText = Color(0xFF1F2937);

  @override
  void initState() {
    super.initState();
    _loadAIData();
  }

  double _parseDoubleSafely(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Future<void> _loadAIData() async {
    setState(() => _isLoading = true);
    
    try {
      final history = await StorageService.getDietHistory();
      
      if (history.isNotEmpty) {
        final lastRecord = history.last;
        setState(() {
          _hasData = true; 
          _targetKalori = _parseDoubleSafely(lastRecord['kalori']);
          
          _insightAi = lastRecord['insight_ai']?.toString() ?? 
              "AI membagi kalorimu ke dalam 3 Makanan Utama.";
          _targetKarboHarian = _parseDoubleSafely(lastRecord['target_karbo_harian']);
          _targetProteinHarian = _parseDoubleSafely(lastRecord['target_protein_harian']);
          _targetLemakHarian = _parseDoubleSafely(lastRecord['target_lemak_harian']);
          
          _sarapanData = {
            'nama': lastRecord['menu_sarapan']?.toString() ?? "Menu tidak ditemukan",
            'gambar': lastRecord['img_sarapan']?.toString() ?? "",
            'karbo': _parseDoubleSafely(lastRecord['karbo_sarapan']),
            'protein': _parseDoubleSafely(lastRecord['pro_sarapan']),
            'lemak': _parseDoubleSafely(lastRecord['lemak_sarapan']),
            'porsi_gram': _parseDoubleSafely(lastRecord['porsi_gram_sarapan'] ?? 100),
          };

          _siangData = {
            'nama': lastRecord['menu_siang']?.toString() ?? "Menu tidak ditemukan",
            'gambar': lastRecord['img_siang']?.toString() ?? "",
            'karbo': _parseDoubleSafely(lastRecord['karbo_siang']),
            'protein': _parseDoubleSafely(lastRecord['pro_siang']),
            'lemak': _parseDoubleSafely(lastRecord['lemak_siang']),
            'porsi_gram': _parseDoubleSafely(lastRecord['porsi_gram_siang'] ?? 150),
          };

          _malamData = {
            'nama': lastRecord['menu_malam']?.toString() ?? "Menu tidak ditemukan",
            'gambar': lastRecord['img_malam']?.toString() ?? "",
            'karbo': _parseDoubleSafely(lastRecord['karbo_malam']),
            'protein': _parseDoubleSafely(lastRecord['pro_malam']),
            'lemak': _parseDoubleSafely(lastRecord['lemak_malam']),
            'porsi_gram': _parseDoubleSafely(lastRecord['porsi_gram_malam'] ?? 150),
          };
        });
      } else {
        setState(() => _hasData = false);
      }
    } catch (e) {
      debugPrint("Error loading AI Data: $e");
      setState(() => _hasData = false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshSingleMenu(String category) async {
    setState(() {
      if (category == 'SARAPAN') _isRefSarapan = true;
      if (category == 'SIANG') _isRefSiang = true;
      if (category == 'MALAM') _isRefMalam = true;
    });

    try {
      String apiCategory = 'Sarapan';
      if (category == 'SIANG') apiCategory = 'Makan Siang';
      if (category == 'MALAM') apiCategory = 'Makan Malam';

      final newMenu = await ApiService.regenerateSingleMenu(apiCategory);
      
      await _updateStorageRecord(category, newMenu);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefSarapan = false;
          _isRefSiang = false;
          _isRefMalam = false;
        });
      }
    }
  }

  Future<void> _updateStorageRecord(String category, Map<String, dynamic> newMenu) async {
    setState(() {
      if (category.contains('SARAPAN')) _sarapanData = newMenu;
      else if (category.contains('SIANG')) _siangData = newMenu;
      else if (category.contains('MALAM')) _malamData = newMenu;
    });

    final history = await StorageService.getDietHistory();
    if (history.isNotEmpty) {
      var lastRecord = history.last;
      if (category.contains('SARAPAN')) {
         lastRecord['menu_sarapan'] = newMenu['nama'];
         lastRecord['img_sarapan'] = newMenu['gambar'] ?? newMenu['image_url'];
         lastRecord['karbo_sarapan'] = newMenu['karbo'] ?? newMenu['karbohidrat'];
         lastRecord['pro_sarapan'] = newMenu['protein'];
         lastRecord['lemak_sarapan'] = newMenu['lemak'];
         lastRecord['porsi_gram_sarapan'] = newMenu['porsi_gram'];
      } else if (category.contains('SIANG')) {
         lastRecord['menu_siang'] = newMenu['nama'];
         lastRecord['img_siang'] = newMenu['gambar'] ?? newMenu['image_url'];
         lastRecord['karbo_siang'] = newMenu['karbo'] ?? newMenu['karbohidrat'];
         lastRecord['pro_siang'] = newMenu['protein'];
         lastRecord['lemak_siang'] = newMenu['lemak'];
         lastRecord['porsi_gram_siang'] = newMenu['porsi_gram'];
      } else if (category.contains('MALAM')) {
         lastRecord['menu_malam'] = newMenu['nama'];
         lastRecord['img_malam'] = newMenu['gambar'] ?? newMenu['image_url'];
         lastRecord['karbo_malam'] = newMenu['karbo'] ?? newMenu['karbohidrat'];
         lastRecord['pro_malam'] = newMenu['protein'];
         lastRecord['lemak_malam'] = newMenu['lemak'];
         lastRecord['porsi_gram_malam'] = newMenu['porsi_gram'];
      }
      await StorageService.updateLastDietRecord(lastRecord);
    }
  }

  Future<void> _showMenuOptions(BuildContext context, String waktu, int targetKalori, Map<String, dynamic> currentData) async {
    Future<List<dynamic>>? fetchFuture;
    try {
      fetchFuture = ApiService.getMenuOptions(targetKalori.toDouble(), waktu);
    } catch (e) {
      fetchFuture = Future.error(e);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Pilih Menu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                ),
                Flexible(
                  child: FutureBuilder<List<dynamic>>(
                    future: fetchFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(child: CircularProgressIndicator(color: primaryGreen)),
                        );
                      }
                      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(child: Text('Gagal memuat menu: ${snapshot.error ?? "Data tidak ditemukan"}')),
                        );
                      }
                      
                      final menus = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: menus.length,
                        itemBuilder: (context, index) {
                          final menu = menus[index];
                          return ListTile(
                            leading: Image.network(menu['image_url'] ?? '', width: 50, height: 50, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 50, color: Colors.black26)),
                            title: Text(menu['nama']?.toString() ?? 'Tanpa Nama', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Porsi: ${menu['porsi_gram']}g | Kalori: $targetKalori Kcal\nPro: ${menu['protein']}g | Lemak: ${menu['lemak']}g | Karbo: ${menu['karbohidrat']}g'),
                            isThreeLine: true,
                            onTap: () {
                              Navigator.pop(context);
                              final mappedMenu = {
                                'nama': menu['nama'],
                                'gambar': menu['image_url'],
                                'karbo': menu['karbohidrat'],
                                'protein': menu['protein'],
                                'lemak': menu['lemak'],
                                'porsi_gram': menu['porsi_gram'],
                              };
                              _updateStorageRecord(waktu.toUpperCase(), mappedMenu);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: primaryGreen))
      );
    }
    if (!_hasData) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 80,
          title: const Text('Rekomendasi Menu AI', style: TextStyle(color: darkText, fontWeight: FontWeight.w900, fontSize: 20)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: primaryGreen.withValues(alpha: 0.05), shape: BoxShape.circle),
                  child: Icon(Icons.restaurant_menu_rounded, size: 80, color: primaryGreen.withValues(alpha: 0.5)),
                ),
                const SizedBox(height: 24),
                const Text('Belum Ada Rencana Diet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: darkText)),
                const SizedBox(height: 12),
                const Text(
                  'Silakan masuk ke menu Kalkulator dan minta saran AI untuk menyusun rekomendasi makanan harian Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final double safeKalori = _targetKalori.isNaN || _targetKalori.isInfinite ? 0 : _targetKalori;
    final int kaloriSarapan = (safeKalori * 0.25).toInt();
    final int kaloriSiang = (safeKalori * 0.40).toInt();
    final int kaloriMalam = (safeKalori * 0.35).toInt();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Rekomendasi Menu', style: TextStyle(color: darkText, fontWeight: FontWeight.w900, fontSize: 20)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(12)),
                  child: const Text('AI Curated', style: TextStyle(color: primaryGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: const [
                Icon(Icons.energy_savings_leaf_outlined, color: primaryGreen, size: 14),
                SizedBox(width: 4),
                Expanded(child: Text('Berdasarkan pedoman gizi seimbang Isi Piringku Kemenkes RI', style: TextStyle(color: Colors.black54, fontSize: 11), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAIData, 
        color: primaryGreen,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          children: [
            _buildAIInsightCard(),
            const SizedBox(height: 24),

            _buildModernMenuCard(
              title: 'Sarapan', 
              time: '07:00 - 08:30',
              icon: Icons.wb_sunny_outlined,
              data: _sarapanData, 
              calories: kaloriSarapan,
              isRefreshing: _isRefSarapan,
              onRefresh: () => _refreshSingleMenu('SARAPAN'),
            ),
            const SizedBox(height: 24),

            _buildModernMenuCard(
              title: 'Makan Siang', 
              time: '12:00 - 13:30',
              icon: Icons.wb_incandescent_outlined,
              data: _siangData, 
              calories: kaloriSiang,
              isRefreshing: _isRefSiang,
              onRefresh: () => _refreshSingleMenu('SIANG'),
            ),
            const SizedBox(height: 24),

            _buildModernMenuCard(
              title: 'Makan Malam', 
              time: '18:30 - 20:00',
              icon: Icons.nights_stay_outlined,
              data: _malamData, 
              calories: kaloriMalam,
              isRefreshing: _isRefMalam,
              onRefresh: () => _refreshSingleMenu('MALAM'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAIInsightCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryGreen.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: primaryGreen, size: 20),
              const SizedBox(width: 8),
              const Text("Insight AI PorsiPas", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkText)),
            ],
          ),
          const SizedBox(height: 10),
          Text(_insightAi, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildModernMenuCard({
    required String title,
    required String time,
    required IconData icon,
    required Map<String, dynamic> data,
    required int calories,
    required bool isRefreshing,
    required VoidCallback onRefresh,
  }) {
    String imageUrl = data['gambar'] ?? '';
    double porsiAsli = _parseDoubleSafely(data['porsi_gram']);
    if (porsiAsli <= 0) porsiAsli = 100; 
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: primaryGreen, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: darkText),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                time,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                      color: Color(0xFFE2E8F0),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, size: 60, color: Colors.black26),
                          )
                        : const Icon(Icons.fastfood, size: 60, color: Colors.black26),
                  ),
                  
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                      ),
                    ),
                  ),

                  Positioned(
                    top: 16,
                    right: 16,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showMenuOptions(context, title, calories, data),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: Colors.white.withAlpha(230), borderRadius: BorderRadius.circular(20)),
                            child: const Text('Pilih Menu', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                        GestureDetector(
                          onTap: isRefreshing ? null : onRefresh,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(230),
                              shape: BoxShape.circle,
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                            ),
                            child: isRefreshing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(color: primaryGreen, strokeWidth: 2),
                                  )
                                : const Icon(Icons.sync_rounded, color: primaryGreen, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['nama'] ?? 'Menu PorsiPas',
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, shadows: [Shadow(color: Colors.black54, blurRadius: 4)]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(6)),
                              child: Row(
                                children: [
                                  const Icon(Icons.scale_outlined, color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text('Porsi: ${porsiAsli.toStringAsFixed(0)}g', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: primaryGreen, borderRadius: BorderRadius.circular(8)),
                              child: Text('~$calories Kcal', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNutrientChip('Protein', data['protein'], const Color(0xFFD1FAE5), primaryGreen),
                    _buildNutrientChip('Karbo', data['karbo'], const Color(0xFFFEF3C7), const Color(0xFFD97706)),
                    _buildNutrientChip('Lemak', data['lemak'], const Color(0xFFE0E7FF), const Color(0xFF4338CA)),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientChip(String label, double value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
          Text('${value.toStringAsFixed(0)}g', style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}