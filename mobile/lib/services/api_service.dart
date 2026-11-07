import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/diet_model.dart';

class ApiService {
  static const String baseUrl = "https://regulate-subsoil-booted.ngrok-free.dev";

  static Future<DietRecommendation> fetchDietPlan({
    required bool isPria,
    required int umur,
    required double tinggi,
    required double berat,
    required int frekuensiOlahraga,
    required String targetTubuh,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/predict'),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
        body: jsonEncode({
          "is_pria": isPria,
          "umur": umur,
          "tinggi": tinggi,
          "berat": berat,
          "frekuensi_olahraga": frekuensiOlahraga,
          "target_tubuh": targetTubuh,
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
      throw Exception('Gagal menghubungi AI Server: $e');
    }
  }

  static Future<Map<String, dynamic>> regenerateSingleMenu(String kategori) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/regenerate-menu'),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
        body: jsonEncode({"kategori": kategori}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> bodyJson = jsonDecode(response.body);
        
        Map<String, dynamic> menuData;
        if (bodyJson.containsKey('data') && bodyJson['data'] is Map<String, dynamic>) {
          menuData = bodyJson['data'];
        } else if (bodyJson.containsKey('menu') && bodyJson['menu'] is Map<String, dynamic>) {
          menuData = bodyJson['menu'];
        } else {
          menuData = bodyJson;
        }

        final menuObj = Menu.fromJson(menuData);
        return {
          'nama': menuObj.nama,
          'kategori': menuObj.kategori == '-' ? kategori : menuObj.kategori,
          'gambar': menuObj.imageUrl,
          'image_url': menuObj.imageUrl,
          'karbo': menuObj.karbohidrat,
          'karbohidrat': menuObj.karbohidrat,
          'protein': menuObj.protein,
          'lemak': menuObj.lemak,
          'porsi_gram': menuObj.porsiGram,
        };
      } else {
        throw Exception('Server merespons kode: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal mengacak menu: $e');
    }
  }
}