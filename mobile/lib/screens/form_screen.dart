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
  DateTime? _birthDate;
  bool _isProfileLocked = false;

  int _tinggi = 166;
  int _berat = 68;
  String _olahraga = "2 - Aktif Berkeringat (3-5 hari/minggu)";
  
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

  @override
  void initState() {
    super.initState();
    _loadSavedProfile();
  }

  Future<void> _loadSavedProfile() async {
    final history = await StorageService.getDietHistory();
    final profile = await StorageService.getUserProfile();
    
    if (history.isNotEmpty && profile != null) {
      setState(() {
        _isPria = profile['is_pria'];
        _birthDate = DateTime.parse(profile['birth_date']);
        _isProfileLocked = true; 
      });
    } else {
      setState(() {
        _isProfileLocked = false;
      });
    }
  }

  int _getUmur() {
    if (_birthDate == null) return 22;
    DateTime today = DateTime.now();
    int age = today.year - _birthDate!.year;
    if (today.month < _birthDate!.month || (today.month == _birthDate!.month && today.day < _birthDate!.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    if (_isProfileLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil biologi sudah dikunci. Hapus semua riwayat untuk membukanya.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 22)),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: primaryGreen),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  int _calculateLiveTDEE() {
    int currentAge = _getUmur();
    double bmr = _isPria 
      ? (10 * _berat) + (6.25 * _tinggi) - (5 * currentAge) + 5
      : (10 * _berat) + (6.25 * _tinggi) - (5 * currentAge) - 161;
      
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
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Peringatan: Silakan pilih Tanggal Lahir terlebih dahulu!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    int umurAktual = _getUmur();

    if (umurAktual <= 0 || _tinggi <= 50 || _berat <= 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Peringatan: Masukkan angka yang valid!'),
          backgroundColor: Colors.orange,
        ),
      );
      return; 
    }

    setState(() => _isLoading = true);

    try {
      int freq = 3;
      if (_olahraga.contains("0")) freq = 0;
      if (_olahraga.contains("1")) freq = 1;
      if (_olahraga.contains("2")) freq = 2;

      final data = await ApiService.fetchDietPlan(
        isPria: _isPria,
        umur: umurAktual,
        tinggi: _tinggi.toDouble(),
        berat: _berat.toDouble(),
        frekuensiOlahraga: freq,
        targetTubuh: _selectedTarget, 
      );

      if (!_isProfileLocked) {
        await StorageService.saveUserProfile(
          isPria: _isPria, 
          birthDateIso: _birthDate!.toIso8601String()
        );
        _isProfileLocked = true;
      }

      final record = {
        'timestamp': DateTime.now().toIso8601String(),
        'target_tubuh': _selectedTarget,
        'is_pria': _isPria,
        'aktivitas': _olahraga,
        
        'kalori': data.targetKaloriHarian.toStringAsFixed(0),
        'status': data.statusKesehatan, 
        'tinggi': _tinggi,
        'berat': _berat,
        'umur': umurAktual,
        'skor': data.skorKesehatan,

        'insight_ai': data.insightAi,
        'target_karbo_harian': data.targetKarboHarian,
        'target_protein_harian': data.targetProteinHarian,
        'target_lemak_harian': data.targetLemakHarian,
        
        'menu_sarapan': data.porsiMakan['sarapan']?.menu.nama,
        'menu_siang': data.porsiMakan['makan_siang']?.menu.nama,
        'menu_malam': data.porsiMakan['makan_malam']?.menu.nama,

        'img_sarapan': data.porsiMakan['sarapan']?.menu.imageUrl,
        'img_siang': data.porsiMakan['makan_siang']?.menu.imageUrl,
        'img_malam': data.porsiMakan['makan_malam']?.menu.imageUrl,

        'karbo_sarapan': data.porsiMakan['sarapan']?.menu.karbohidrat,
        'pro_sarapan': data.porsiMakan['sarapan']?.menu.protein,
        'lemak_sarapan': data.porsiMakan['sarapan']?.menu.lemak,
        'porsi_gram_sarapan': data.porsiMakan['sarapan']?.menu.porsiGram,

        'karbo_siang': data.porsiMakan['makan_siang']?.menu.karbohidrat,
        'pro_siang': data.porsiMakan['makan_siang']?.menu.protein,
        'lemak_siang': data.porsiMakan['makan_siang']?.menu.lemak,
        'porsi_gram_siang': data.porsiMakan['makan_siang']?.menu.porsiGram,

        'karbo_malam': data.porsiMakan['makan_malam']?.menu.karbohidrat,
        'pro_malam': data.porsiMakan['makan_malam']?.menu.protein,
        'lemak_malam': data.porsiMakan['makan_malam']?.menu.lemak,
        'porsi_gram_malam': data.porsiMakan['makan_malam']?.menu.porsiGram,
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

            const Text('Identitas Biologis (Hanya diisi sekali)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: darkText)),
            const SizedBox(height: 12),
            
            GestureDetector(
              onTap: () {
                if (_isProfileLocked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profil biologi sudah dikunci secara permanen.'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: AbsorbPointer(
                absorbing: _isProfileLocked,
                child: Opacity(
                  opacity: _isProfileLocked ? 0.6 : 1.0,
                  child: Row(
                    children: [
                      Expanded(child: _buildGenderSelector(true, 'Pria', 'Laju Metabolisme Cepat')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildGenderSelector(false, 'Wanita', 'Kebutuhan Hormonal')),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: () => _selectBirthDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: _isProfileLocked ? Colors.grey.shade100 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.cake_outlined, color: Colors.orange, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _birthDate == null 
                                ? 'Pilih Tanggal Lahir' 
                                : 'Lahir: ${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                            style: TextStyle(
                              color: _isProfileLocked ? Colors.grey.shade600 : darkText,
                              fontWeight: FontWeight.bold,
                              fontSize: 14
                            ),
                          ),
                          if (_birthDate != null)
                            Text(
                              'Usia terhitung: ${_getUmur()} Tahun',
                              style: const TextStyle(fontSize: 11, color: Colors.black54),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      _isProfileLocked ? Icons.lock_outline : Icons.calendar_today,
                      color: _isProfileLocked ? Colors.grey : primaryGreen,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

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
                  shadowColor: emeraldGreen.withValues(alpha: 0.5),
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
              decoration: BoxDecoration(color: isSelected ? primaryGreen.withValues(alpha: 0.1) : Colors.grey.shade100, shape: BoxShape.circle),
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

  Widget _buildCompactNumberInput({required String title, required String unit, required IconData icon, required int value, required VoidCallback onMinus, required VoidCallback onPlus, required Function(int) onManualInput}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: primaryGreen, size: 20),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black54), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(onTap: onMinus, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle), child: const Icon(Icons.remove, size: 16, color: Colors.black87))),
              
              Expanded( 
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => _showEditDialog(context, title, value, unit, onManualInput),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryGreen.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: primaryGreen.withValues(alpha: 0.2)),
                      ),
                      child: FittedBox( 
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text('$value', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: darkText)),
                              const SizedBox(width: 2),
                              Text(unit, style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 4),
                              const Icon(Icons.edit, size: 12, color: primaryGreen),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              InkWell(onTap: onPlus, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle), child: const Icon(Icons.add, size: 16, color: Colors.black87))),
            ],
          ),
        ],
      ),
    );
  }
}