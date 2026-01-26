import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    if (_prefs == null) {
      throw Exception('Storage not initialized. Call Storage.init() first.');
    }
    return _prefs!;
  }

  static Future<bool> setString(String key, String value) async {
    return await _instance.setString(key, value);
  }

  static String? getString(String key) {
    return _instance.getString(key);
  }

  static Future<bool> setBool(String key, bool value) async {
    return await _instance.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _instance.getBool(key);
  }

  static Future<bool> setInt(String key, int value) async {
    return await _instance.setInt(key, value);
  }

  static int? getInt(String key) {
    return _instance.getInt(key);
  }

  static Future<bool> setDouble(String key, double value) async {
    return await _instance.setDouble(key, value);
  }

  static double? getDouble(String key) {
    return _instance.getDouble(key);
  }

  static Future<bool> setStringList(String key, List<String> value) async {
    return await _instance.setStringList(key, value);
  }

  static List<String>? getStringList(String key) {
    return _instance.getStringList(key);
  }

  static Future<bool> setJson(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    return await _instance.setString(key, jsonString);
  }

  static Map<String, dynamic>? getJson(String key) {
    final jsonString = _instance.getString(key);
    if (jsonString == null) {
      return null;
    }
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> remove(String key) async {
    return await _instance.remove(key);
  }

  static Future<bool> clear() async {
    return await _instance.clear();
  }

  static bool containsKey(String key) {
    return _instance.containsKey(key);
  }

  static Set<String> getKeys() {
    return _instance.getKeys();
  }
}
