import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  bool _isPria = true;
  int _umur = 22;
  int _tinggi = 175;
  int _berat = 69;
  String _olahraga = "2 - Aktif Berkeringat (3-5 hari/minggu)";
  
  // Opsi Target Fisik Statis
  final List<String> _targetOptions = [
    "Menurunkan Berat Badan",
    "Menjaga Berat Badan",
    "Menaikkan Berat Badan"
  ];
  String _selectedTarget = "Menjaga Berat Badan";

  bool _isLoading = false;

  static const Color primaryGreen = Color(0xFF047857);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color darkText = Color(0xFF1F2937);

  // Kalkulasi TDEE dinamis untuk ditampilkan di UI
  int _calculateLiveTDEE() {
    double bmr = _isPria 
      ? (10 * _berat) + (6.25 * _tinggi) - (5 * _umur) + 5
      : (10 * _berat) + (6.25 * _tinggi) - (5 * _umur) - 161;
      
    int freq = 0;
    if (_olahraga.contains("1")) freq = 1;
    if (_olahraga.contains("2")) freq = 2;
    if (_olahraga.contains("3")) freq = 3;

    double tdee = bmr * (1.2 + (freq * 0.1));

    if (_selectedTarget == "Menurunkan Berat Badan") {
      tdee -= 500;
    } else if (_selectedTarget == "Menaikkan Berat Badan") {
      tdee += 400;
    }
    
    return tdee.toInt();
  }

  Future<void> _hitungPrediksi() async {
    setState(() => _isLoading = true);

    try {
      int freq = 3;
      if (_olahraga.contains("0")) freq = 0;
      if (_olahraga.contains("1")) freq = 1;
      if (_olahraga.contains("2")) freq = 2;

      final data = await ApiService.fetchDietPlan(
        isPria: _isPria,
        umur: _umur,
        tinggi: _tinggi.toDouble(),
        berat: _berat.toDouble(),
        frekuensiOlahraga: freq,
        targetTubuh: _selectedTarget, // Mengirim target fisik
      );

      final record = {
        // --- DATA BARU YANG DISIMPAN ---
        'timestamp': DateTime.now().toIso8601String(),
        'target_tubuh': _selectedTarget,
        'is_pria': _isPria,
        'aktivitas': _olahraga,
        // -------------------------------
        
        'kalori': data.targetKaloriHarian.toStringAsFixed(0),
        'status': data.statusKesehatan, 
        'tinggi': _tinggi,
        'berat': _berat,
        'umur': _umur,
        'skor': data.skorKesehatan,
        
        'menu_sarapan': data.porsiMakan['sarapan']?.menu.nama,
        'menu_siang': data.porsiMakan['makan_siang']?.menu.nama,
        'menu_malam': data.porsiMakan['makan_malam']?.menu.nama,

        'img_sarapan': data.porsiMakan['sarapan']?.menu.imageUrl,
        'img_siang': data.porsiMakan['makan_siang']?.menu.imageUrl,
        'img_malam': data.porsiMakan['makan_malam']?.menu.imageUrl,

        'karbo_sarapan': data.porsiMakan['sarapan']?.menu.karbohidrat,
        'pro_sarapan': data.porsiMakan['sarapan']?.menu.protein,
        'lemak_sarapan': data.porsiMakan['sarapan']?.menu.lemak,

        'karbo_siang': data.porsiMakan['makan_siang']?.menu.karbohidrat,
        'pro_siang': data.porsiMakan['makan_siang']?.menu.protein,
        'lemak_siang': data.porsiMakan['makan_siang']?.menu.lemak,

        'karbo_malam': data.porsiMakan['makan_malam']?.menu.karbohidrat,
        'pro_malam': data.porsiMakan['makan_malam']?.menu.protein,
        'lemak_malam': data.porsiMakan['makan_malam']?.menu.lemak,
      };
      await StorageService.saveDietRecord(record);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perhitungan berhasil! Data AI telah diperbarui.'), 
          backgroundColor: primaryGreen
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showEditDialog(BuildContext context, String title, int currentValue, String unit, Function(int) onSave) async {
    final TextEditingController controller = TextEditingController(text: currentValue.toString());
    
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Atur $title', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: darkText)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkText),
            decoration: InputDecoration(
              suffixText: unit,
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryGreen, width: 2)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                final int? parsed = int.tryParse(controller.text);
                if (parsed != null && parsed > 0) {
                  onSave(parsed);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: const [
                      Icon(Icons.biotech, color: primaryGreen, size: 14),
                      SizedBox(width: 6),
                      Text('Kalibrasi Tubuh', style: TextStyle(color: primaryGreen, fontSize: 11, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Ayo Kenali\nTubuhmu Lebih Dalam 🧬',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: darkText, height: 1.2),
            ),
            const SizedBox(height: 12),
            const Text(
              'Jujur itu sehat! Masukkan data terbarumu agar algoritma AI PorsiPas bisa meracik kalori dan porsi makan yang 100% cocok untuk metabolisme unikmu.',
              style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 30),
            
            // --- DROPDOWN TARGET FISIK ---
            const Text('Pilih Target Fisik Anda:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: darkText)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTarget,
                  isExpanded: true,
                  icon: const Icon(Icons.flag_circle, color: primaryGreen),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: darkText, fontSize: 13),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTarget = newValue!;
                    });
                  },
                  items: _targetOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 30),

            const Text('Identitas Biologis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: darkText)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildGenderSelector(true, 'Pria', 'Laju Metabolisme Cepat')),
                const SizedBox(width: 16),
                Expanded(child: _buildGenderSelector(false, 'Wanita', 'Kebutuhan Hormonal')),
              ],
            ),
            const SizedBox(height: 20),

            _buildNumberInputRow(
              title: 'Usia Kamu Saat Ini',
              subtitle: 'Berpengaruh pada laju seluler.',
              icon: Icons.cake_outlined,
              value: _umur,
              unit: 'Th',
              onMinus: () => setState(() => _umur > 10 ? _umur-- : null),
              onPlus: () => setState(() => _umur < 100 ? _umur++ : null),
              onManualInput: (val) => setState(() => _umur = val),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildCompactNumberInput(
                    title: 'Tinggi Badan',
                    unit: 'cm',
                    icon: Icons.height,
                    value: _tinggi,
                    onMinus: () => setState(() => _tinggi > 100 ? _tinggi-- : null),
                    onPlus: () => setState(() => _tinggi < 250 ? _tinggi++ : null),
                    onManualInput: (val) => setState(() => _tinggi = val),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCompactNumberInput(
                    title: 'Berat Badan',
                    unit: 'kg',
                    icon: Icons.monitor_weight_outlined,
                    value: _berat,
                    onMinus: () => setState(() => _berat > 30 ? _berat-- : null),
                    onPlus: () => setState(() => _berat < 200 ? _berat++ : null),
                    onManualInput: (val) => setState(() => _berat = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text('Seberapa Sering Kamu Berolahraga? 💦', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: darkText)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _olahraga,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: primaryGreen),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: darkText, fontSize: 13),
                  onChanged: (String? newValue) {
                    setState(() {
                      _olahraga = newValue!;
                    });
                  },
                  items: <String>[
                    "0 - Kaum Rebahan (Sangat Jarang)",
                    "1 - Pemanasan (1-3 hari/minggu)",
                    "2 - Aktif Berkeringat (3-5 hari/minggu)",
                    "3 - Atlet Sejati (6-7 hari/minggu)"
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // LIVE TDEE ESTIMATION
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.insights, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text('Estimasi TDEE Harian:', style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: '~${_calculateLiveTDEE()} ', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.blue)),
                        const TextSpan(text: 'kkal', style: TextStyle(fontSize: 10, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _hitungPrediksi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: emeraldGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  shadowColor: emeraldGreen.withOpacity(0.5),
                ),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Minta Saran AI Sekarang', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        SizedBox(width: 8),
                        Icon(Icons.auto_awesome, size: 18),
                      ],
                    ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Privasi dijamin 100%. Datamu tidak kami sebar luaskan.',
                style: TextStyle(fontSize: 10, color: Colors.black45),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector(bool isMale, String title, String subtitle) {
    bool isSelected = _isPria == isMale;
    return GestureDetector(
      onTap: () => setState(() => _isPria = isMale),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? primaryGreen : Colors.grey.shade200, width: isSelected ? 1.5 : 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: isSelected ? primaryGreen.withOpacity(0.1) : Colors.grey.shade100, shape: BoxShape.circle),
              child: Icon(isMale ? Icons.male : Icons.female, color: isSelected ? primaryGreen : Colors.black54, size: 24),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: darkText)),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberInputRow({required String title, required String subtitle, required IconData icon, required int value, required String unit, required VoidCallback onMinus, required VoidCallback onPlus, required Function(int) onManualInput}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: darkText)),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.black54)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                InkWell(onTap: onMinus, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.remove, size: 16, color: Colors.black87))),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: InkWell(
                    onTap: () => _showEditDialog(context, title, value, unit, onManualInput),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: primaryGreen.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Text('$value $unit', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: darkText)),
                          const SizedBox(width: 4),
                          const Icon(Icons.edit, size: 12, color: primaryGreen),
                        ],
                      ),
                    ),
                  ),
                ),

                InkWell(onTap: onPlus, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add, size: 16, color: Colors.black87))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactNumberInput({required String title, required String unit, required IconData icon, required int value, required VoidCallback onMinus, required VoidCallback onPlus, required Function(int) onManualInput}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: primaryGreen, size: 20),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(onTap: onMinus, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle), child: const Icon(Icons.remove, size: 16, color: Colors.black87))),
              const SizedBox(width: 8),
              
              InkWell(
                onTap: () => _showEditDialog(context, title, value, unit, onManualInput),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: primaryGreen.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('$value', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: darkText)),
                      const SizedBox(width: 2),
                      Text(unit, style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit, size: 12, color: primaryGreen),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),
              InkWell(onTap: onPlus, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle), child: const Icon(Icons.add, size: 16, color: Colors.black87))),
            ],
          ),
        ],
      ),
    );
  }
}