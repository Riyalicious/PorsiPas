import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyHistory = 'diet_history_porsipas';
  static const String _keyWater = 'water_count_porsipas';

  static Future<void> saveDietRecord(Map<String, dynamic> record) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_keyHistory) ?? [];
    history.add(jsonEncode(record));
    await prefs.setStringList(_keyHistory, history);
  }

  // Tipe data disederhanakan menjadi Future<List> agar tidak ada ">>>"
  static Future<List> getDietHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_keyHistory) ?? [];
    return history.map((item) => jsonDecode(item)).toList();
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHistory);
  }

  static Future<void> saveWaterCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyWater, count);
  }

  static Future<int> getWaterCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyWater) ?? 0;
  }
  // --- FUNGSI BARU: Mengupdate data riwayat terakhir tanpa menambah baris baru ---
  static Future<void> updateLastDietRecord(Map<String, dynamic> updatedRecord) async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyString = prefs.getString('diet_history'); // Sesuaikan key jika di kodemu berbeda
    
    if (historyString != null) {
      List<dynamic> historyList = jsonDecode(historyString);
      if (historyList.isNotEmpty) {
        // Ganti elemen paling terakhir di dalam List dengan data yang baru di-refresh
        historyList[historyList.length - 1] = updatedRecord;
        
        // Simpan kembali list yang sudah diubah ke SharedPreferences
        await prefs.setString('diet_history', jsonEncode(historyList));
      }
    }
  }
}