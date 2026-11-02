import 'dart:convert';
import 'dart:async'; 
import 'package:http/http.dart' as http;

class Menu {
  final String nama;
  final String kategori;
  final String imageUrl;
  final double karbohidrat;
  final double protein;
  final double lemak;

  Menu({required this.nama, required this.kategori, required this.imageUrl, required this.karbohidrat, required this.protein, required this.lemak});

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      nama: json['nama'] ?? 'Menu Tidak Ditemukan',
      kategori: json['kategori'] ?? '-',
      imageUrl: json['image_url'] ?? 'https://via.placeholder.com/150',
      karbohidrat: (json['karbohidrat'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      lemak: (json['lemak'] ?? 0).toDouble(),
    );
  }
}

class MealPortion {
  final double targetKalori;
  final Menu menu;

  MealPortion({required this.targetKalori, required this.menu});

  factory MealPortion.fromJson(Map<String, dynamic> json) {
    return MealPortion(
      targetKalori: (json['target_kalori'] ?? 0).toDouble(),
      menu: Menu.fromJson(json['menu'] ?? {}),
    );
  }
}

class DietRecommendation {
  final String statusKesehatan;
  final double targetKaloriHarian;
  final double kebutuhanAirMl;
  final int kebutuhanAirGelas;
  final int skorKesehatan;
  final Map<String, MealPortion> porsiMakan;

  DietRecommendation({
    required this.statusKesehatan,
    required this.targetKaloriHarian,
    required this.kebutuhanAirMl,
    required this.kebutuhanAirGelas,
    required this.skorKesehatan,
    required this.porsiMakan,
  });

  factory DietRecommendation.fromJson(Map<String, dynamic> json) {
    return DietRecommendation(
      statusKesehatan: json['status_kesehatan'] ?? 'Tidak Diketahui',
      targetKaloriHarian: (json['target_kalori_harian'] ?? 0).toDouble(),
      kebutuhanAirMl: (json['kebutuhan_air_ml'] ?? 0).toDouble(),
      kebutuhanAirGelas: json['kebutuhan_air_gelas'] ?? 0,
      skorKesehatan: json['skor_kesehatan'] ?? 0,
      porsiMakan: {
        "sarapan": MealPortion.fromJson(json['porsi_makan']['sarapan']),
        "makan_siang": MealPortion.fromJson(json['porsi_makan']['makan_siang']),
        "makan_malam": MealPortion.fromJson(json['porsi_makan']['makan_malam']),
      },
    );
  }
}

class ApiService {
  static const String baseUrl = "https://regulate-subsoil-booted.ngrok-free.dev";

  static Future<DietRecommendation> fetchDietPlan({
    required bool isPria,
    required int umur,
    required double tinggi,
    required double berat,
    required int frekuensiOlahraga,
    required String targetTubuh, // <-- Berubah jadi target tubuh statis
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/predict'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "is_pria": isPria,
          "umur": umur,
          "tinggi": tinggi,
          "berat": berat,
          "frekuensi_olahraga": frekuensiOlahraga,
          "target_tubuh": targetTubuh // <-- Kirim ke FastAPI
        }),
      ).timeout(const Duration(seconds: 10)); 

      if (response.statusCode == 200) {
        return DietRecommendation.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Server merespons dengan kode: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Server AI tidak merespons (Timeout). Pastikan backend Python sudah menyala.');
    } catch (e) {
      throw Exception('Gagal menghubungi AI Server. Cek koneksi lokalmu.');
    }
  }

  static Future<Map<String, dynamic>> regenerateSingleMenu(String kategori) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/regenerate-menu'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"kategori": kategori}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return {
            'nama': data['data']['nama'],
            'gambar': data['data']['image_url'],
            'karbo': data['data']['karbohidrat'],
            'protein': data['data']['protein'],
            'lemak': data['data']['lemak'],
          };
        }
      }
      throw Exception('Format balasan AI tidak sesuai');
    } catch (e) {
      throw Exception('Gagal mengacak menu: $e');
    }
  }
}