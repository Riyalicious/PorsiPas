import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyHistory = 'diet_history_porsipas';
  static const String _keyWater = 'water_count_porsipas';
  static const String _keyProfile = 'user_profile_porsipas';

  static Future<void> saveUserProfile({required bool isPria, required String birthDateIso}) async {
    final prefs = await SharedPreferences.getInstance();
    final profileData = {
      'is_pria': isPria,
      'birth_date': birthDateIso,
    };
    await prefs.setString(_keyProfile, jsonEncode(profileData));
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(_keyProfile);
    if (dataString != null) {
      return jsonDecode(dataString) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> saveDietRecord(Map<String, dynamic> record) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_keyHistory) ?? [];
    history.add(jsonEncode(record));
    await prefs.setStringList(_keyHistory, history);
  }

  static Future<List<dynamic>> getDietHistory() async {
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

  static Future<void> updateLastDietRecord(Map<String, dynamic> updatedRecord) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? historyStringList = prefs.getStringList(_keyHistory); 
    
    if (historyStringList != null && historyStringList.isNotEmpty) {
      List<dynamic> historyList = historyStringList.map((item) => jsonDecode(item)).toList();
      historyList[historyList.length - 1] = updatedRecord;
      List<String> updatedStringList = historyList.map((item) => jsonEncode(item)).toList();
      await prefs.setStringList(_keyHistory, updatedStringList);
    }
  }
}